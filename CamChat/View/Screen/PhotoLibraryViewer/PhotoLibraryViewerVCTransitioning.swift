//
//  PhotoLibraryViewerVCTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


@objc protocol PhotoLibraryTransitioningParticipator{
    var viewControllerForPhotoLibraryTransition: UIViewController {get}
}
extension PhotoLibraryTransitioningParticipator{
    var view: UIView!{
        return viewController.view
    }
    var viewController: UIViewController{
        return viewControllerForPhotoLibraryTransition
    }
}


protocol PhotoLibraryViewerTransitioningPresenter: PhotoLibraryTransitioningParticipator{
    var viewForSnapshotToEnterForDismissal: UIView! {get}
    func photoViewerPresentationDidBegin()
    func photoViewerDismissalWillBegin()
    func getThumbnailInfo(forItemAt index: Int) -> (snapshot: UIView, frame: CGRect, cornerRadius: CGFloat)
}

protocol PhotoLibraryViewerTransitioningPresented: PhotoLibraryTransitioningParticipator{
    var currentItemIndex: Int {get}
}



private class PhotoLibraryViewerTransitioningBrain{
    
    
    init(presenter: PhotoLibraryViewerTransitioningPresenter, presented: PhotoLibraryViewerTransitioningPresented){
        
        self.presenter = presenter
        self.presented = presented
    }
    
    
    private lazy var thumbnailInfo = presenter.getThumbnailInfo(forItemAt: presented.currentItemIndex)
    
    private func refreshThumbnailInfo(){
       self.thumbnailInfo = presenter.getThumbnailInfo(forItemAt: presented.currentItemIndex)
    }
    
    
    let presenter: PhotoLibraryViewerTransitioningPresenter
    let presented: PhotoLibraryViewerTransitioningPresented
    
    private var container: UIView!
    
    private lazy var dimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = .black
        x.alpha = 0
        return x
    }()
    
    
    
    
    func prepareForPresentation(using context: UIViewControllerContextTransitioning){
        
        container = context.containerView
        
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
    
    func adjustViewsForPresentation(){
        dimmerView.alpha = 1
        
        thumbnailInfo.snapshot.alpha = 0
        thumbnailInfo.snapshot.frame = container.bounds
        thumbnailInfo.snapshot.layer.cornerRadius = 0
        
        presented.view.frame = container.bounds
        presented.view.layer.cornerRadius = 0
        presented.view.layoutIfNeeded()
    }
    
    func performAfterPresentationCleanUp(){
        thumbnailInfo.snapshot.removeFromSuperview()
    }
    
    
    
    
    
    private var originalFingerPositionInPresentedViewBounds: CGPoint?
    
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
        let newFingerPoint = fingerPosition.translated(by: translation)
        
        
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
    
    func carryOutEndingDismissalAnimationAction(){
        presented.view.transform = CGAffineTransform.identity
        presented.view.frame = thumbnailInfo.frame
        presented.view.layer.cornerRadius = thumbnailInfo.cornerRadius
        presented.view.layoutIfNeeded()
        
        thumbnailInfo.snapshot.transform = CGAffineTransform.identity
        thumbnailInfo.snapshot.alpha = 1
        thumbnailInfo.snapshot.frame = thumbnailInfo.frame
        
        dimmerView.alpha = 0
    }
    
    
    
    func performAfterDismissalCleanUp(){
        thumbnailInfo.snapshot.removeFromSuperview()
        dimmerView.removeFromSuperview()
        presenter.view.isUserInteractionEnabled = true
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


private class PhotoLibraryTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    enum Config { case presentation, dismissal }
    
    private let brain: PhotoLibraryViewerTransitioningBrain
    private let config: Config
    
    init(brain: PhotoLibraryViewerTransitioningBrain, config: Config){
        self.config = config
        self.brain = brain
    }
    
    private let duration: TimeInterval = 0.5
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if config == .presentation{
            brain.prepareForPresentation(using: transitionContext)
            animate(action: brain.adjustViewsForPresentation) {
                self.brain.performAfterPresentationCleanUp()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            brain.prepareForDismissal(fingerPositionInPresentedView: CGPoint.zero)
            brain.prepareForEndingDismissalAnimation()
            animate(action: brain.carryOutEndingDismissalAnimationAction) {
                self.brain.performAfterDismissalCleanUp()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    
    private func animate(action: @escaping () -> Void, completion: @escaping () -> Void){
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: {
            action()
        }) { _ in
            completion()
        }
    }
}







private class PhotoLibraryViewerInteractionController: HKInteractionController{
    
    
    private weak var brain: PhotoLibraryViewerTransitioningBrain!
    
    private let presenter: PhotoLibraryViewerTransitioningPresenter
    private let presented: PhotoLibraryViewerTransitioningPresented
    
    init(brain: PhotoLibraryViewerTransitioningBrain){
        self.brain = brain
        self.presenter = brain.presenter
        self.presented = brain.presented
        super.init()
        setUpGesture(for: presented.viewController)
    }
    
    
    
    
    
    private var shouldCompleteAnimation = false
    var interactionInProgress = false
    
    private var gesture: UIPanGestureRecognizer!
    
    
    private func setUpGesture(for vc: UIViewController){
        
        let gesture = DirectionAwarePanGesture(target: self, action: #selector(respondToGesture(gesture:)))
        vc.view.addGestureRecognizer(gesture)
        self.gesture = gesture
    }
    
    private func begin(){
        interactionInProgress = true
        assert
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
            self.brain.carryOutEndingDismissalAnimationAction()
        }) { _ in
            super.completeTransition(true)
            self.brain.performAfterDismissalCleanUp()
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
