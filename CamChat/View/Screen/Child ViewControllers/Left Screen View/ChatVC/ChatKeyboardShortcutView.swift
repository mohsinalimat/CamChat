//
//  ChatKeyboardShortcutView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class ChatKeyboardShortcutView: HKView{
    private let user: User
    init(user: User){
        self.user = user
        super.init()
    }

    override func setUpView() {
        backgroundColor = .white
        
        addSubview(textView)
        addSubview(sendButton)
        addSubview(topLine)
        
        
        topLine.pin(anchors: [.left: leftAnchor, .right: rightAnchor, .top: topAnchor])
        
        let buttonInsets: CGFloat = 6
        let buttonHeight = textView.contentSize.height - buttonInsets.doubled
        sendButton.pin(anchors: [.right: rightAnchor, .bottom: bottomAnchor], constants: [.right: buttonInsets, .height: buttonHeight, .width: 50, .bottom: buttonInsets])
        
        textView.pin(anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: sendButton.leftAnchor], constants: [.right: buttonInsets])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextDidChange), name: UITextView.textDidChangeNotification, object: self.textView)
        
        
        
    }
    

    
   
    
    
    private let preferredMaximumHeight: CGFloat = 140
    
    
    private var preferredHeight: CGFloat{
        return min(textView.contentSize.height, preferredMaximumHeight)
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: UIView.noIntrinsicMetric, height: preferredHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sendButton.setCornerRadius(to: sendButton.frame.height.half)
    }
    
    private lazy var sendButton: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.label.text = "Send"
        x.label.font = SCFonts.getFont(type: .demiBold, size: 13)
        x.backgroundColor = BLUECOLOR
        x.label.textColor = .white
        x.transform = CGAffineTransform(scaleX: 0, y: 0)
        x.addAction({[unowned textView, unowned self] in
            let message = TempMessage(text: textView.text.withTrimmedWhiteSpaces(), dateSent: Date(), uniqueID: NSUUID().uuidString, senderID: DataCoordinator.currentUserUniqueID!, receiverID: self.user.uniqueID)
            try! DataCoordinator.send(message: message, sender: DataCoordinator.currentUser!, receiver: self.user)
            textView.text = ""
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: textView)
        })
        return x
    }()
    
    lazy var textView: ChatKeyboardShortutTextView = {
        let x = ChatKeyboardShortutTextView()
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
        
        adjustSendButton()
        
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
    
    private func adjustSendButton(){
        let action: () -> Void
        if textView.hasValidText{
            action = {
                if self.sendButton.transform != CGAffineTransform.identity{
                    self.sendButton.transform = CGAffineTransform.identity
                }
            }
        } else {
            action = {
                if self.sendButton.transform != CGAffineTransform(scaleX: 0, y: 0){
                    self.sendButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                }
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            action()
            self.layoutIfNeeded()
            self.sendButton.setCornerRadius(to: self.sendButton.bounds.height.half)
        }
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


















class ChatKeyboardShortutTextView: UITextView{
    
    init(){
        super.init(frame: CGRect.zero, textContainer: nil)
        returnKeyType = .default
        font = SCFonts.getFont(type: .medium, size: 17.5)
        tintColor = REDCOLOR
        textContainerInset.left = 4
        textContainerInset.right = 6
        setUpTextViewHint()
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextDidChange), name: UITextView.textDidChangeNotification, object: self)
        
    }
    
    @objc private func respondToTextDidChange(){
        placeholderLabel.isHidden = !text.isEmpty

    }
    
    
    private lazy var placeholderLabel = UILabel()
    
    private func setUpTextViewHint(){
        
        placeholderLabel.text = "Send a Chat"
        placeholderLabel.font = font
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: textContainerInset.left + 5, y: textContainerInset.top)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !text.isEmpty
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


