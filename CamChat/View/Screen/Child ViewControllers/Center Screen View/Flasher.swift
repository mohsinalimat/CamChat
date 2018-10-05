//
//  Flasher.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/29/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import AVFoundation
import HelpKit


class Flasher{
    
    
    func turnOnFlash(forCaptureInput input: AVCaptureDeviceInput) {
        
        if input.device.isTorchAvailable{
            handleErrorWithPrintStatement {
                try input.device.lockForConfiguration()
                input.device.torchMode = .on
                input.device.unlockForConfiguration()
            }
        } else { enableArtificialFlash() }
    }
    
    
    func turnOffFlash(forCaptureInput input: AVCaptureDeviceInput) {
        
        if input.device.isTorchAvailable{
            handleErrorWithPrintStatement {
                try input.device.lockForConfiguration()
                input.device.torchMode = .off
                input.device.unlockForConfiguration()
            }
        } else { disableArtificialFlash() }
    }
    
    
    
    private var fakeFlashInfo: (whiteView: UIView, previousUserBrightness: CGFloat)?
    
    private func enableArtificialFlash(){
        
        DispatchQueue.main.async {
            let previousBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
            let whitenessView = UIView(frame: UIScreen.main.bounds)
            whitenessView.backgroundColor = .white
            whitenessView.alpha = 0.8
            whitenessView.isUserInteractionEnabled = false
            UIApplication.shared.keyWindow?.addSubview(whitenessView)
            self.fakeFlashInfo = (whitenessView, previousBrightness)
        }
    }
    
    
    
    private func disableArtificialFlash(){
        
        DispatchQueue.main.async {
            if let info = self.fakeFlashInfo{
                info.whiteView.removeFromSuperview()
                UIScreen.main.brightness = info.previousUserBrightness
                self.fakeFlashInfo = nil
            }
        }
    }
}
