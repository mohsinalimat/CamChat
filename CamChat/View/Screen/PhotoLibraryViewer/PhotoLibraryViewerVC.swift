//
//  PagerViewTester.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class PhotoLibraryViewerVC: SCPagerViewController, PhotoLibraryViewerTransitioningPresented{
    
    var viewControllerForPhotoLibraryTransition: UIViewController{
        return self
    }
    
    var currentItemIndex: Int{
        return pagerView.currentItemIndex
    }
    
    
    

    private let imageArray: [UIImage]
    private let beginningIndex: Int
    init(imageArray: [UIImage], currentIndex: Int, presenter: PhotoLibraryViewerTransitioningPresenter){
      
        self.beginningIndex = currentIndex
        self.imageArray = imageArray
        super.init(nibName: nil, bundle: nil)
          self.libraryViewerTransitioningDelegate = PhotoLibraryViewerTransitioningDelegate(presenter: presenter, presented: self)
        self.transitioningDelegate = libraryViewerTransitioningDelegate
        pagerView.interactor.onlyAcceptInteractionInSpecifiedDirection = true
        
   
    }
    
 
    
    
    
    
    private var libraryViewerTransitioningDelegate: PhotoLibraryViewerTransitioningDelegate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagerView.setIndex(to: beginningIndex)
        
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
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}









private class PagerView: HKView{
    
    override func setUpView() {
        imageView.pinAllSides(addTo: self, pinTo: self)
        sendButton.pin(addTo: self, anchors: [.bottom: bottomAnchor, .right: rightAnchor], constants: [.height: 50, .width: 50, .right: 20, .bottom: APP_INSETS.bottom + 20])
    }
    
    private lazy var sendButton = SendButton()
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    
}
