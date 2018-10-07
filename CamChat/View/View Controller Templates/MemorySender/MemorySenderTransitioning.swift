//
//  MemorySenderTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class MemorySenderTransitioningBrain: HKVCTransBrain{
    
    
    var presenter: HKVCTransParticipator{
        return _presenter
    }
    var presented: HKVCTransParticipator{
        return _presented
    }
    
    
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        
        container.addSubview(presented.view)
        presented.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
    }
    
    override func carryOutUnanimatedPresentationAction() {
        super.carryOutUnanimatedPresentationAction()
        presented.view.transform = CGAffineTransform.identity
    }
    
    override func carryOutUnanimatedDismissalAction() {
        super.carryOutUnanimatedDismissalAction()
        presented.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
    }
}


class MemorySenderAnimationController: HKVCTransAnimationController<MemorySenderTransitioningBrain>{
    
    override var duration: TimeInterval{
        return 0.4
    }
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        
        
            return {UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: $1, completion: $2)}
        
    }
    
    
}


class MemorySenderTransioningDelegate: HKVCTransDelegate<MemorySenderTransitioningBrain, MemorySenderAnimationController>{
    override init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        super.init(presenter: presenter, presented: presented)
        presented.viewController.modalPresentationStyle = .overCurrentContext
    }
}

