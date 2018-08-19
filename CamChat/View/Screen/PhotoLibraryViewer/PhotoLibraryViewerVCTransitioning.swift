//
//  PhotoLibraryViewerVCTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit





protocol PhotoLibraryViewerTransitioningPresenter: HKVCTransParticipator{
    var viewForSnapshotToEnterForDismissal: UIView! {get}
    func photoViewerPresentationDidBegin()
    func photoViewerDismissalWillBegin()
    func getThumbnailInfo(forItemAt index: Int) -> (snapshot: UIView, frame: CGRect, cornerRadius: CGFloat)
}

protocol PhotoLibraryViewerTransitioningPresented: HKVCTransParticipator{
    var currentItemIndex: Int { get }
}



private class PhotoLibraryViewerTransitioningBrain: HKVCTransBrain{
    
    
    var presenter: PhotoLibraryViewerTransitioningPresenter{
        return _presenter as! PhotoLibraryViewerTransitioningPresenter
    }
    
    var presented: PhotoLibraryViewerTransitioningPresented{
        return _presented as! PhotoLibraryViewerTransitioningPresented
    }
    
    
    private lazy var thumbnailInfo = presenter.getThumbnailInfo(forItemAt: presented.currentItemIndex)
    
    private func refreshThumbnailInfo(){
       self.thumbnailInfo = presenter.getThumbnailInfo(forItemAt: presented.currentItemIndex)
    }
    
    
    
    
    
    private lazy var dimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = .black
        x.alpha = 0
        return x
    }()
    
    
    
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning){
        super.prepareForPresentation(using: context)
        
        dimmerView.frame = container.bounds
        
        presented.view.frame = thumbnailInfo.frame
        presented.view.layer.masksToBounds = true
        presented.view.layer.cornerRadius = thumbnailInfo.cornerRadius
        
        thumbnailInfo.snapshot.frame = thumbnailInfo.frame
        thumbnailInfo.snapshot.layer.masksToBounds = true
        thumbnailInfo.snapshot.layer.cornerRadius = thumbnailInfo.cornerRadius
    
        container.addSubview(dimmerView)
        container.addSubview(presented.view)
        container.addSubview(thumbnailInfo.snapshot)
        presented.view.layoutIfNeeded()
        presenter.photoViewerPresentationDidBegin()
    }
    
    override func carryOutUnanimatedPresentationAction() {
        dimmerView.alpha = 1
        
        thumbnailInfo.snapshot.alpha = 0
        thumbnailInfo.snapshot.frame = container.bounds
        thumbnailInfo.snapshot.layer.cornerRadius = 0
        
        presented.view.frame = container.bounds
        presented.view.layer.cornerRadius = 0
        presented.view.layoutIfNeeded()
    }
    
    
    
    override func cleanUpAfterPresentation() {
        thumbnailInfo.snapshot.removeFromSuperview()

    }
    
    
    
    
    
    
    
    private var originalFingerPositionInPresentedViewBounds: CGPoint?
    
    override func prepareForDismissal() {
        prepareForDismissal(fingerPositionInPresentedView: nil)
    }
    
    func prepareForDismissal(fingerPositionInPresentedView: CGPoint? = nil){
        refreshThumbnailInfo()
        originalFingerPositionInPresentedViewBounds = fingerPositionInPresentedView
        container.insertSubview(presenter.view, at: 0)
        presenter.view.isUserInteractionEnabled = false
        
        container.addSubview(thumbnailInfo.snapshot)
        thumbnailInfo.snapshot.layer.masksToBounds = true
        thumbnailInfo.snapshot.layer.cornerRadius = thumbnailInfo.cornerRadius
        thumbnailInfo.snapshot.frame = presented.view.frame
        thumbnailInfo.snapshot.alpha = 0
        
        presented.view.layer.masksToBounds = true
        presenter.photoViewerDismissalWillBegin()
    }
    

    
    private let minimumPresentedViewScale: CGFloat = 0.3
    
    private let dimmerAlphaEquation = CGLinearEquation(xy(0, 1), xy(300, 0), min: 0, max: 1)!
    
    private lazy var presentedViewTranslationEquation = CGLinearEquation(xy(0, 1), xy(UIScreen.main.bounds.height - 200, minimumPresentedViewScale), min: minimumPresentedViewScale, max: 1)!
    
    
    
    func adjustViewsForDismissal(accordingTo translation: CGPoint){
        
        guard let fingerPosition = originalFingerPositionInPresentedViewBounds else {return}
        let newFingerPoint = fingerPosition.offset(by: translation)
        
        
        let scaleTranslation = presentedViewTranslationEquation.solve(for: translation.y)
        let transform = CGAffineTransform(scaleX: scaleTranslation, y: scaleTranslation)
        presented.view.transform = transform
        thumbnailInfo.snapshot.transform = transform
        
        presented.view.move(pointInBounds: fingerPosition, toPointInSuperViewsFrame: newFingerPoint)
        thumbnailInfo.snapshot.move(pointInBounds: fingerPosition, toPointInSuperViewsFrame: newFingerPoint)
        dimmerView.alpha = dimmerAlphaEquation.solve(for: translation.y)
    }
    
    func prepareForEndingDismissalAnimation(){
        presenter.viewForSnapshotToEnterForDismissal.addSubview(presented.view)
        presenter.viewForSnapshotToEnterForDismissal.addSubview(thumbnailInfo.snapshot)
    }
    
    override func carryOutUnanimatedDismissalAction() {
        presented.view.transform = CGAffineTransform.identity
        presented.view.frame = thumbnailInfo.frame
        presented.view.layer.cornerRadius = thumbnailInfo.cornerRadius
        presented.view.layoutIfNeeded()
        
        thumbnailInfo.snapshot.transform = CGAffineTransform.identity
        thumbnailInfo.snapshot.alpha = 1
        thumbnailInfo.snapshot.frame = thumbnailInfo.frame
        
        dimmerView.alpha = 0
    }
    
    
    
    override func cleanUpAfterDismissal() {
        thumbnailInfo.snapshot.removeFromSuperview()
        dimmerView.removeFromSuperview()
        presented.view.layoutIfNeeded()
        presenter.view.isUserInteractionEnabled = true
        super.cleanUpAfterDismissal()
    }
    
    
}








class PhotoLibraryViewerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate{
    
    private let brain: PhotoLibraryViewerTransitioningBrain
    private let interactor: PhotoLibraryViewerInteractionController
    
    init(presenter: PhotoLibraryViewerTransitioningPresenter, presented: PhotoLibraryViewerTransitioningPresented){

        brain = PhotoLibraryViewerTransitioningBrain(presenter: presenter, presented: presented)
        interactor = PhotoLibraryViewerInteractionController(brain: brain)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoLibraryTransitioningAnimator(brain: brain, config: .presentation)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoLibraryTransitioningAnimator(brain: brain, config: .dismissal)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.interactionInProgress{
            return interactor
        }
        return nil
    }
}


private class PhotoLibraryTransitioningAnimator: HKVCTransAnimationController<PhotoLibraryViewerTransitioningBrain>{
    
    override var duration: TimeInterval{
        return 0.5
    }
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        return {UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: $1, completion: $2)}
    }
}







private class PhotoLibraryViewerInteractionController: HKVCTransInteractionController<PhotoLibraryViewerTransitioningBrain>{
    
    

    private var presenter: PhotoLibraryViewerTransitioningPresenter{
        return brain.presenter
    }
    private var presented: PhotoLibraryViewerTransitioningPresented{
        return brain.presented
    }
    
    override init(brain: PhotoLibraryViewerTransitioningBrain) {
        super.init(brain: brain)
        setUpGesture()
    }
    
    
    
    
    
    
    private var gesture: UIPanGestureRecognizer!
    
    
    private func setUpGesture(){
        
        let gesture = DirectionAwarePanGesture(target: self, action: #selector(respondToGesture(gesture:)))
        presented.view.addGestureRecognizer(gesture)
        self.gesture = gesture
    }
    
    private func begin(){
        interactionInProgress = true
        presented.viewController.dismiss(animated: true)
        brain.prepareForDismissal(fingerPositionInPresentedView: gesture.location(in: presented.view))
    }
    
    private func update(translation: CGPoint, velocity: CGFloat) {
        self.shouldCompleteAnimation = translation.y >= 50 || (velocity >= 500 && translation.y > 50)
        brain.adjustViewsForDismissal(accordingTo: translation)
        super.update(0.5)
    }
    
    func cancel(){
        interactionInProgress = false
        shouldCompleteAnimation = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.brain.adjustViewsForDismissal(accordingTo: CGPoint.zero)
        }) { (success) in
            super.completeTransition(false)
        }
        self.cancelInteraction()
    }
    
    private func finish() {
        interactionInProgress = false
        shouldCompleteAnimation = false
        
        brain.prepareForEndingDismissalAnimation()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: {
            self.brain.carryOutUnanimatedDismissalAction()
        }) { _ in
            super.completeTransition(true)
            self.brain.cleanUpAfterDismissal()
        }
        self.completeInteraction()
    }
    
    @objc private func respondToGesture(gesture: DirectionAwarePanGesture){
        if gesture.scrollingDirection != .vertical{return}
        
        if !interactionInProgress && gesture.swipingDirection != .towardBottom {return}
        
        
        var translation = gesture.translation(in: presenter.view)
        if translation.y < 0 {translation = CGPoint(x: translation.x, y: translation.y * 0.2)}
        let velocity = abs(gesture.velocity(in: presenter.view).y)
        
        switch gesture.state {
            
        case .began: begin()
        case .changed: update(translation: translation, velocity: velocity)
        case .cancelled, .failed: cancel()
        case .ended: if shouldCompleteAnimation{finish()} else {cancel()}

        default: break
            
        }
    }
}
