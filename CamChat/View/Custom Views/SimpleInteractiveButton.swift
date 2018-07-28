//
//  SimpleInteractiveButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

class SimpleInteractiveButton: HKButtonTemplate{
    
    override func setUpView() {
        addSubview(label)
        addSubview(shadeView)
        label.pin(anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor])
        shadeView.pinAllSides(pinTo: self)
    }
    

    
    
    override func tapBegan() {
        shadeView.alpha = 0.2
    }
    
    override func tapEnded() {
        shadeView.alpha = 0
    }
    
    lazy var label: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.font = SCFonts.getFont(type: .demiBold, size: 26)
        return x
        
    }()
    
    private lazy var shadeView: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.black
        x.alpha = 0
        x.isUserInteractionEnabled = false
        return x
    }()
    
    

    
}



