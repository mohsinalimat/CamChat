//
//  ScreenTopBar.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit


protocol ScreenButtonsTopBarDelegate: class{
    func newChatButtonTapped()
    func flashButtonTapped(to isOn: Bool)
    func cameraFlipButtonTapped()
    func photoLibrarySelectButtonTapped()
}


class ScreenButtonsTopBar: UIView{
    
    private weak var delegate: ScreenButtonsTopBarDelegate?
    init(delegate: ScreenButtonsTopBarDelegate){
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        addSubview(centerScreenIcons)
        addSubview(leftScreenIcon)
        addSubview(rightScreenIcon)
        
        
        [centerScreenIcons, leftScreenIcon, rightScreenIcon].forEach {
            $0.pin(anchors: [.right: rightAnchor, .centerY: centerYAnchor], constants: [.right: 15])
        }
        
        leftScreenIcon.transform = CGAffineTransform(translationX: -maxLeftAndRightTransform, y: 0)
        rightScreenIcon.transform = CGAffineTransform(translationX: maxLeftAndRightTransform, y: 0)
        leftScreenIcon.alpha = 0
        rightScreenIcon.alpha = 0
        
        setCustomActivationAreaForCenterIcons()
        
        leftScreenIcon.addAction({[weak self] in self?.delegate?.newChatButtonTapped()})
        flashIcon.addAction { [weak self, weak flashIcon] in
            guard let flashIcon = flashIcon else {return}
            self?.delegate?.flashButtonTapped(to: flashIcon.currentImageType == .alternative)
        }
        cameraFlipIcon.addAction({[weak self] in self?.delegate?.cameraFlipButtonTapped()})
        rightScreenIcon.addAction({[weak self] in self?.delegate?.photoLibrarySelectButtonTapped()})
        
    }
    
    private func setCustomActivationAreaForCenterIcons(){
        self.layoutIfNeeded()
        
        let val: CGFloat = -10
        flashIcon.activationArea = {[weak self] in
            let centerButtonSpacing = self!.cameraFlipIcon.leftSide - self!.flashIcon.rightSide
            return self!.flashIcon.bounds.inset(by: UIEdgeInsets(top: val, left: val, bottom: val, right: -centerButtonSpacing.half))
        }
        cameraFlipIcon.activationArea = {[weak self] in
            let centerButtonSpacing = self!.cameraFlipIcon.leftSide - self!.flashIcon.rightSide
            return self!.cameraFlipIcon.bounds.inset(by: UIEdgeInsets(top: val, left: -centerButtonSpacing.half, bottom: val, right: val))
        }
        
    }
    
    
    private let maxLeftAndRightTransform: CGFloat = 40
    

    
    
    
    
    private let leftIconAlphaEquation = CGLinearEquation(xy(-1, 1), xy(-0.5, 0), min: 0, max: 1)!
    private let middleIconAlphaEquation = CGQuadEquation(xy(-0.5, 0), xy(0, 1), xy(0.5, 0), min: 0, max: 1)!
    private let rightIconAlphaEquation = CGLinearEquation(xy(1, 1), xy(0.5, 0), min: 0, max: 1)!
    
    
    private lazy var leftIconTransformEquation = CGLinearEquation(xy(-1, 0), xy(0, -maxLeftAndRightTransform), min: -maxLeftAndRightTransform, max: 0)!
    private lazy var centerIconsTransformEquation = CGQuadEquation(xy(-1, maxLeftAndRightTransform), xy(0, 0), xy(1, -maxLeftAndRightTransform), min: -maxLeftAndRightTransform, max: maxLeftAndRightTransform)!
    private lazy var rightIconTransformEquation = CGLinearEquation(xy(1, 0), xy(0, maxLeftAndRightTransform), min: 0, max: maxLeftAndRightTransform)!
    
    
    
    
    
    
    
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
    
    lazy var rightScreenIcon = self.getImageView(for: AssetImages.selectItemsIcon)
    private lazy var leftScreenIcon = self.getImageView(for: AssetImages.newChatIcon)
    
    
    lazy var centerScreenIcons: UIStackView = {
        let x = UIStackView(arrangedSubviews: [flashIcon, cameraFlipIcon] )
        x.axis = .horizontal
        x.spacing = 15
        return x
    }()
    
 
    
    private let preferredIconSize = CGSize(width: 30, height: 30)
    
    lazy var flashIcon = self.getImageView(for: AssetImages.flashOffIcon, alternativeImage: AssetImages.flashOnIcon, applyLightShadow: true)
    
    lazy var cameraFlipIcon = self.getImageView(for: AssetImages.cameraFlipIcon, applyLightShadow: true)
    
    
    
    
    
    private func getImageView(for image: UIImage, alternativeImage: UIImage? = nil, applyLightShadow: Bool = false) -> BouncyImageButton{
        let x = BouncyImageButton(image: image, alternateImage: alternativeImage)
        x.tintColor = .white
        
        x.pin(constants: [.width: preferredIconSize.width, .height: preferredIconSize.height])
        
        if applyLightShadow{
            x.applyShadow(width: 0.5)
        }
        return x
    }
    
    
   
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        
        var activeButtons = [BouncyImageButton]()
        
        if centerScreenIcons.alpha == 1{activeButtons = [flashIcon, cameraFlipIcon]}
        else if leftScreenIcon.alpha == 1 {activeButtons = [leftScreenIcon]}
        else if rightScreenIcon.alpha == 1 {activeButtons = [rightScreenIcon]}
        
        
        for subview in activeButtons{
            let newPoint = subview.convert(point, from: self)
            if let view = subview.hitTest(newPoint, with: event){return view}
        }
        return nil
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
