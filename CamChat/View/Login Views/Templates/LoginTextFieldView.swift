//
//  LoginTextFieldView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class LoginTextFieldView: HKView{
    

    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: desiredWidth, height: desiredHeight)
    }
    
    private let desiredHeight: CGFloat = 50
    private let desiredWidth: CGFloat = 260
    
    private let sideInsets: CGFloat = 4
    
    
    
    override func setUpView(){
        
        
        backgroundColor = .white
        
        addLayoutGuide(layoutGuide)
        addSubview(descriptionLabel)
        addSubview(textField)
        addSubview(bottomLine)
        
        layoutGuide.pin(anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor], constants: [.height: desiredHeight, .width: desiredWidth])
        
        descriptionLabel.pin(anchors: [.left: layoutGuide.leftAnchor, .top: layoutGuide.topAnchor], constants: [.left: sideInsets])
        textField.pin(anchors: [.left: layoutGuide.leftAnchor, .bottom: bottomLine.topAnchor, .right: layoutGuide.rightAnchor], constants: [.left: sideInsets, .right: sideInsets, .bottom: 2])
        bottomLine.pin(anchors: [.left: leftAnchor, .right: rightAnchor, .bottom: bottomAnchor], constants: [.height: 1])
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToTap(gesture:)))
        addGestureRecognizer(gesture)
        
    }
    
    @objc private func respondToTap(gesture: UITapGestureRecognizer){
        if gesture.state == .recognized{
            textField.becomeFirstResponder()
        }
    }
    
    
    

    
    private var layoutGuide = UILayoutGuide()
    
    func setDescriptionText(to text: String){
        descriptionLabel.text = text.uppercased()
    }
    
    private var descriptionLabel: UILabel = {
        let x = UILabel()
        x.font = CCFonts.getFont(type: .demiBold, size: 11)
        x.textColor = UIColor(red: 160, green: 160, blue: 160)
        x.text = "NO DESCRIPTION PROVIDED"
        return x
    }()
    
    
    
    private(set)var textField: UITextField = {
        let x = UITextField()
        x.font = CCFonts.getFont(type: .medium, size: 17)
        x.autocorrectionType = .no
        x.spellCheckingType = .no
        x.autocapitalizationType = .none
        x.enablesReturnKeyAutomatically = true
        x.returnKeyType = .next
        return x
    }()
    
    private var bottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor(red: 215, green: 215, blue: 215)
        return x
    }()
    
 
}

