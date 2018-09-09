//
//  PhotoOptionsMiniTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/19/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit





class PhotoOptionsMiniTransitioningBrain: HKVCTransBrain{
    
    required init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        super.init(presenter: presenter, presented: presented)
        
        presented.viewController.modalPresentationStyle = .overCurrentContext
    }
    
    var presented: HKVCTransParticipator{
        return _presented
    }
    
    var presenter: HKVCTransParticipator{
        return _presenter
    }
    
    private let bluryView: UIView = {
        let x = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        x.alpha = 0
        return x
    }()
    
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        bluryView.pinAllSides(addTo: container, pinTo: container)
        container.addSubview(presented.view)
        presented.view.backgroundColor = .clear
        
        
    }
    
    override func carryOutUnanimatedPresentationAction() {
        bluryView.alpha = 1
        super.carryOutUnanimatedPresentationAction()
        // because for some reason the status bar is not disappearing, even though in the viewController class I have preferrsStatusBarHidden to true
        statusBar.alpha = 0
    }
    
    override func prepareForDismissal() {
        super.prepareForDismissal()
    }
    
    override func carryOutUnanimatedDismissalAction() {
        bluryView.alpha = 0
        // because for some reason the status bar is not disappearing, even though in the viewController class I have preferrsStatusBarHidden to true
        statusBar.alpha = 1
        super.carryOutUnanimatedDismissalAction()
    }
    
    
    override func cleanUpAfterDismissal() {
        bluryView.removeFromSuperview()
        super.cleanUpAfterDismissal()

    }
    
}


class PhotoOptionsMiniTransitioningDelegate: HKVCTransDelegate<PhotoOptionsMiniTransitioningBrain, PhotoOptionsMiniAnimationController>{
    init(presenter: HKVCTransParticipator, presented: HKVCTransEventAwareParticipator) {
        super.init(presenter: presenter, presented: presented)
    }
}

class PhotoOptionsMiniAnimationController: HKVCTransAnimationController<PhotoOptionsMiniTransitioningBrain>{
    override var duration: TimeInterval{return config == .presentation ? 0.3 : 0.17}
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        if config == .presentation{
        return { UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: $1, completion: $2) }
        } else {
            return { UIView.animate(withDuration: $0, delay: 0, options: [.curveEaseOut], animations: $1, completion: $2) }
        }
    }
}
