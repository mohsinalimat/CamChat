//
//  LoginButtonView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

class LoginButtonView: HKView{
    override func setUpView() {
        addSubview(gradientView)
        addSubview(button)
        
        
        gradientView.pinAllSides(pinTo: self)
       
        
        button.pin(anchors: [.top: topAnchor, .centerX: centerXAnchor], constants: [.height: 45, .width: 230])
        
        setButtonText(to: "No Text Specified")
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: UIView.noIntrinsicMetric, height: 65)
    }
    
    private let activeColor = BLUECOLOR
    private let inactiveColor = UIColor.lightGray
    
    
    private var action = {}
    
    func addAction(_ action: @escaping () -> Void){
        self.action = action
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    private var isEnabled: Bool{
        return button.isEnabled
    }
    
    
    func enable(){
        button.backgroundColor = activeColor
        button.isEnabled = true
    }
    
    func disable(){
        button.backgroundColor = inactiveColor
        button.isEnabled = false
    }
    
    func setButtonText(to text: String){
        
        button.label.attributedText = NSAttributedString(string: text, attributes: [.font: SCFonts.getFont(type: .demiBold, size: 17), .foregroundColor: UIColor.white])
    }
    
    private lazy var button: SimpleInteractiveButton = {
        let x = SimpleInteractiveButton()
        x.backgroundColor = activeColor
        x.layer.masksToBounds = true
        x.addAction(respondToButtonPressed)
        return x
    }()
    
    func carryOutAction(){
        respondToButtonPressed()
    }
    
    
    @objc private func respondToButtonPressed(){
        action()
    }
    
    private lazy var gradientView: HKGradientView = {
        let x = HKGradientView(colors: [UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(1)])
        return x
    }()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews{
            let convertedPoint = subview.convert(point, from: self)
            if subview !== gradientView && subview.point(inside: convertedPoint, with: event){
                return true
            }
        }
        return false
    }
}
