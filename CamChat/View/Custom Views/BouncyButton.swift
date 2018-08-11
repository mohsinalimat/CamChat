//
//  BouncyButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData

class BouncyButton: HKButtonTemplate{
    
    
    override init(){
        super.init()
        contentView.pinAllSides(addTo: self, pinTo: self)
        
        activationArea = { [weak self] in
        
            let height = max(self!.bounds.height, 60)
            let width = max(self!.bounds.width, 60)
            
            return CGRect(center: self!.centerInBounds, width: height, height: width)
        }
    }
    
    
    
    
    let contentView = UIView()
    
    override func tapBegan() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
        
    }
    
    override func tapEnded() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, animations: {
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
        
        
    }
    
}
