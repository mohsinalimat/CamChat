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
        
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touches began")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("touches ended")
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
