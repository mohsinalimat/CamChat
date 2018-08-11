//
//  Screen_Layout.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



extension Screen{
    
    

    func setUpViews(){
        view.backgroundColor = .black
        
        view.addSubview(centerScreen.view)
        view.addSubview(topBarBottomLine)
        view.addSubview(centerScreenCoverView)
        view.addSubview(leftScreen.view)
        view.addSubview(rightScreen.view)
        view.addSubview(bottomScreen.view)
        view.addSubview(topGradientView)
        view.addSubview(topBar_typed)
        view.addSubview(bottomGradientView)
        view.addSubview(navigationView)
        
        
        let topBarConstraints = topBar_typed.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor], constants: [.height: topBarHeight, .top: APP_INSETS.top])
        
        topBarTopContraint = topBarConstraints.top!
        topBarHeightConstraint = topBarConstraints.height!
        
        
        let leftScreenPins = leftScreen.view.pin(anchors: [.top: view.topAnchor, .bottom: view.bottomAnchor, .width: view.widthAnchor, .right: view.leftAnchor])
        leftScreenRightAnchor = leftScreenPins.right!
        
        
        centerScreen.view.pinAllSides(pinTo: self.view)
        centerScreenCoverView.pinAllSides(pinTo: self.view)
        
        
        let rightScreenPins = rightScreen.view.pin(anchors: [.top: view.topAnchor, .bottom: view.bottomAnchor, .width: view.widthAnchor, .left: view.rightAnchor])
        rightScreenLeftAnchor = rightScreenPins.left!
        
        
        let bottomScreenPins = bottomScreen.view.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.bottomAnchor], constants: [.height: self.view.frame.height - topBarHeight - view.safeAreaInsets.top])
        bottomScreenTopAnchor = bottomScreenPins.top!
        
        
        
        bottomGradientView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: navigationView.topAnchor, .bottom: view.bottomAnchor])
        
        
        topGradientView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor, .bottom: topBar_typed.bottomAnchor], constants: [.bottom: -30])
        
        
        navigationView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.safeAreaLayoutGuide.bottomAnchor], constants: [.height: 150])
        
        
        topBarBottomLine.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: topBar_typed.bottomAnchor], constants: [.height: 0.5])
        
    }
    
}



