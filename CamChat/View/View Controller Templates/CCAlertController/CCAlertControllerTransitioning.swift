//
//  CCAlertControllerTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CCAlertControllerTransitioningBrain: HKVCTransBrain{
    var presenter: HKVCTransParticipator{ return _presenter }
    var presented: HKVCTransParticipator{ return _presented }
    
    required init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        super.init(presenter: presenter, presented: presented)
        presented.viewController.modalPresentationStyle = .overCurrentContext
    }
    
    private var minDimmerViewAlpha: CGFloat = 0.4
    
    private lazy var dimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.black.withAlphaComponent(minDimmerViewAlpha)
        x.alpha = 0
        return x
    }()
    
    private lazy var statusBarDimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.black.withAlphaComponent(minDimmerViewAlpha)
        x.alpha = 0
        return x
    }()
    
    private var offScreenTransform: CGAffineTransform{
        let translation = container.bounds.height.half + presented.view.intrinsicContentSize.height.half + 50
        return CGAffineTransform(translationX: 0, y: translation).rotated(by: CGFloat.pi / 3)
    }
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        dimmerView.pin(addTo: container, anchors: [.left: container.leftAnchor, .right: container.rightAnchor, .bottom: container.bottomAnchor, .top: container.safeAreaLayoutGuide.topAnchor])
        statusBar.addSubview(statusBarDimmerView)
        statusBarDimmerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: APP_INSETS.top)
        presented.view.transform = offScreenTransform
        presented.view.pin(addTo: container, anchors: [.centerX: container.safeAreaLayoutGuide.centerXAnchor, .centerY: container.safeAreaLayoutGuide.centerYAnchor])
        
    }
    
    override func carryOutUnanimatedPresentationAction() {
        dimmerView.alpha = 1
        statusBarDimmerView.alpha = 1
        presented.view.transform = CGAffineTransform.identity
    }
    
    override func carryOutUnanimatedDismissalAction() {
        presented.view.transform = offScreenTransform
        dimmerView.alpha = 0
        statusBarDimmerView.alpha = 0
    }
    override func cleanUpAfterDismissal() {
        statusBarDimmerView.removeFromSuperview()
        dimmerView.removeFromSuperview()
        super.cleanUpAfterDismissal()
    }
    
    
}

class CCAlertControllerTransitioningDelegate: HKVCTransDelegate<CCAlertControllerTransitioningBrain, CCAlertControllerTransitioningAnimator>{
    
    override init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        super.init(presenter: presenter, presented: presented)
    }
    
}

class CCAlertControllerTransitioningAnimator: HKVCTransAnimationController<CCAlertControllerTransitioningBrain>{
    
    override var duration: TimeInterval{return config == .presentation ? 0.5 : 0.3}
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        if config == .presentation {
            return { UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: $1, completion: $2)}
        } else {
            return { UIView.animate(withDuration: $0, delay: 0, options: [.curveEaseOut], animations: $1, completion: $2)}
        }
    }
    
}
