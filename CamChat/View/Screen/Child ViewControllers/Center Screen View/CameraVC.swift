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
        get{ return camera.isFlashEnabled }
        set{ camera.isFlashEnabled = newValue }
    }
   
    func flipCamera(){
        camera.flipCamera()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension CameraVC: CameraCaptureButtonDelegate{
    
    
    
    func respondToTap() {
        camera.takePhoto()
    }
    
    func respondToLongPress(event: CameraCaptureButton.LongPressEvent) {
        switch event {
        case .began: camera.startRecordingVideo()
        case .ended: camera.stopRecordingVideo()
        }
    }
    
    
    func panGestureTranslationChangedTo(translation: CGPoint) {
        let desiredScale = -translation.y / 4200
        camera.setZoomScaleTo(desiredScale)
    }
    
    func shouldRespondToUserInteraction() -> Bool {
        
        #if targetEnvironment(simulator)
        cancelCurrentTouch()
        presentOopsAlert(description: "Photos and videos cannot be taken in the simulator. Please run this app on an actual device to take advantage of this feature.")
        return false
        
        #else
        
        if camera.isActive.isFalse{
            cancelCurrentTouch()
            presentOopsAlert(description: "Please allow CamChat access to the camera and microphone in your privacy settings.")
            return false
        }
        return true
        #endif
    }
    
    private func cancelCurrentTouch(){
        cameraCaptureButton.gestureRecognizers?.forEach{ $0.cancelCurrentTouch() }
    }
    
    
}
