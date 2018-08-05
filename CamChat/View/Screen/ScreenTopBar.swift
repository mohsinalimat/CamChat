//
//  ScreenTopBar.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/29/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ScreenTopBar: HKView{
    
    override func setUpView() {
        topSearchBar.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: centerXAnchor])
        buttonTopBar.pin(addTo: self, anchors: [.left: topSearchBar.rightAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: rightAnchor])
    }
    
    let topSearchBar: CCSearchBar = {
        let x = CCSearchBar()
        return x
    }()
    
    lazy var buttonTopBar: ScreenButtonsTopBar = {
        let x = ScreenButtonsTopBar()
        return x
        
    }()
    
    
    func adaptTo(gradient: CGFloat, direction: ScrollingDirection){
        topSearchBar.changeGradientTo(gradient: gradient, direction: direction)
        buttonTopBar.changeIconPositionsAccordingTo(gradient: gradient, direction: direction)
    }
    
}





