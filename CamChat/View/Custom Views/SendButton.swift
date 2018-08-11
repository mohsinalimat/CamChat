//
//  SendButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class SendButton: BouncyButton{
    
    override init() {
        super.init()
        
        circleView.pinAllSides(addTo: contentView, pinTo: contentView)
        imageView.pinAllSides(addTo: contentView, pinTo: contentView, insets: UIEdgeInsets(allInsets: 12))
        
    }
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: AssetImages.sendIcon)
        x.contentMode = .scaleAspectFit
        x.tintColor = .white
        return x
    }()
    
    private lazy var circleView: HKCircleView = {
        let x = HKCircleView()
        x.backgroundColor = BLUECOLOR
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
