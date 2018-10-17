//
//  CCListViewBackgroundView.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CCListViewBackgroundView: UIView {

    
    init(labelText: String, buttonColor: UIColor, buttonText: String, buttonAction: @escaping () -> Void){
        super.init(frame: CGRect.zero)
        
        label.text = labelText
        button.addAction(buttonAction)
        button.backgroundColor = buttonColor
        button.label.text = buttonText
        
        label.pin(addTo: self, anchors: [.centerX: centerXAnchor, .top: topAnchor, .width: widthAnchor])
        button.pin(addTo: self, anchors: [.top: label.bottomAnchor, .centerX: centerXAnchor], constants: [.top: 20])
        self.pin(anchors: [.bottom: button.bottomAnchor], constants: [.width: UIScreen.main.bounds.width])
    }
    
    
    private(set) lazy var label: UILabel = {
        let x = UILabel(text: "NO TEXT HAS BEEN SPECIFIED", font: CCFonts.getFont(type: .medium, size: 17), textColor: UIColor.gray(percentage: 0.4))
        x.numberOfLines = 0
        x.textAlignment = .center
        return x
    }()
    
    private lazy var button: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.label.text = "NO TEXT SPECIFIED"
        x.backgroundColor = BLUECOLOR
        x.label.font = CCFonts.getFont(type: .medium, size: 16)
        x.pin(anchors: [.width: x.label.widthAnchor], constants: [.height: 44, .width: 60])
        return x
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.setCornerRadius(to: button.frame.height.half)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
