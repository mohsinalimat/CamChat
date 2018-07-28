//
//  ScreenTopBar.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

class ScreenTopBar: UIView{
    
    
    init(){
        super.init(frame: CGRect.zero)
        addSubview(centerScreenIcons)
        addSubview(leftScreenIcon)
        addSubview(rightScreenIcon)
        
        
        [centerScreenIcons, leftScreenIcon, rightScreenIcon].forEach {
            $0.pin(anchors: [.right: rightAnchor, .centerY: centerYAnchor], constants: [.right: 15])
        }
        
        leftScreenIcon.transform = CGAffineTransform(translationX: -maxTransform, y: 0)
        rightScreenIcon.transform = CGAffineTransform(translationX: maxTransform, y: 0)
        leftScreenIcon.alpha = 0
        rightScreenIcon.alpha = 0
    }
    
    
    private let maxTransform: CGFloat = 40
    

    
    
    
    
    private let leftIconAlphaEquation = CGLinearEquation(xy(-1, 1), xy(-0.5, 0), min: 0, max: 1)
    private let middleIconAlphaEquation = CGQuadEquation(xy(-0.5, 0), xy(0, 1), c3: xy(0.5, 0), min: 0, max: 1)
    private let rightIconAlphaEquation = CGLinearEquation(xy(1, 1), xy(0.5, 0), min: 0, max: 1)
    
    
    private lazy var leftIconTransformEquation = CGLinearEquation(xy(-1, 0), xy(0, -maxTransform), min: -maxTransform, max: 0)
    private lazy var centerIconsTransformEquation = CGQuadEquation(xy(-1, maxTransform), xy(0, 0), c3: xy(1, -maxTransform), min: -maxTransform, max: maxTransform)
    private lazy var rightIconTransformEquation = CGLinearEquation(xy(1, 0), xy(0, maxTransform), min: 0, max: maxTransform)
    
    
    
    
    
    
    
    func changeIconPositionsAccordingTo(gradient: CGFloat, direction: ScrollingDirection){
        
        
        if direction == .vertical{
            centerScreenIcons.alpha = middleIconAlphaEquation.solve(for: gradient)
            return
        }
         let leftIconTransform = leftIconTransformEquation.solve(for: gradient)
        let centerIconsTranform = centerIconsTransformEquation.solve(for: gradient)
        let rightIconTranform = rightIconTransformEquation.solve(for: gradient)
        
        centerScreenIcons.transform = CGAffineTransform(translationX: centerIconsTranform, y: 0)
        leftScreenIcon.transform = CGAffineTransform(translationX: leftIconTransform, y: 0)
        rightScreenIcon.transform = CGAffineTransform(translationX: rightIconTranform, y: 0)
        
        centerScreenIcons.alpha = middleIconAlphaEquation.solve(for: gradient)
        leftScreenIcon.alpha = leftIconAlphaEquation.solve(for: gradient)
        rightScreenIcon.alpha = rightIconAlphaEquation.solve(for: gradient)
        
    }
    

    
    
    
    private lazy var rightScreenIcon = self.getImageView(for: AssetImages.selectItemsIcon)
    private lazy var leftScreenIcon = self.getImageView(for: AssetImages.newChatIcon)
    
    
    private lazy var centerScreenIcons: UIStackView = {
        let x = UIStackView(arrangedSubviews: [flashIcon, cameraFlipIcon] )
        x.axis = .horizontal
        x.spacing = 15
        return x
    }()
    
 
    
    private let preferredIconSize = CGSize(width: 30, height: 30)
    
    private lazy var flashIcon = self.getImageView(for: AssetImages.flashOnIcon, alternativeImage: AssetImages.flashOffIcon, applyLightShadow: true)
    
    private lazy var cameraFlipIcon = self.getImageView(for: AssetImages.cameraFlipIcon, applyLightShadow: true)
    
    
    
    
    
    private func getImageView(for image: UIImage, alternativeImage: UIImage? = nil, applyLightShadow: Bool = false) -> BouncyButton{
        let x = BouncyButton(image: image, alternateImage: alternativeImage)
        x.tintColor = .white
        
        x.pin(constants: [.width: preferredIconSize.width, .height: preferredIconSize.height])
        
        if applyLightShadow{
            x.applyShadow(width: 0.5)
        }
        return x
    }
    
    
   
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in [flashIcon, cameraFlipIcon, rightScreenIcon, leftScreenIcon]{
            let newPoint = subview.convert(point, from: self)
            if subview.point(inside: newPoint, with: event){
                if [flashIcon, cameraFlipIcon].contains(subview) && centerScreenIcons.alpha == 1{
                    return subview
                } else if [rightScreenIcon, leftScreenIcon].contains(subview) && centerScreenIcons.alpha != 1{
                    return subview
                }
            }
        }
        return nil
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
