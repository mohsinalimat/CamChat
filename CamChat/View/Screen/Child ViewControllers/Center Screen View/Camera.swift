//
//  Camera.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import AVFoundation
import HelpKit

protocol CameraDelegate: class {
    func willTakePhoto()
    func didTakePhoto(image: UIImage)
    
    func didStartRecordingVideo()
    func willFinishRecordingVideo()
    func didFinishRecordingVideo(url: URL)
}




class Camera: NSObject {
    
    private let captureSession = AVCaptureSession()
    
    var isActive: Bool{
        
        return captureSession.inputs.count >= 2 || captureSession.isRunning.isFalse
    }
    
    private var photoCaptureOutput: AVCapturePhotoOutput?
    private var videoCaptureOutput: AVCaptureVideoDataOutput?
    private var audioCaptureOutput: AVCaptureAudioDataOutput?
    
    private var videoWriter: VideoWriter!
    
    
    private weak var delegate: CameraDelegate?
    
    init(delegate: CameraDelegate){
        self.delegate = delegate
        super.init()
        prepareCamera()
    }
    
    
    var isFlashEnabled = false
    

    func getPreviewLayer() -> CALayer{
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        return previewLayer
    }
    
    
    func startRecordingVideo(){
        videoWriter?.startWriting()
        delegate?.didStartRecordingVideo()
    }
    
    func stopRecordingVideo(){
        guard let videoWriter = videoWriter else {return}
        self.delegate?.willFinishRecordingVideo()
        videoWriter.stopWriting { (url) in
            DispatchQueue.main.async {
                self.delegate?.didFinishRecordingVideo(url: url)
            }
        }
    }
    
    
    func takePhoto(){
        if captureSession.isRunning.isFalse{return}
        delegate?.willTakePhoto()
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = false
        settings.flashMode = isFlashEnabled ? .on : .off
        
        
        photoCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    
    private func prepareCamera() {

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        
        self.setUpCaptureSesionInputsFor(position: .back)
        
        let photoOutput = AVCapturePhotoOutput()
        self.photoCaptureOutput = photoOutput
        photoOutput.isHighResolutionCaptureEnabled = true
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        self.videoCaptureOutput = videoOutput
        
        let audioOutput = AVCaptureAudioDataOutput()
        self.audioCaptureOutput = audioOutput

        
        for ouput in [photoOutput, videoOutput, audioOutput]{
            captureSession.addOutput(ouput)
        }
        
        captureSession.commitConfiguration()
        self.videoWriter = VideoWriter(audioOutput: audioOutput, videoOutput: videoOutput, flashController: self)
        captureSession.startRunning()
    }
    
    
    
    
    
 
    
    
    
    func flipCamera(){
        setUpCaptureSesionInputsFor(position: currentCameraPosition == .back ? .front : .back)
    }
    
    
    private enum CameraPosition{case front, back}
    
    private var currentCameraPosition = CameraPosition.back
    
    private var currentCameraInput: AVCaptureDeviceInput?
    private var previousUserBrighnesSetting: CGFloat?
    private var currentBrightnessWhiteView: UIView?
    
    
    
    private func setUpCaptureSesionInputsFor(position: CameraPosition){
        
        if let writer = self.videoWriter{writer.pauseForCameraFlip()}
    
        captureSession.beginConfiguration()

        defer {
            currentCameraPosition = position
            captureSession.commitConfiguration()
            if let writer = self.videoWriter{writer.resumeAfterCameraFlip()}
        }
        
        guard let camera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position == .back ? .back : .front).devices.first,
            let audioDevice = AVCaptureDevice.default(for: .audio)
            else { return }
        
        
        if let previousCameraInput = currentCameraInput{
            captureSession.removeInput(previousCameraInput)
        } else {
            setSessionWith(captureDevice: audioDevice)
        }
        
        let cameraInput = setSessionWith(captureDevice: camera)!
        currentCameraInput = cameraInput
        
        let shouldMirrorOutput = position == .front
        
        for output in [photoCaptureOutput].filterOutNils(){
            output.connections.forEach{
                $0.automaticallyAdjustsVideoMirroring = false
                $0.isVideoMirrored = shouldMirrorOutput
            }
        }
    }
    
    
    
    
    
    
    @discardableResult private func setSessionWith(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        
        if let input = try? AVCaptureDeviceInput(device: captureDevice){
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
            return input
        }
        return nil
    }
    
    
    
    
    
}

extension Camera: CaptureDeviceFlashController{
    
    func flashIsNeeded() {
        if let currentCamera = currentCameraInput{
            if currentCamera.device.isTorchAvailable{
                handleErrorWithPrintStatement {
                    try currentCamera.device.lockForConfiguration()
                    currentCamera.device.torchMode = .on
                    currentCamera.device.unlockForConfiguration()
                }
            }
            
            if currentCameraPosition == .front{
                enableArtificialFlash()
            }
        }
    }
    
    func flashIsNoLongerNeeded() {
        if let currentCamera = currentCameraInput{
            
            if currentCamera.device.isTorchAvailable{
                handleErrorWithPrintStatement {
                    try currentCamera.device.lockForConfiguration()
                    currentCamera.device.torchMode = .off
                    currentCamera.device.unlockForConfiguration()
                }
            }
            
            disableArtificialFlash()
            
        }
    }
    
    private func enableArtificialFlash(){
        
        DispatchQueue.main.async {
            self.previousUserBrighnesSetting = UIScreen.main.brightness
            UIScreen.main.brightness = 1
            let whitenessView = UIView(frame: UIScreen.main.bounds)
            whitenessView.backgroundColor = .white
            whitenessView.alpha = 0.8
            whitenessView.isUserInteractionEnabled = false
            self.currentBrightnessWhiteView = whitenessView
            UIApplication.shared.keyWindow?.addSubview(whitenessView)
        }
    }
    
    private func disableArtificialFlash(){
        if let previous = previousUserBrighnesSetting{
            previousUserBrighnesSetting = nil
            UIScreen.main.brightness = previous
        }
        if let whitenessView = currentBrightnessWhiteView{
            DispatchQueue.main.async {
                whitenessView.removeFromSuperview()
                self.currentBrightnessWhiteView = nil
            }
            
        }
    }
}


extension Camera: AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error{ print(error); return }
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData, scale: 1){
            delegate?.didTakePhoto(image: image)
        } else { fatalError() }
    }
    
}
