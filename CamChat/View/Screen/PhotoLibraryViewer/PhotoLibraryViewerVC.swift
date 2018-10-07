//
//  PagerViewTester.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class PhotoLibraryViewerVC: SCPagerViewController{
    
    override var prefersStatusBarHidden: Bool{return true}

    
    
    private let itemArray: [Memory]
    private let beginningIndex: Int
    init(imageArray: [Memory], currentIndex: Int, presenter: PhotoLibraryViewerTransitioningPresenter){
      
        self.beginningIndex = currentIndex
        self.itemArray = imageArray
        super.init(desiredCurrentIndex: currentIndex)
          self.libraryViewerTransitioningDelegate = PhotoLibraryViewerTransitioningDelegate(presenter: presenter, presented: self)
        self.transitioningDelegate = libraryViewerTransitioningDelegate
        pagerView.interactor.onlyAcceptInteractionInSpecifiedDirection = true
    }
    
 
    private var libraryViewerTransitioningDelegate: PhotoLibraryViewerTransitioningDelegate!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (pagerView.currentCenterCell as! PagerView).currentVideoView?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (pagerView.currentCenterCell as! PagerView).currentVideoView?.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.clipsToBounds = true
    }
    
    
    
    override func pagerView(_ pagerView: SCPagerView, cellForItemAt index: Int, cachedView: UIView?) -> SCPagerViewCell {
        let viewToUse: PagerView
        
        if let cache = cachedView { viewToUse = cache as! PagerView }
        else { viewToUse = PagerView() }
        
        viewToUse.delegate = self
        viewToUse.setWith(memory: itemArray[index])
        return viewToUse
    }

    
  
    
    
    
    
    
    private func presentOptions(){
        self.present(PhotoOptionsVC(memory: self.itemArray[self.currentItemIndex], presenter: self, delegate: self), animated: true, completion: nil)
    }
    
    override func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int {
        return itemArray.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}






extension PhotoLibraryViewerVC: PagerViewDelegate{
    func sendButtonTapped() {
        
    }
    func viewLongPressed() {
        UIImpactFeedbackGenerator().impactOccurred()
        presentOptions()
    }
    func threeDotButtonTapped() {
        presentOptions()
    }
}



private protocol PagerViewDelegate: class {
    func sendButtonTapped()
    func viewLongPressed()
    func threeDotButtonTapped()
}




private class PagerView: SCPagerViewCell{
    
    required init() {
        super.init()
        setUpView()
    }
    
    weak var delegate: PagerViewDelegate?
    
    private func setUpView() {
        imageView.pinAllSides(addTo: self, pinTo: self)
        videoHolderView.pinAllSides(addTo: self, pinTo: self)
        longTapView.pinAllSides(addTo: self, pinTo: self)
        sendButton.pin(addTo: self, anchors: [.bottom: bottomAnchor, .right: rightAnchor], constants: [.height: 50, .width: 50, .right: 20, .bottom: Variations.homeIndicatorHeight + 20])
        threeDotButton.pin(addTo: self, anchors: [.right: rightAnchor, .top: topAnchor], constants: [.right: 15, .top: Variations.notchHeight + 15, .height: 40, .width: 24])
    }
    
    
    func setWith(memory: Memory){
        
        if let video = currentVideoView{
            video.removeFromSuperview()
            currentVideoView = nil
        }
        
        self.imageView.image = memory.info.image
        
        if case let .video(url, _) = memory.info{
            
            let newVideoPlayer = SimpleVideoPlayer(url: url)
            UIView.performWithoutAnimation {
                newVideoPlayer.pinAllSides(addTo: videoHolderView, pinTo: videoHolderView)
                self.layoutIfNeeded()
            }
            self.currentVideoView = newVideoPlayer
        }
    }
    
    
    override func willAppear() {
        
    }
    
    override func didAppear() {
        currentVideoView?.play()
    }
    
    override func willDisappear() {
        currentVideoView?.pause()
    }
    
    override func didDisappear() {
        currentVideoView?.pause()
        currentVideoView?.rewindToBeginning()
    }
    
    
    private(set) var currentVideoView: SimpleVideoPlayer?
    
    private lazy var longTapView: UIView = {
        let x = UIView()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPress(gesture:)))
        gesture.minimumPressDuration = 0.15
        x.addGestureRecognizer(gesture)
        return x
    }()
    
    private var videoHolderView: UIView = {
        let x = UIView()
        x.backgroundColor = .clear
        x.isUserInteractionEnabled = false
        return x
    }()
    
    @objc private func respondToLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{return}
        delegate?.viewLongPressed()
    }
    
    private lazy var threeDotButton: BouncyButton = {
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
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension PhotoLibraryViewerVC: PhotoLibraryViewerTransitioningPresented{
    
    
    
    var currentItemIndex: Int {
        return pagerView.currentItemIndex
    }
}

extension PhotoLibraryViewerVC: PhotoOptionMenuDelegate {
    
    func memoryWillBeDeleted() {
        self.transitioningDelegate = nil
        presentingViewController?.view.isUserInteractionEnabled = true
        self.dismiss()
    }
    
    
}
