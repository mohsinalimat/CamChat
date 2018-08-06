//
//  PagerViewTester.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class PagerViewTester: SCPagerViewController{
    
    
    private let imageArray: [UIImage] = {
        var images = [UIImage]()
        for i in 0...4{
            images.append(UIImage(named: "iphoneImage\(i)")!)
        }
        
        var imagesToReturn = [UIImage]()
        for i in 1...10{
            imagesToReturn.append(images.randomElement()!)
        }
        
        return imagesToReturn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func pagerView(_ pagerView: SCPagerView, viewForItemAt index: Int, cachedView: UIView?) -> UIView {
        let viewToUse: PagerView
        
        if let cache = cachedView{viewToUse = cache as! PagerView}
        else {viewToUse = PagerView()}
        
        viewToUse.imageView.image = imageArray[index]
        
        return viewToUse
    }
    
    override func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int {
        return imageArray.count
    }
    
    
    
}


private class PagerView: HKView{
    
    override func setUpView() {
        imageView.pinAllSides(addTo: self, pinTo: self)
    }
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    
}



