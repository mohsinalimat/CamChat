//
//  Screen_OtherRandomStuff.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


extension Screen{
    
    func enterSelectionMode(newTopBar: UIView?){
        navigationView.isUserInteractionEnabled = false
        topBar_typed.isUserInteractionEnabled = false
        horizontalScrollInteractor.stopAcceptingTouches()
        
        UIView.animate(withDuration: 0.1) {
            self.navigationView.alpha = 0
            self.bottomGradientView.alpha = 0
        }
        

        if let bar = newTopBar {
            topBar_typed.alpha = 0
            bar.pinAllSides(addTo: view, pinTo: topBar_typed)
            self.currentSelectionModeTopBar = newTopBar
        }
    }
    
    func endSelectionMode(){
        navigationView.isUserInteractionEnabled = true
        topBar_typed.isUserInteractionEnabled = true
        horizontalScrollInteractor.startAcceptingTouches()
        topBar_typed.alpha = 1
        
        UIView.animate(withDuration: 0.1) {
            self.navigationView.alpha = 1
            self.bottomGradientView.alpha = 1
        }
        
        
        if let bar = currentSelectionModeTopBar{
            bar.removeFromSuperview()
        }
    }
    
}
