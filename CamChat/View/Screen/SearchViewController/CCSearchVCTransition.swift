//
//  CCSearchVCTransition.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class CCSearchVCBrain: HKVCTransBrain{
    
    var presented: HKVCTransParticipator{return _presented}
    var presenter: HKVCTransParticipator{return _presenter}
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        
    }
    
    override func carryOutUnanimatedPresentationAction() {
        super.carryOutUnanimatedPresentationAction()
    }
    
    override func cleanUpAfterPresentation() {
        super.cleanUpAfterPresentation()
    }
    
    override func prepareForDismissal() {
        super.prepareForDismissal()
    }
    
    override func carryOutUnanimatedDismissalAction() {
        super.carryOutUnanimatedDismissalAction()
    }
    
    override func cleanUpAfterDismissal() {
        super.cleanUpAfterDismissal()
    }
}


class CCSearchVCTransition: NSObject, UIViewControllerTransitioningDelegate{
    init(searchController: UIViewController){
        searchController.modalPresentationStyle = .overCurrentContext
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CCSearchVCTransitionAnimator(config: .presentation)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CCSearchVCTransitionAnimator(config: .dismissal)
    }
    
}

private class CCSearchVCTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    enum Config{ case presentation, dismissal}
    private let config: Config
    init(config: Config){
        self.config = config
    }
    
    private let duration = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        if config == .presentation{
            transitionContext.containerView.addSubview(toView!)
            toView?.alpha = 0
        }
        let viewToChange = (config == .presentation) ? toView : fromView
        let endingAlpha: CGFloat = (config == .presentation) ? 1 : 0
        
        UIView.animate(withDuration: duration, animations: {
            viewToChange!.alpha = endingAlpha
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    
    
}
