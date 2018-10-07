//
//  VdeoRecorder.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import AVFoundation
import HelpKit




class VideoWriter: NSObject{
    
    private(set) var isWriting = false
    private var hasStartedWritingCurrentVideo = false
    
    
    private let videoOutput: AVCaptureVideoDataOutput
    private let audioOutput: AVCaptureAudioDataOutput
    
    private var assetWriter: AVAssetWriter!
    private var audioAssetInput: AVAssetWriterInput!
    private var videoAssetInput: AVAssetWriterInput!
    
    
    init(videoOutput: AVCaptureVideoDataOutput, audioOutput: AVCaptureAudioDataOutput){
        self.videoOutput = videoOutput
        self.audioOutput = audioOutput
        
        super.init()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        resetAssetWriter()
    }
    
    private func resetAssetWriter(){
        assetWriter = try! AVAssetWriter(outputURL: getNewURL(), fileType: .mp4)
        
        audioAssetInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4) as? [String: Any])
        videoAssetInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4))
    
        audioAssetInput.expectsMediaDataInRealTime = true
        videoAssetInput.expectsMediaDataInRealTime = true
        for input in [audioAssetInput, videoAssetInput]{ assetWriter.add(input!) }
        
        assetWriter.startWriting()
    }
    
    private let queue = DispatchQueue(label: "The best queue in the world!!!!")
    
    func startWriting(){
        if isWriting{ return }
        if assetWriter.status == .failed{resetAssetWriter()}
        hasStartedWritingCurrentVideo = false
        isWriting = true
    }
    

    
    func finishWriting(_ completion: @escaping (URL) -> Void){
        if isWriting.isFalse{return}
        isWriting = false
        videoAssetInput.markAsFinished()
        audioAssetInput.markAsFinished()
        let url = self.assetWriter.outputURL

        assetWriter.finishWriting {
            completion(url)
            self.resetAssetWriter()
        }
        hasStartedWritingCurrentVideo = false
    }
    
    
    
    func getNewURL() -> URL{
        let uniqueString = NSUUID().uuidString
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsURL = url.appendingPathComponent(uniqueString + ".mp4")
        return documentsURL
    }

}

extension VideoWriter: AVCaptureVideoDataOutputSampleBufferDelegate { }
extension VideoWriter: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    
        if isWriting.isFalse{ return }
        if self.assetWriter.status == .failed { 
            resetAssetWriter()
            hasStartedWritingCurrentVideo = false
        }
        
        if hasStartedWritingCurrentVideo.isFalse && output === audioOutput{return}
        
        if hasStartedWritingCurrentVideo.isFalse {
            hasStartedWritingCurrentVideo = true
            let sourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            assetWriter.startSession(atSourceTime: sourceTime)
        }
        if output === audioOutput && audioAssetInput.isReadyForMoreMediaData{
            audioAssetInput.append(sampleBuffer)
        } else if output === videoOutput && videoAssetInput.isReadyForMoreMediaData{
            videoAssetInput.append(sampleBuffer)
        }
    }
}










