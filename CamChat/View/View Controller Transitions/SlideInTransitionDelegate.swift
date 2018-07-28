//
//  SlideInTransitionDelegate.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/22/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class SlideInTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate{
    
    
    enum SlideDirection{ case left, right}
    
    private let direction: SlideDirection
    private let interactor: SlideVCTransitionInteractor
    init(viewController: UIViewController, direction: SlideDirection){
        self.interactor = SlideVCTransitionInteractor(viewController: viewController, direction: direction)
        self.direction = direction
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideVCTransition(config: .presentation(direction))
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor
    }
    
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideVCTransition(config: .dismissal(direction))
    }
}




private class SlideVCTransition: NSObject, UIViewControllerAnimatedTransitioning{
    
    enum SlideConfig{
        
        case presentation(SlideInTransitioningDelegate.SlideDirection)
        case dismissal(SlideInTransitioningDelegate.SlideDirection)
        
        var direction: SlideInTransitioningDelegate.SlideDirection{
            switch self{
            case .presentation(let direction): return direction
            case .dismissal(let direction): return direction
            }
        }
    }
    
    private let config: SlideConfig
    
    init(config: SlideConfig) {
        self.config = config
        super.init()
    }
    
    private let duration: TimeInterval = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else {return}
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        toView.frame = UIScreen.main.bounds
        fromView.frame = UIScreen.main.bounds
        let container = transitionContext.containerView
        container.backgroundColor = .black
        

        
        let completion: (Bool) -> Void = { _ in
            toView.transform = CGAffineTransform.identity
            fromView.transform = CGAffineTransform.identity

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        let topViewTranslation = CGAffineTransform(translationX: config.direction == .left ? -toView.frame.width : toView.frame.width, y: 0)
        
        let bottomViewTranslationVal = fromView.frame.width * 0.4
        let bottomViewTranslation = CGAffineTransform(translationX: config.direction == .left ? bottomViewTranslationVal : -bottomViewTranslationVal , y: 0)
        
        let action: () -> Void
        let alphaConstant: CGFloat = 0.5
        switch config {
        case .presentation:
            container.addSubview(toView)
            toView.transform = topViewTranslation
            action = {
                toView.transform = CGAffineTransform.identity
                fromView.transform = bottomViewTranslation
                fromView.alpha = alphaConstant
                
            }
        case .dismissal:
            toView.transform = bottomViewTranslation
            container.insertSubview(toView, at: 0)
            toView.alpha = alphaConstant
            action = {
                fromView.transform = topViewTranslation
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1
            }
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: action, completion: completion)
        
        
    }
}

class SlideVCTransitionInteractor: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate{
    
    var interactionInProgress = false
    private var shouldFinishAnimation = false
    private weak var viewController: UIViewController?
    private var direction: SlideInTransitioningDelegate.SlideDirection
    
    
    override var completionCurve: UIView.AnimationCurve{
        get { return .easeOut }
        set { super.completionCurve = .easeOut }
        
        
    }
    

  
    func update(_ percentComplete: CGFloat, velocity: CGFloat){
        shouldFinishAnimation = percentComplete > 0.3 || velocity > 800

        print(completionSpeed)
        update(percentComplete)
    }
    
    

    
    
    init(viewController: UIViewController, direction: SlideInTransitioningDelegate.SlideDirection){
        self.direction = direction
        self.viewController = viewController
        super.init()
        prepareVCWithGestureRecognizer(vc: viewController)
        completionSpeed = 0.5
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    private func prepareVCWithGestureRecognizer(vc: UIViewController){
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(respondToGesture(gesture:)))
        gesture.delegate = self
        vc.view.addGestureRecognizer(gesture)
    }
    
    
    @objc private func respondToGesture(gesture: UIPanGestureRecognizer){
        guard let vc = viewController else {return}
        let translation = gesture.translation(in: vc.view).x
        let velocity = abs(gesture.velocity(in: vc.view).x)
        let translationToUse = (direction == .left) ? -translation : translation
        let percent: CGFloat = max(min(translationToUse / vc.view.frame.width, 1), 0)
        switch gesture.state{

        case .began:
            interactionInProgress = true
            vc.dismiss(animated: true, completion: nil)
        case .changed:
            update(percent, velocity: velocity)
        case .cancelled, .failed:
            interactionInProgress = false
            shouldFinishAnimation = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldFinishAnimation{ finish() }
            else { cancel() }
        default: break
            
            
        }
    }
}
