//
//  VdeoRecorder.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import AVFoundation
import HelpKit


protocol CaptureDeviceFlashController: class{
    func flashIsNeeded()
    func flashIsNoLongerNeeded()
    
    var isFlashEnabled: Bool{get}
}

class VideoWriter: NSObject {
    
    private var previousVideoSegmentWriters = [VideoSegmentWriter]()
    private var currentVideoSegmentWriter: VideoSegmentWriter?
    
    private var currentUnstitchedVideos = [AVAsset]()
    private var currentLostBuffers = [(buffer: CMSampleBuffer, captureDevice: AVCaptureOutput)]()
    private var urlGenerator = UniqueURLGenerator()
    
    private let audioOutput: AVCaptureAudioDataOutput
    private let videoOutput: AVCaptureVideoDataOutput
    
    private unowned let flashController: CaptureDeviceFlashController
    
    init?(audioOutput: AVCaptureAudioDataOutput, videoOutput: AVCaptureVideoDataOutput, flashController: CaptureDeviceFlashController){
        self.audioOutput = audioOutput
        self.videoOutput = videoOutput
        self.flashController = flashController
        super.init()
        
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        guard let writer = VideoSegmentWriter(audioOutput: audioOutput, videoOutput: videoOutput) else {return nil}
        currentVideoSegmentWriter = writer
    }
    
    private let queue = DispatchQueue(label: "BestQueueEver")
    
    private(set) var isRecording = false
    
    func startWriting(){
        if isRecording{ return }
        isRecording = true
        if flashController.isFlashEnabled{flashController.flashIsNeeded()}
        self.currentVideoSegmentWriter = VideoSegmentWriter(audioOutput: audioOutput, videoOutput: videoOutput)
    }
    
    private var currentUrlCompletionHandler: ((URL) -> Void)?
    
    func stopWriting(completion: @escaping (URL) -> Void){
        if isRecording.isFalse{return}
        isRecording = false
        self.currentUrlCompletionHandler = completion
        stopAndCacheCurrentSegementWriter { self.stitchAndSendVideo() }
        flashController.flashIsNoLongerNeeded()
    }
    

    func pauseForCameraFlip(){
        if isRecording.isFalse{return}
        stopAndCacheCurrentSegementWriter()
        if flashController.isFlashEnabled{flashController.flashIsNoLongerNeeded()}
    }
    
    func resumeAfterCameraFlip(){
        if isRecording.isFalse{return}
        if flashController.isFlashEnabled{ flashController.flashIsNeeded()}
        currentVideoSegmentWriter = VideoSegmentWriter(audioOutput: audioOutput, videoOutput: videoOutput)
    }
    
    private func stopAndCacheCurrentSegementWriter(_ completion: (() -> Void)? = nil){
        guard let currentWriter = currentVideoSegmentWriter else {return}
        currentWriter.stopWriting { (url) in
            let asset = AVAsset(url: url)
            self.currentUnstitchedVideos.append(asset)
            self.previousVideoSegmentWriters.append(self.currentVideoSegmentWriter!)
            
            completion?()
        }
    }
    
    private func stitchAndSendVideo(){
        guard let completion = currentUrlCompletionHandler else {fatalError()}
        
        merge(arrayVideos: self.currentUnstitchedVideos) { (url) in
            self.currentUrlCompletionHandler = nil
            self.currentUnstitchedVideos.removeAll()
            self.urlGenerator.clearAndDeleteTempURLs()
            self.previousVideoSegmentWriters.removeAll()
            completion(url)
        }
    }
    
    
    private func merge(arrayVideos:[AVAsset], completion: @escaping (URL) -> Void) -> Void {
        
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = CMTime.zero
        
        for videoAsset in arrayVideos {
            if let videoTrack = videoAsset.tracks(withMediaType: .video).item(at: 0){
                try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoTrack, at: insertTime)
            }
            
            if let soundTrack = videoAsset.tracks(withMediaType: .audio).item(at: 0){
                try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: soundTrack, at: insertTime)
            }
            
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
       
        let outputUrl = urlGenerator.getNewPermanentURL()
        
        let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)!
        
        exporter.outputURL = outputUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                completion(outputUrl)
            }
        }
    }
    
    

}

extension VideoWriter: AVCaptureAudioDataOutputSampleBufferDelegate { }

extension VideoWriter: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let writer = self.currentVideoSegmentWriter else {
            if isRecording{ self.currentLostBuffers.append((sampleBuffer, output)) }
            return
        }
        if self.currentLostBuffers.isEmpty.isFalse{
            currentLostBuffers.forEach({writer.add(sampleBuffer: $0, captureOutput: $1)})
            currentLostBuffers.removeAll()
        }
        writer.add(sampleBuffer: sampleBuffer, captureOutput: output)
    }
}











private class VideoSegmentWriter{
    
    private var audioOuput: AVCaptureAudioDataOutput
    private var videoOutput: AVCaptureVideoDataOutput
    
    private var assetWriter: AVAssetWriter
    private var assetAudioInput: AVAssetWriterInput
    private var assetVideoInput: AVAssetWriterInput
    
    private let urlGenerator = UniqueURLGenerator()
    
    init?(audioOutput: AVCaptureAudioDataOutput, videoOutput: AVCaptureVideoDataOutput){
        self.audioOuput = audioOutput
        self.videoOutput = videoOutput
        self.assetWriter = try! AVAssetWriter(outputURL: self.urlGenerator.getNewTempURL(), fileType: .mp4)
        guard let audioInputSettings = (audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4) as? [String : Any]) else {return nil}
        guard let videoInputSettings = videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4) else {return nil}
        self.assetAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioInputSettings)
        self.assetVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoInputSettings)
        [self.assetVideoInput, self.assetAudioInput].forEach{self.assetWriter.add($0)}
        self.assetVideoInput.expectsMediaDataInRealTime = true
        self.assetAudioInput.expectsMediaDataInRealTime = true
        
        self.assetWriter.startWriting()
    }
    
    private var hasStoppedWriting = false
    private var hasStartedWriting = false

    
    
    func add(sampleBuffer: CMSampleBuffer, captureOutput: AVCaptureOutput){
        if hasStoppedWriting { return }
        if hasStartedWriting.isFalse{
            hasStartedWriting = true
            
            let sourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let interval = CMTimeMake(value: 5, timescale: 100)
            
            let actualTime = CMTimeAdd(interval, sourceTime)
            assetWriter.startSession(atSourceTime: actualTime)
        }
        if captureOutput === audioOuput && assetAudioInput.isReadyForMoreMediaData{
            assetAudioInput.append(sampleBuffer)
        } else if captureOutput === videoOutput && assetVideoInput.isReadyForMoreMediaData{
            assetVideoInput.append(sampleBuffer)
        }
    }
    
    
    func stopWriting(_ completion: @escaping (URL) -> Void){
        
        if hasStoppedWriting || hasStartedWriting.isFalse { return }
        hasStoppedWriting = true
        
        assetVideoInput.markAsFinished()
        assetAudioInput.markAsFinished()
        
        assetWriter.finishWriting {
            completion(self.assetWriter.outputURL)
        }
    }
    
    
    
    deinit { urlGenerator.clearAndDeleteTempURLs() }
}











private class UniqueURLGenerator{
    
    private var currentTempUrls = [URL]()
    
    func getNewTempURL() -> URL{
        let url = getNewPermanentURL()
        currentTempUrls.append(url)
        return url
    }
    
    func getNewPermanentURL() -> URL{
        let uniqueString = NSUUID().uuidString
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsURL = url.appendingPathComponent(uniqueString + ".mp4")
        return documentsURL
    }
    
    func clearAndDeleteTempURLs(){
        for url in currentTempUrls{
            if FileManager.default.fileExists(atPath: url.path){
                handleErrorWithPrintStatement {
                    try FileManager.default.removeItem(at: url)
                }
            }
        }
        currentTempUrls.removeAll()
    }
    
}

