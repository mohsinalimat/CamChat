//
//  CCSearchBarIcon.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class BouncySearchIcon: UIView{
    init(){
        super.init(frame: CGRect.zero)
        imageView.pinAllSides(addTo: self, pinTo: self)
    }
    
    func bounce(){
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
    
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: AssetImages.magnifyingGlass)
        x.tintColor = CCSearchConstants.searchTintColor
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
