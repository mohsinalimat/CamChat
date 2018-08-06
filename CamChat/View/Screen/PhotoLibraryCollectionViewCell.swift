//
//  PhotoLibraryCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class PhotoLibraryCollectionViewCell: UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        
        imageView.pinAllSides(addTo: self, pinTo: self)
        
    }
    
  
    
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
