//
//  LoginVCsTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/28/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class LoginVCTransitioningBrain: HKVCTransBrain{
    
    var presenter: HKVCTransParticipator{return _presenter}
    var presented: HKVCTransParticipator{return _presented}
    
    private lazy var dimmerView: UIView = {
        let x = UIView(frame: UIScreen.main.bounds)
        x.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        x.alpha = 0
        return x
    }()
    
    private let minPresenterViewTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        container.addSubview(presented.view)
        presented.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        presenter.view.addSubview(dimmerView)
    }
    
    override func carryOutUnanimatedPresentationAction() {
        super.carryOutUnanimatedPresentationAction()
        presenter.view.transform = minPresenterViewTransform
        dimmerView.alpha = 1
        presented.view.transform = CGAffineTransform.identity
    }
    override func cleanUpAfterPresentation() {
        super.cleanUpAfterPresentation()
        dimmerView.removeFromSuperview()
        presenter.view.transform = CGAffineTransform.identity
        dimmerView.alpha = 0
    }
    
    override func prepareForDismissal() {
        super.prepareForDismissal()
        container.insertSubview(presenter.view, at: 0)
        presenter.view.addSubview(dimmerView)
        dimmerView.alpha = 1
        presenter.view.transform = minPresenterViewTransform
    }
    
    override func carryOutUnanimatedDismissalAction() {
        super.carryOutUnanimatedDismissalAction()
        presented.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        presenter.view.transform = CGAffineTransform.identity
        dimmerView.alpha = 0
        
    }
    
    override func cleanUpAfterDismissal() {
        dimmerView.removeFromSuperview()
        presented.view.transform = CGAffineTransform.identity
        super.cleanUpAfterDismissal()
    }
    
    
    
}

class LoginVCTransitioningDelegate: HKVCTransDelegate<LoginVCTransitioningBrain,LoginVCAnimationController>{
    
}




class LoginVCAnimationController: HKVCTransAnimationController<LoginVCTransitioningBrain>{
    
    override var duration: TimeInterval{return 0.5}
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        return { UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: $1, completion: $2)}
    }
    
}
