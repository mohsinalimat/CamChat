//
//  BouncyButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/17/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit



class BouncyButton: HKButtonTemplate{


    private var image: UIImage?
    private var alternateImage: UIImage?

    /// The alternate image allows the api user to specify the second image the imageView will alternate between when the button is tapped.
    init(image: UIImage?, alternateImage: UIImage? = nil){
        self.image = image
        self.alternateImage = alternateImage
        super.init()
        imageView.image = image

        addSubview(imageView)
        imageView.pinAllSides(pinTo: self)
        tintColor = .white
    }




    override func tapBegan() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)

    }

    override func tapEnded() {

        if let altImage = self.alternateImage{
            imageView.image = (imageView.image == image) ? altImage : image
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, animations: {
            self.imageView.transform = CGAffineTransform.identity
        }, completion: nil)
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
