//
//  CCInterface.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

private(set) var APP_INSETS: UIEdgeInsets!


class InterfaceManager{
    
    private init(){ }
    
    static var shared = InterfaceManager()

    private var loginWindow: UIWindow?
    private var mainScreenWindow: UIWindow?
    
    
    private func getWindow() -> UIWindow{
        let window = UIWindow(frame: UIScreen.main.bounds)
        if APP_INSETS.isNil { APP_INSETS = window.safeAreaInsets }
        [0, 0].forEach{window.gestureRecognizers?.remove(at: $0)}
        return window
    }
    
    @discardableResult private func initializeMainScreenWindow() -> UIWindow{
        let x = getWindow()
        x.rootViewController = Screen()
        mainScreenWindow = x
        return x
    }
    
    @discardableResult private func initializeLoginWindow() -> UIWindow{
        let x = getWindow()
        x.rootViewController = Login_MainVC()
        loginWindow = x
        return x
    }
    
    /**
     Call this function when the app is first launched to present the app's user interface on screen.
     */
    func launchInterface(){
        let window = DataCoordinator.userIsLoggedIn ? initializeMainScreenWindow() : initializeLoginWindow()
        window.makeKeyAndVisible()
    }
    
    func transitionToLoginInterface(){
        if let mainScreenWindow = mainScreenWindow{
            let loginWindow = initializeLoginWindow()
            transition(from: mainScreenWindow, to: loginWindow){
                self.mainScreenWindow?.dismissAllPresentedViewControllers()
                self.mainScreenWindow = nil
            }
        }
    }
    
    func transitionToMainInterface(){
        if let loginWindow = loginWindow{
            let mainScreen = initializeMainScreenWindow()
            transition(from: loginWindow, to: mainScreen) {
                self.loginWindow?.dismissAllPresentedViewControllers()
                self.loginWindow = nil
            }
        }
    }
    
    private func transition(from fromWindow: UIWindow, to toWindow: UIWindow, completion: @escaping () -> Void){
        
        let minTransform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        toWindow.isHidden = true; toWindow.isHidden = false
        toWindow.transform = minTransform
        toWindow.alpha = 0
    
        UIView.animate(withDuration: 0.3) { toWindow.alpha = 1 }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: [.curveEaseIn, .allowUserInteraction], animations: {
            
            fromWindow.transform = minTransform
            toWindow.transform = CGAffineTransform.identity
            
        }, completion: { (success) in completion(); toWindow.makeKeyAndVisible()})
    }
    
    





}
