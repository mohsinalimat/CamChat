//
//  CameraVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    var captureDevice:AVCaptureDevice!
    
    
    
    
    
    
    
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        if let availableDevice = availableDevices.first{
            captureDevice = availableDevice
            beginSession()
            
        }
        
        
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
            
        } catch {
            print(error.localizedDescription)
        }
    
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
    }
}
