//
//  PhotoWriter.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import AVFoundation
import HelpKit



class PhotoWriter: NSObject {
    
    private let photoOutput: AVCapturePhotoOutput
    
    init(photoOutput: AVCapturePhotoOutput){
        self.photoOutput = photoOutput
        super.init()
    }
    private var currentPhotoCompletion: ((UIImage) -> ())?
    
    func takePhoto(shouldUseFlash: Bool, completion: @escaping (UIImage) -> Void){
        
        self.currentPhotoCompletion = completion
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = false
        settings.flashMode = shouldUseFlash ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
}

extension PhotoWriter: AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData, scale: 1){
            if let completion = currentPhotoCompletion{
                completion(image)
                currentPhotoCompletion = nil
            }
        }
    }
    
    
}
