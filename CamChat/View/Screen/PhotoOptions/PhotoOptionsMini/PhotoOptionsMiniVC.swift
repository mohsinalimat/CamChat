//
//  PhotoOptionsMiniVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/19/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



extension CGRect{
    
    fileprivate func translationToFitInside(rect: CGRect) -> CGPoint{
        var translation = CGPoint.zero
        translation.x += max(rect.minX - minX, 0)
        translation.x += min(-(maxX - rect.maxX), 0)
        translation.y += max(rect.minY - minY, 0)
        translation.y += min(-(maxY - rect.maxY), 0)
        return translation
    }
}




protocol PhotoOptionsMiniPresenter: HKVCTransEventAwareParticipator{
    func getSnapshotInfo() -> (snapshot: UIView, cornerRadius: CGFloat, currentFrame: CGRect, currentTransform: CGAffineTransform, endingFrame: CGRect)
}



class PhotoOptionsMiniVC: UIViewController {
    
    override var prefersStatusBarHidden: Bool{return true}
    
 

    private weak var presenter: PhotoOptionsMiniPresenter!
    private let snapshotInfo: (snapshot: UIView, cornerRadius: CGFloat, currentFrame: CGRect, currentTransform: CGAffineTransform, endingFrame: CGRect)
    private var snapshot: UIView{
        return snapshotInfo.snapshot
    }
    
    init(presenter: PhotoOptionsMiniPresenter){
        UISelectionFeedbackGenerator().selectionChanged()
        self.presenter = presenter
        
        snapshotInfo = presenter.getSnapshotInfo()
        super.init(nibName: nil, bundle: nil)
        
        customTransitioningDelegate = PhotoOptionsMiniTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = customTransitioningDelegate
        
        tapActivationAreaView.pinAllSides(addTo: view, pinTo: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPositionVars()

    }
    
    
    
    @objc private func respondToTap(gesture: UITapGestureRecognizer){
        if gesture.state != .ended{return}
        self.dismiss(animated: true)
    }
    
    private lazy var tapActivationAreaView: UIView = {
        let x = UIView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToTap(gesture:)))
        x.addGestureRecognizer(gesture)
        return x
    }()
    
    
    private var customTransitioningDelegate: PhotoOptionsMiniTransitioningDelegate!
    

    private let menuSize = CGSize(width: 250, height: 150)
    private let menu_imageSpacing: CGFloat = 20
    private let viewPadding: CGFloat = 20
    
    private var menu_ImageHeight: CGFloat{
        return menuSize.height + menu_imageSpacing + snapshotInfo.endingFrame.height
    }
    
    
    
    private var endingObjectsTranslation: CGAffineTransform!
    private var menuShouldBePinnedToLeftOfImage: Bool!
    private var menuShouldBeOnTop: Bool!
    private var endingSnapshotFrame: CGRect!

    
    
    private func setUpPositionVars(){
        
        let phoneInsets = UIEdgeInsets(hktop: Variations.notchHeight, bottom: Variations.homeIndicatorHeight)
        var requiredTranslation = snapshotInfo.endingFrame.translationToFitInside(rect: view.bounds.inset(by: phoneInsets).inset(by: UIEdgeInsets(allInsets: viewPadding)))
        let newImageFrame = CGRect(origin: snapshotInfo.endingFrame.origin + requiredTranslation, size: snapshotInfo.endingFrame.size)
        
        let topSpace = newImageFrame.minY
        let bottomSpace = view.bounds.height - newImageFrame.maxY
        let leftSpace = newImageFrame.minX
        let rightSpace = view.bounds.width - newImageFrame.maxX
        
        menuShouldBeOnTop = topSpace >= bottomSpace
        
        if menuShouldBeOnTop {
            requiredTranslation.y += max((menuSize.height + menu_imageSpacing + viewPadding) - topSpace, 0)
        } else {
            requiredTranslation.y -= max((menuSize.height + menu_imageSpacing + viewPadding) - bottomSpace, 0)
        }
        menuShouldBePinnedToLeftOfImage = rightSpace >= leftSpace
        endingObjectsTranslation = CGAffineTransform(translationX: requiredTranslation.x, y: requiredTranslation.y)
        endingSnapshotFrame = CGRect(origin: snapshotInfo.endingFrame.origin + requiredTranslation, size: snapshotInfo.endingFrame.size)
    }
    
    private func setInitialViewPositions(){
        
        snapshot.frame = snapshotInfo.endingFrame
        view.addSubview(snapshotInfo.snapshot)
        snapshot.transform = snapshotInfo.currentTransform
        snapshot.setCornerRadius(to: snapshotInfo.cornerRadius)
        
        optionMenu.layer.anchorPoint = CGPoint(x: 0.5, y: menuShouldBeOnTop ? 1 : 0)

        let topOffsetToAccountForAnchorPointChange = menuSize.height.half
        
        
        optionMenu.pin(addTo: view, constants: [.width: menuSize.width, .height: menuSize.height])
        
        if menuShouldBePinnedToLeftOfImage{
            optionMenu.pin(anchors: [.left: view.leftAnchor], constants: [.left: endingSnapshotFrame.minX])
        } else {
            optionMenu.pin(anchors: [.right: view.rightAnchor], constants: [.right: view.bounds.width - endingSnapshotFrame.maxX])
        }
        if menuShouldBeOnTop{
            optionMenu.pin(anchors: [.bottom: view.topAnchor], constants: [.bottom: -(endingSnapshotFrame.minY - menu_imageSpacing) - topOffsetToAccountForAnchorPointChange])
        } else {
            optionMenu.pin(anchors: [.top: view.topAnchor], constants: [.top: endingSnapshotFrame.maxY + menu_imageSpacing - topOffsetToAccountForAnchorPointChange])
        }
        view.layoutIfNeeded()

        let translation = snapshotInfo.currentFrame.origin.y - endingSnapshotFrame.origin.y
        optionMenu.transform = CGAffineTransform(translationX: 0, y: translation).scaledBy(x: 1, y: 0.02)
        optionMenuInitialTransform = optionMenu.transform
    }
    
    
    private var optionMenuInitialTransform: CGAffineTransform!
   
    
    private func setEndingViewPositions(){
        snapshot.transform = endingObjectsTranslation
        optionMenu.transform = CGAffineTransform.identity
    }
    
    private func revertPositionsBackToInitial(){
        snapshot.transform = CGAffineTransform.identity
        optionMenu.transform = optionMenuInitialTransform
        optionMenu.alpha = 0
    }
    
    
    private lazy var optionMenu: PhotoOptionMenu = {
        let x = PhotoOptionMenu()
        return x
    }()

    required init?(coder aDecoder: NSCoder){
        fatalError("init coder has not being implemented")
    }
}


extension PhotoOptionsMiniVC: HKVCTransEventAwareParticipator{
    
    func prepareForPresentation() {
        setInitialViewPositions()
    }
    
    func performUnanimatedPresentationAction() {
        setEndingViewPositions()
    }
    
    func performUnanimatedDismissalAction() {
        revertPositionsBackToInitial()
    }
}

