//
//  PhotoSelectionBars.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class PhotoSelectionTopBar: UIView{
    
    init(exitButtonTappedAction: @escaping () -> Void){
        super.init(frame: CGRect.zero)
        label.pin(addTo: self, anchors: [.centerY: centerYAnchor, .centerX: centerXAnchor])
        exitSelectionButton.pin(addTo: self, anchors: [.left: leftAnchor, .centerY: centerYAnchor], constants: [.left: 15])
        exitSelectionButton.addAction(exitButtonTappedAction)
    }
    
    private lazy var label: UILabel = {
        let x = UILabel.init(text: "Select...", font: CCFonts.getFont(type: .demiBold, size: 22), textColor: .white)
        
        return x
    }()
    
    private lazy var exitSelectionButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.xIcon)
        x.pin(constants: [.height: 25, .width: 25])
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}









class PhotoSelectionBottomBar: UIView{
    
    init(){
        super.init(frame: CGRect.zero)
        
        stackView.pin(addTo: self, anchors: [.left: leftAnchor, .centerY: centerYAnchor], constants: [.left: 10])
        
        
        let buttons = [trashButton, cameraRollButton, shareButton, sendButton]
        self.buttons = buttons
        buttons.forEach{ (button) in
            let activationArea = { [weak button] in
                return button!.bounds.inset(by: UIEdgeInsets(allInsets: -10))
            }
            button.activationArea = activationArea
        }
        sendButton.pin(addTo: self, anchors: [.right: rightAnchor, .centerY: centerYAnchor, .width: heightAnchor], constants: [.right: 5, .height: 30])
        
        for button in buttons.firstItems(3){
            stackView.addArrangedSubview(button)
            button.pin(constants: [.height: 23, .width: 23])
        }
        buttons.forEach{$0.transform = CGAffineTransform(rotationAngle: CGFloat.pi)}
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            buttons.forEach{ $0.transform = CGAffineTransform.identity }
        }, completion: nil)
    }

    
    private(set) var buttons = [BouncyImageButton]()
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isUserInteractionEnabled.isTrue && isHidden.isFalse && alpha > 0{
            for button in buttons {
                let convertedPoint = button.convert(point, from: self)
                if let view = button.hitTest(convertedPoint, with: event){ return view }
            }
        }
        return nil
    }
    
    let trashButton = BouncyImageButton(image: AssetImages.trashIcon)
    let cameraRollButton = BouncyImageButton(image: AssetImages.downloadIcon)
    let shareButton = BouncyImageButton(image: AssetImages.shareIcon)
    let sendButton = BouncyImageButton(image: AssetImages.sendIcon)
    
    private lazy var stackView: UIStackView = {
        let x = UIStackView()
        x.axis = .horizontal
        x.spacing = 25
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


