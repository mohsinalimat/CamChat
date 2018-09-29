//
//  SimpleInteractiveButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

class SimpleLabelledButton: SimpleInteractiveButton{
    
    
    
    override init(){
        super.init()
        addSubview(label)
        label.pin(anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor])
        sendSubviewToBack(label)
    }

    lazy var label: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.font = SCFonts.getFont(type: .demiBold, size: 26)
        return x
        
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}



