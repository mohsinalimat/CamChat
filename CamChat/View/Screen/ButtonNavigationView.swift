//
//  ButtonNavigationView.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

fileprivate typealias ButtonType = ButtonNavigationView.ButtonType


func getGradientValue(minVal: CGFloat, maxVal: CGFloat, percentage: CGFloat) -> CGFloat{
    
    return minVal + ((maxVal - minVal) * abs(percentage))
    
}

class ButtonNavigationView: UIView{
    
    init(){
        super.init(frame: CGRect.zero)

        
        
        addSubview(cameraButton)
        addSubview(photoButton)
        addSubview(chatButton)
        addSubview(settingsButton)
        
        chatButton.pin(anchors: [.bottom: bottomAnchor, .centerX: leftAnchor], constants: [.width: beginningIconSize, .height: beginningIconSize, .bottom: bottomIconInset, .centerX: beginningIconSideInset])
        
        
        cameraButton.pin(anchors: [.centerX: centerXAnchor, .centerY: bottomAnchor], constants: [.width: beginningBigCircleSize, .height: beginningBigCircleSize, .centerY: -beginningBigCircleBottomInset])
        
        
        photoButton.pin(anchors: [.bottom: bottomAnchor, .centerX: rightAnchor], constants: [.width: beginningIconSize, .height: beginningIconSize, .bottom: bottomIconInset, .centerX: -beginningIconSideInset])
        
        
        
        settingsButton.pin(anchors: [.top: cameraButton.bottomAnchor, .centerX: cameraButton.centerXAnchor], constants: [.width: 30, .height: 30, .top: 20])
        

        

        
    }
    
    func setButtonBackingAlphas (to alpha: CGFloat){
        [cameraButton, chatButton, photoButton].forEach{$0.iconBacking.alpha = alpha}
    }
    
    func setButtonShadowAlphas(to alpha: CGFloat){
        [cameraButton, chatButton, photoButton].forEach{$0.layer.shadowOpacity = Float(alpha)}
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    enum ButtonType{
        case chat
        case cameraCapture
        case photoLibrary
        case settings
        
        fileprivate var image: UIImage!{
            switch self {
            case .cameraCapture: return nil
            case .chat: return AssetImages.chatBubble
            case .photoLibrary: return AssetImages.photoIcon
            case .settings: return AssetImages.settingsIcon
            }
        }
        
    }
    
    
    
    func setButtonActions(to action: @escaping (ButtonType) -> Void){
        
        [photoButton, cameraButton, chatButton, settingsButton].forEach { $0.setAction(action: action) }
    }
    

    
    
    
    
    
    // CONSTANTS TO CONFIGURE BEGINNING AND ENDING POSITIONS
    
    private let beginningIconSideInset: CGFloat = 30
    private let endingIconInsetFromCenter: CGFloat = 75
    private var endingSideInset: CGFloat {
        self.layoutIfNeeded()
        let centerX = self.centerInBounds.x
        return centerX - endingIconInsetFromCenter
    }
    private var bottomIconInset: CGFloat{
        return beginningIconSideInset - (beginningIconSize / 2)
    }
    
    
    private let beginningIconSize: CGFloat = 35
    private let endingIconSize: CGFloat = 25
    
    
    private let beginningBigCircleBottomInset: CGFloat = 100
    private var endingBigCircleBottomInset: CGFloat{
        return (bottomIconInset + (endingBigCircleSize / 2)) + 10
    }
    
    
    private let beginningBigCircleSize: CGFloat = 75
    private let endingBigCircleSize: CGFloat = 50
    
    
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        [chatButton, cameraButton, photoButton].forEach{$0.tintColor = tintColor}
    }
    
    
    func getGradientValue(minVal: CGFloat, maxVal: CGFloat, percentage: CGFloat) -> CGFloat{
        
        return minVal + ((maxVal - minVal) * abs(percentage))
        
    }
    
    
    
    
    func changeObjectPositionsBy(gradient: CGFloat){
        let percentage = abs(gradient)
        let endingIconSizeScale = endingIconSize / beginningIconSize
        let endingCircleSizeScale = endingBigCircleSize / beginningBigCircleSize
        
        let sideInsetDifference = endingSideInset - beginningIconSideInset
        let circleInsetDifference = beginningBigCircleBottomInset - endingBigCircleBottomInset
        

        let iconSizeScale = getGradientValue(minVal: 1 , maxVal: endingIconSizeScale, percentage: percentage)
        let circleSizeScale = getGradientValue(minVal: 1, maxVal: endingCircleSizeScale, percentage: percentage)
        let iconTranslation = getGradientValue(minVal: 0, maxVal: sideInsetDifference, percentage: percentage)
        let circleTranslation = getGradientValue(minVal: 0, maxVal: circleInsetDifference, percentage: percentage)
        
        let settingsRotation = getGradientValue(minVal: 0, maxVal: 5 * CGFloat.pi, percentage: percentage)

        chatButton.transform = CGAffineTransform(translationX: iconTranslation, y: 0).scaledBy(x: iconSizeScale, y: iconSizeScale)
        
        cameraButton.transform = CGAffineTransform(scaleX: circleSizeScale, y: circleSizeScale)
            .concatenating(CGAffineTransform(translationX: 0, y: circleTranslation))
        layoutIfNeeded()
        
        photoButton.transform = CGAffineTransform(scaleX: iconSizeScale, y: iconSizeScale)
            .concatenating(CGAffineTransform(translationX: -iconTranslation, y: 0))
        
        settingsButton.transform = CGAffineTransform(translationX: 0, y: circleTranslation)
        settingsButton.imageView.transform = CGAffineTransform(rotationAngle: settingsRotation)
        settingsButton.alpha = 1 - percentage
        
    }
    
   

    
    
    
    private lazy var settingsButton: SCNavigationButton = {
        let x = SCNavigationButton.init(type: .settings)
        return x
    }()
    
    private lazy var photoButton: SCNavigationButton = {
        let x = SCNavigationButton(type: .photoLibrary)
        return x
    }()
    private lazy var chatButton: SCNavigationButton = {
        let x = SCNavigationButton(type: .chat)
        return x
    }()
    
    private lazy var cameraButton: SCNavigationButton = {
        let x = CameraCaptureButton()
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    


    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.point(inside: subview.convert(point, from: self), with: event) {
                return true
            }
        }
        return false
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}

























fileprivate class CameraCaptureButton: SCNavigationButton{
    
    init(){
        super.init(type: .cameraCapture)
        layer.addSublayer(circleLayer)
    }
    private let circleLayer = CAShapeLayer()
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        circleLayer.strokeColor = tintColor.cgColor
    }
    
    override var iconBacking: UIView{
        return _iconBacking
    }
    
  
    private lazy var _iconBacking: UIView = {
        let x = CircleView()
        x.backgroundColor = .white
        return x
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        
        circleLayer.frame = self.bounds
        let radius = (self.frame.width / 2) - 3
        let path = UIBezierPath(arcCenter: self.centerInBounds, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 6
        circleLayer.strokeColor = UIColor.white.cgColor
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}




fileprivate class SCNavigationButton: BouncyButton{
    
    private let type: ButtonType
    init(type: ButtonType){
        self.type = type
        super.init(image: type.image)
        
        
        
        iconBacking.alpha = 0
        addSubview(iconBacking)
        sendSubviewToBack(iconBacking)
        tintColor = .white
        iconBacking.pinAllSides(pinTo: self, insets: UIEdgeInsets(allInsets: -5))
        applyShadow(width: 0.5)
        
        
    }
    

    
    
   
    
    
    
    
    
    
  
    
    
    
    private(set) lazy var iconBacking: UIView = {
        let x = UIView()
        
        x.backgroundColor = .white
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        return x
    }()
    
    
    
    
    
    
    
    func setAction(action: @escaping (ButtonType) -> Void){
        addAction { action(self.type) }
    }
 
    
    

    
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}










