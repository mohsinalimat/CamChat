//
//  ChatKeyboardShortcutView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class ChatKeyboardShortcutView: HKView{
    
    
    
    override func setUpView() {
        backgroundColor = .red
        
        textView.pinAllSides(addTo: self, pinTo: self)
        topLine.pin(addTo: self, anchors: [.left: leftAnchor, .right: rightAnchor, .top: topAnchor])
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextDidChange), name: UITextView.textDidChangeNotification, object: self.textView)
        
        setUpTextViewHint()
    }
    
    private lazy var placeholderLabel = UILabel()
    
    private func setUpTextViewHint(){
        
        placeholderLabel.text = "Send a Chat"
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: textView.textContainerInset.left + 5, y: textView.textContainerInset.top)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
        
    }
    
    
    private let preferredMaximumHeight: CGFloat = 140
    
    
    private var preferredHeight: CGFloat{
        return min(textView.contentSize.height, preferredMaximumHeight)
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: UIView.noIntrinsicMetric, height: preferredHeight)
    }
    
    
    lazy var textView: UITextView = {
        let x = UITextView()
        x.returnKeyType = .send
        x.font = SCFonts.getFont(type: .medium, size: 17.5)
        x.tintColor = REDCOLOR
        x.textContainerInset.left = 4
        x.textContainerInset.right = 6
        return x
    }()
    
    
    
    private lazy var topLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.lightGray
        x.pin(constants: [.height: 0.3])
        return x
    }()
    
    
    private var previousTextViewSize: CGSize!
    
    @objc func respondToTextDidChange(){
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        guard let previousSize = previousTextViewSize else {
            previousTextViewSize = textView.contentSize
            return
        }
        if textView.contentSize.height != previousSize.height && textView.contentSize.height < self.preferredMaximumHeight{
            
            self.superview?.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
            self.superview?.layoutIfNeeded()
            self.textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            
        }
        previousTextViewSize = textView.contentSize
    }
}


