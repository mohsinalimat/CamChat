//
//  MemorySenderMessageCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class MemorySenderMessageCell: UITableViewCell{
    
    private var heightConstraint: NSLayoutConstraint!
    
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = 300
    
    init(){
        super.init(style: .default, reuseIdentifier: "yama")
        setCornerRadius(to: 7)
        backgroundColor = UIColor.gray(percentage: 70 / 255).withAlphaComponent(0.6)
        let constraint = heightAnchor.constraint(equalToConstant: minHeight)
        constraint.priority = UILayoutPriority(999)
        constraint.isActive = true
        heightConstraint = constraint
    
        selectionStyle = .none
        
        textView.pinAllSides(addTo: self, pinTo: self)
        
    }
    private lazy var previousHeight = minHeight
    private func respondToTextDidChange(){
        let desiredConstant = textView.contentSize.height
        let actualConstant = min(max(desiredConstant, minHeight), maxHeight)
        if heightConstraint.constant != actualConstant{
            heightConstraint.constant = actualConstant
            let tableView = (superview as? UITableView)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            
            if actualConstant < maxHeight{
                UIView.performWithoutAnimation {
                    textView.scrollToTop()
                }
            }
        }
        previousHeight = actualConstant
    }
    
    
    
    private(set) lazy var textView: UITextView = {
        let x = UITextView(frame: CGRect.zero)
        x.backgroundColor = .clear
        x.keyboardAppearance = .dark
        x.returnKeyType = .default
        x.font = CCFonts.getFont(type: .medium, size: 15)
        x.textColor = .white
        x.tintColor = BLUECOLOR
        x.textContainerInset = UIEdgeInsets(allInsets: 10)
        self.setUpTextViewHint(for: x)
        x.addTextDidChangeListener({[weak self] (newVal) in
            self?.placeholderLabel.isHidden = !x.text.isEmpty
            self?.respondToTextDidChange()
        })
        return x
    }()
    
    
    private lazy var placeholderLabel = UILabel()
    
    private func setUpTextViewHint(for textView: UITextView){
        placeholderLabel.text = "Type a Message"
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: textView.textContainerInset.left + 5, y: textView.textContainerInset.top)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = textView.text.isEmpty.isFalse
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
