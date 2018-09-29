//
//  CameraVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import AVFoundation






class CameraVC: UIViewController {
    
    
    private let camera: Camera
    
    
    init(cameraDelegate: CameraDelegate){
        
        self.camera = Camera(delegate: cameraDelegate)
        super.init(nibName: nil, bundle: nil)
    }
  
    
    func getCaptureButton() -> CameraCaptureButton{
        return cameraCaptureButton
    }
    
    private lazy var cameraCaptureButton: CameraCaptureButton = {
        let x = CameraCaptureButton(delegate: self)
        return x
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPreviewLayer()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(respondToTapGesture(gesture:)))
        tapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesture)
    }
    
    
    
    @objc private func respondToTapGesture(gesture: UITapGestureRecognizer){
        if gesture.state == .ended{
            camera.flipCamera()
        }
    }

    
    private func setUpPreviewLayer() {
        
        let layer = camera.getPreviewLayer()
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        
    }
    
    var isFlashEnabled: Bool{
        get{return camera.isFlashEnabled}
        set{camera.isFlashEnabled = newValue}
    }
   
    func flipCamera(){
        camera.flipCamera()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension CameraVC: CameraCaptureButtonDelegate{
    
    private var cameraAccessWarning: String {
        return "Please allow CamChat access to the camera and microphone in your privacy settings."
    }
    
    func respondToTap() {
        if camera.isActive.isFalse {
            presentOopsAlert(description: cameraAccessWarning)
            return
        }
        camera.takePhoto()
    }
    
    func respondToLongPress(event: CameraCaptureButton.LongPressEvent) {
        
        switch event {
        case .began: camera.startRecordingVideo()
        case .ended: camera.stopRecordingVideo()
        }
    }

    func shouldRespondToLongPressGesture() -> Bool {
        if camera.isActive.isFalse{
            showCameraAccessWarning()
            return false
        } else { return true }
    }
    
    private func showCameraAccessWarning(){
        cameraCaptureButton.gestureRecognizers?.forEach{ $0.cancelCurrentTouch() }
        presentOopsAlert(description: cameraAccessWarning)
    }
    
}
