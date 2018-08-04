//
//  ChatTransitionConformance.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/29/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



extension Screen: ChatControllerTransitionAnimationParticipator{
    var topBarView: UIView {
        return topBar_typed
    }
    
    
    
    var viewToDim: UIView!{
        return leftScreen.backgroundView
    }
    
    
}
