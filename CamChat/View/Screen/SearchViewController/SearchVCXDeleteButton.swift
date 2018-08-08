//
//  SearchVCXDeleteButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class SearchVCXDeleteButton: UIView{
    init(){
        super.init(frame: CGRect.zero)
        
        [dismissButton, cancelButton].forEach{$0.pin(addTo: self, anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor])}
        
        cancelButton.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    func showDismissButton(){
        UIView.animate(withDuration: 0.2) {
            self.dismissButton.transform = CGAffineTransform.identity
            self.cancelButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
    }
    
    func showCancelButton(){
        UIView.animate(withDuration: 0.2) {
            self.dismissButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.cancelButton.transform = CGAffineTransform.identity

        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if dismissButton.transform == CGAffineTransform.identity{return dismissButton.hitTest( point, with: event)}
        else {return cancelButton.hitTest(point, with: event)}
        
    }
    
    lazy var dismissButton: BouncyButton = {
        let x = BouncyButton(image: AssetImages.xIcon)
        x.pin(constants: [.height: 25, .width: 25])
        return x
    }()
    
    lazy var cancelButton: BouncyButton = {
        let x = BouncyButton(image: AssetImages.cancelButton)
        x.pin(constants: [.height: 20, .width: 20])
        return x
    }()
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
