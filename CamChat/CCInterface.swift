//
//  CCInterface.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class InterfaceManager{
    
    
    
    private var login
    
    private var mainInterfaceWindow: UIWindow = {
        let x = UIWindow(frame: UIScreen.main.bounds)
        x.rootViewController = Screen.main
        return x
    }()
    
    
    
    
    
    
    
    
}
