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
        imageViewPins = imageView.pinAllSides(addTo: contentView, pinTo: contentView)
        
    }
    
    private var imageViewPins: Pins!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let val = (max(bounds.height, bounds.width) * 0.2)
        
        imageViewPins.left!.constant = val
        imageViewPins.top!.constant = val
        imageViewPins.right!.constant = -val
        imageViewPins.bottom!.constant = -val
        
        imageView.transform = CGAffineTransform(translationX: bounds.width * 0.05, y: 0)
    }
    
    func setColorsInverted() {
        self.imageView.tintColor = BLUECOLOR
        circleView.backgroundColor = .white
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
