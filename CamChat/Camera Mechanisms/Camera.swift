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
    
    private let cameraCaptureSession = AVCaptureSession()
    private let microphoneCaptureSession = AVCaptureSession()
    
    private(set) var isActive = false
    
    private var photoCaptureOutput: AVCapturePhotoOutput?
    private var videoCaptureOutput: AVCaptureVideoDataOutput?
    private var audioCaptureOutput: AVCaptureAudioDataOutput?
    
    private var videoWriter: VideoWriter!
    private var photoWriter: PhotoWriter!
    
    private weak var delegate: CameraDelegate?
    
    private enum CameraPosition{case front, back}
    
    
    private var currentCameraInfo: (deviceInput: AVCaptureDeviceInput, position: CameraPosition)?
    
    private let flasher = Flasher()
    
    init(delegate: CameraDelegate){
        self.delegate = delegate
        super.init()
        
        
        handleAuthoriziationOfCaptureDevices { (callback) in
            if case .success = callback { self.setUp() }
        }
    }
    
    
    var isFlashEnabled = false
    
    
    private func setUp(){
        
        #if !targetEnvironment(simulator)
    
        setUpMicrophoneCaptureSession()
        setUpCameraCaptureSession()
        videoWriter = VideoWriter(videoOutput: self.videoCaptureOutput!, audioOutput: self.audioCaptureOutput!)
        photoWriter = PhotoWriter(photoOutput: self.photoCaptureOutput!)
        isActive = true
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil){[weak self] _ in
            guard let self = self else {return}
            
            if self.cameraCaptureSession.isRunning.isFalse{
                self.cameraCaptureSession.startRunning()
            }
        }
        
        #endif
        
    }
    
    private func tearDown(){
        photoWriter = nil
        videoWriter = nil
        audioCaptureOutput = nil
        videoCaptureOutput = nil
        photoCaptureOutput = nil
        isActive = false
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func handleAuthoriziationOfCaptureDevices(completion: @escaping (HKFailableCompletion) -> Void){
    
        handleAuthorization(for: .audio) { (callback) in
            switch callback {
            case .success: self.handleAuthorization(for: .video, completion: {completion($0)})
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    private func handleAuthorization(for deviceType: AVMediaType, completion: @escaping (HKFailableCompletion) -> Void){
        
        switch AVCaptureDevice.authorizationStatus(for: deviceType){
        case .authorized: completion(.success)
        case .notDetermined: AVCaptureDevice.requestAccess(for: deviceType) {
                completion($0 ? .success : .failure(HKError.unknownError))
            }
        case .denied, .restricted: completion(.failure(HKError.unknownError))
        }
        
        
    }
    
    
    
    

    private func setUpMicrophoneCaptureSession(){
        microphoneCaptureSession.beginConfiguration()
        
        microphoneCaptureSession.sessionPreset = .hd1280x720
        
        let audioOutput = AVCaptureAudioDataOutput()
        self.audioCaptureOutput = audioOutput
        
        microphoneCaptureSession.addOutput(audioOutput)
        
        let audioDevice = AVCaptureDevice.default(for: .audio)!
        set(session: microphoneCaptureSession, withCaptureDevice: audioDevice)
        
        microphoneCaptureSession.commitConfiguration()

    }
    
    private func setUpCameraCaptureSession(){
        cameraCaptureSession.beginConfiguration()
        
        cameraCaptureSession.sessionPreset = .hd1280x720
        
        
        let photoOutput = AVCapturePhotoOutput()
        self.photoCaptureOutput = photoOutput
        photoOutput.isHighResolutionCaptureEnabled = true
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoCaptureOutput = videoOutput
        
        for ouput in [photoOutput, videoOutput]{
            cameraCaptureSession.addOutput(ouput)
        }
        setUpCameraCaptureSesionInputFor(position: .back)

        cameraCaptureSession.commitConfiguration()
        
        cameraCaptureSession.startRunning()
    }
    
    
    
    func getPreviewLayer() -> CALayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraCaptureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        return previewLayer
    }
    
    
    func startRecordingVideo() {
        guard let videoWriter = videoWriter, let currentCamera = currentCameraInfo?.deviceInput else {return}
        if isActive.isFalse || videoWriter.isWriting {return}
        microphoneCaptureSession.startRunning()
        if isFlashEnabled{ flasher.turnOnFlash(forCaptureInput: currentCamera) }
        videoWriter.startWriting()
        delegate?.didStartRecordingVideo()
    }
    
    func stopRecordingVideo(){
        defer{ self.microphoneCaptureSession.stopRunning() }
        guard isActive, let videoWriter = videoWriter else {return}
        
        let camera = currentCameraInfo!.deviceInput
        flasher.turnOffFlash(forCaptureInput: camera)
        
        self.delegate?.willFinishRecordingVideo()
        videoWriter.finishWriting { (url) in
            DispatchQueue.main.async {
                self.delegate?.didFinishRecordingVideo(url: url)
                
                handleErrorWithPrintStatement {
                    
                    let device = self.currentCameraInfo!.deviceInput.device
                    if device.videoZoomFactor == 1 {return}
                    try device.lockForConfiguration()
                    device.ramp(toVideoZoomFactor: 1, withRate: 15)
                    device.unlockForConfiguration()
                }
            }
        }
    }
    
    
    func takePhoto(){
        if isActive.isFalse{return}
        delegate?.willTakePhoto()
        photoWriter?.takePhoto(shouldUseFlash: isFlashEnabled, completion: { (image) in
            self.delegate?.didTakePhoto(image: image)
        })
    }
    

    func flipCamera() {
        guard isActive, let cameraInfo = currentCameraInfo else { return }
        setUpCameraCaptureSesionInputFor(position: cameraInfo.position == .back ? .front : .back)
    }
    
    /// 0 represents no zoom, 1 represents the maximum zoom allowed.
    func setZoomScaleTo(_ val: CGFloat){
        guard let currentCamera = currentCameraInfo?.deviceInput.device else {return}
        let desiredScale = currentCamera.minAvailableVideoZoomFactor + ((currentCamera.maxAvailableVideoZoomFactor - currentCamera.minAvailableVideoZoomFactor) * val)
        handleErrorWithPrintStatement {
            try currentCamera.lockForConfiguration()
            currentCamera.videoZoomFactor = max(min(desiredScale, currentCamera.maxAvailableVideoZoomFactor), currentCamera.minAvailableVideoZoomFactor)
            currentCamera.unlockForConfiguration()
        }
    }
    
 
  
    private func setUpCameraCaptureSesionInputFor(position: CameraPosition){

        cameraCaptureSession.beginConfiguration()
        
        let camera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position == .back ? .back : .front).devices.first!
        
        if let previousCameraInput = currentCameraInfo?.deviceInput{
            flasher.turnOffFlash(forCaptureInput: previousCameraInput)
            cameraCaptureSession.removeInput(previousCameraInput)
        }
        
        let cameraInput = set(session: cameraCaptureSession, withCaptureDevice: camera)!
        currentCameraInfo = (cameraInput, position)
        
        adjustOutputConnectionMirroringFor(position: position)
        
        
        cameraCaptureSession.commitConfiguration()
        
        if let writer = videoWriter {
            if writer.isWriting && isFlashEnabled.isTrue{
                flasher.turnOnFlash(forCaptureInput: cameraInput)
            }
        }
    }
    
    private func adjustOutputConnectionMirroringFor(position: CameraPosition){
        let shouldMirrorOutput = position == .front
        
        for output in [photoCaptureOutput, videoCaptureOutput].filterOutNils(){
            output.connections.forEach {
                $0.videoOrientation = .portrait
                $0.automaticallyAdjustsVideoMirroring = false
                $0.isVideoMirrored = shouldMirrorOutput
            }
        }
    }    
    
    
    
    
    @discardableResult private func set(session: AVCaptureSession, withCaptureDevice device: AVCaptureDevice) -> AVCaptureDeviceInput? {
        
        if let input = try? AVCaptureDeviceInput(device: device){
            if session.canAddInput(input){
                session.addInput(input)
                return input
            }
        }
        return nil
    }
}
