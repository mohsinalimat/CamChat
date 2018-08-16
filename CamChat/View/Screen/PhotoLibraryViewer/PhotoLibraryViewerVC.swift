//
//  PagerViewTester.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class PhotoLibraryViewerVC: SCPagerViewController, PagerViewDelegate{
    
    
    
    
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
        view.clipsToBounds = true
        
    }
    
    
    
    

    
    override func pagerView(_ pagerView: SCPagerView, viewForItemAt index: Int, cachedView: UIView?) -> UIView {
        let viewToUse: PagerView
        
        if let cache = cachedView { viewToUse = cache as! PagerView }
        else { viewToUse = PagerView() }
        
        viewToUse.delegate = self
        viewToUse.imageView.image = imageArray[index]
        return viewToUse
    }
    
    
    func sendButtonTapped() {
        
    }
    
    func viewLongPressed() {
        presentOptions()
    }
    
    private func presentOptions(){
        self.present(PhotoOptionsVC(image: self.imageArray[self.currentItemIndex], presenter: self), animated: true, completion: nil)
    }
    
    func threeDotButtonTapped() {
        presentOptions()
    }
    
    
    
    override func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int {
        return imageArray.count
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}



private protocol PagerViewDelegate: class {
    func sendButtonTapped()
    func viewLongPressed()
    func threeDotButtonTapped()
}




private class PagerView: HKView{
    
    weak var delegate: PagerViewDelegate?
    
    override func setUpView() {
        imageView.pinAllSides(addTo: self, pinTo: self)
        longTapView.pinAllSides(addTo: self, pinTo: self)
        sendButton.pin(addTo: self, anchors: [.bottom: bottomAnchor, .right: rightAnchor], constants: [.height: 50, .width: 50, .right: 20, .bottom: Variations.homeIndicatorHeight + 20])
        threeDotButton.pin(addTo: self, anchors: [.right: rightAnchor, .top: topAnchor], constants: [.right: 15, .top: Variations.notchHeight + 15, .height: 40, .width: 24])
    }
    
    private lazy var longTapView: UIView = {
        let x = UIView()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPress(gesture:)))
        gesture.minimumPressDuration = 0.2
        x.addGestureRecognizer(gesture)
        return x
    }()
    
    @objc private func respondToLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{return}
        delegate?.viewLongPressed()
    }
    
    lazy var threeDotButton: BouncyButton = {
        let x = BouncyImageButton(image: AssetImages.threeDotMoreIcon.rotatedBy(.clockwise90)!.templateImage)
        x.addAction({ [weak self] in self?.delegate?.threeDotButtonTapped() })
        x.applyShadow(width: 5)
        return x
    }()
    
    private lazy var sendButton: SendButton = {
        let x = SendButton()
        x.addAction({[weak self] in self?.delegate?.sendButtonTapped()})
        return x
    }()
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
}


extension PhotoLibraryViewerVC: PhotoLibraryViewerTransitioningPresented{
    
    
    
    var currentItemIndex: Int {
        return pagerView.currentItemIndex
    }
}
