//
//  AppDelegate.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Firebase
import AVFoundation




@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    

    
    
    

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Firebase.configure()
        InterfaceManager.shared.launchInterface()
        DataCoordinator.configure()
        
        return true
    }



    func applicationWillTerminate(_ application: UIApplication) {
        CoreData.mainContext.saveChanges()
    }
}

