//
//  SimpleLabelledButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class SimpleInteractiveButton: HKButtonTemplate{
    
    override init(){
        super.init()
        addSubview(shadeView)
        shadeView.pinAllSides(pinTo: self)
    }
    
    var maximumDimmingAlpha: CGFloat = 0.2
    
    override func tapBegan() {
        shadeView.alpha = maximumDimmingAlpha
    }
    
    override func tapEnded() {
        UIView.animate(withDuration: 0.3, animations: {self.shadeView.alpha = 0})
    }
    override func tapCancelled() {
        shadeView.alpha = 0
    }
    
    private lazy var shadeView: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.black
        x.alpha = 0
        x.isUserInteractionEnabled = false
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}

