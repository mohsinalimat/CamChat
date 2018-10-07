//
//  MemorySenderBottomBar.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class MemorySenderBottomBar: UIView{
    
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = BLUECOLOR
        sendButton.pin(addTo: self, anchors: [.right: rightAnchor, .centerY: centerYAnchor], constants: [.height: 40, .width: 40, .right: 15])
        senderScrollView.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: sendButton.leftAnchor])
        bringSubviewToFront(sendButton)
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setScrollViewContentSize()
    }
    
    func setWith(users: [User]){
        longLabel.text = users.map{$0.firstName}.joined(separator: ", ")
        setScrollViewContentSize()
    }
    
    private func setScrollViewContentSize(){
        senderScrollView.contentSize = CGSize(width: longLabel.intrinsicContentSize.width, height: senderScrollView.frame.height)
        if (senderScrollView.contentSize.width + senderScrollView.adjustedContentInset.left + senderScrollView.adjustedContentInset.right) > senderScrollView.frame.width{
            let desiredOffset = senderScrollView.frame.width - senderScrollView.adjustedContentInset.right - senderScrollView.contentSize.width
            let newOffset = CGPoint(x: -desiredOffset, y: senderScrollView.contentOffset.y)
            UIView.animate(withDuration: 0.2) {
                self.senderScrollView.contentOffset = newOffset
            }
        }
    }
    
    
    
    private lazy var senderScrollView: HKScrollView = {
        let x = HKScrollView()
        x.contentInset.left = 15
        x.contentInset.right = 15
        longLabel.pin(addTo: x, anchors: [.left: x.contentLayoutGuide.leftAnchor, .centerY: x.contentLayoutGuide.centerYAnchor])
        x.showsHorizontalScrollIndicator = false
        
        let gradient = HKGradientView(colors: [BLUECOLOR.withAlphaComponent(0), BLUECOLOR])
        gradient.gradientLayer.transform = CATransform3DRotate(gradient.gradientLayer.transform, (CGFloat.pi * 2) * 0.75, 0, 0, 1)
        
        gradient.pin(addTo: x, anchors: [.right: x.frameLayoutGuide.rightAnchor, .top: x.frameLayoutGuide.topAnchor, .bottom: x.frameLayoutGuide.bottomAnchor], constants: [.width: 20])
        
        return x
    }()
    
    
    private lazy var sendButton: SendButton = {
        let x = SendButton()
        x.setColorsInverted()
        return x
    }()
    
    private lazy var longLabel: UILabel = {
        let x = UILabel(font: SCFonts.getFont(type: .demiBold, size: 16), textColor: .white)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
