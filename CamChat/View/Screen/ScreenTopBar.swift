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
        buttonTopBar.pinAllSides(addTo: self, pinTo: self)
        topSearchBar.pinAllSides(addTo: self, pinTo: self)
    }
    
    private let topSearchBar: CCSearchBar = {
        let x = CCSearchBar()
        x.isUserInteractionEnabled = false
        return x
    }()
    
    private lazy var buttonTopBar: ScreenButtonsTopBar = {
        let x = ScreenButtonsTopBar()
        return x
        
    }()
    
    
    func adaptTo(gradient: CGFloat, direction: ScrollingDirection){
        topSearchBar.changeGradientTo(gradient: gradient, direction: direction)
        buttonTopBar.changeIconPositionsAccordingTo(gradient: gradient, direction: direction)
    }
    
}





