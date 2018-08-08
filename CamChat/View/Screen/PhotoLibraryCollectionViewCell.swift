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
    
    func pushViewIn(){
    
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    func pushViewOut(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform.identity
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pushViewIn()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pushViewOut()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pushViewOut()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
