//
//  BouncyButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/17/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit



class BouncyImageButton: BouncyButton{
    
    enum ImageType{case initial, alternative}
    
    private var image: UIImage?
    private var alternateImage: UIImage?
    
    var currentImageType: ImageType{
        return imageView.image == image ? .initial : .alternative
    }
    
    /// The alternate image allows the api user to specify the second image the imageView will alternate between when the button is tapped.
    init(image: UIImage?, alternateImage: UIImage? = nil){
        
        self.image = image
        self.alternateImage = alternateImage
        super.init()
        imageView.image = image

        imageView.pinAllSides(addTo: contentView, pinTo: contentView)
        tintColor = .white
    }

    
    override func tapEnded() {
        if let altImage = self.alternateImage{
            imageView.image = (imageView.image == image) ? altImage : image
        }
        super.tapEnded()
    }



    override func tintColorDidChange() {
        super.tintColorDidChange()
        imageView.tintColor = tintColor
    }

    private(set) lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFit
        x.isUserInteractionEnabled = false
        return x
    }()



    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
