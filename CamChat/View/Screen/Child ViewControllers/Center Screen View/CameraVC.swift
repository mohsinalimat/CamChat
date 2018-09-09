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

    
    
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureDevice: AVCaptureDevice!
    
    
    private weak var stopCaptureSessionTimer: Timer!
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopCaptureSessionTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {[weak self, weak captureSession] (timer) in
            
            guard let self = self, let captureSession = captureSession else {return}
            
            DispatchQueue.global(qos: .background).async {
                if captureSession.isRunning{
                    captureSession.stopRunning()
                }
            }
            timer.invalidate()
            self.stopCaptureSessionTimer = nil
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let timer = stopCaptureSessionTimer{timer.invalidate(); stopCaptureSessionTimer = nil}
        DispatchQueue.global(qos: .background).async { [weak captureSession] in
            
            guard let captureSession = captureSession else {return}
            
            if captureSession.isRunning.isFalse{
                captureSession.startRunning()
            }
        }
    }
    
  
    
    
    
    
    
    
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
