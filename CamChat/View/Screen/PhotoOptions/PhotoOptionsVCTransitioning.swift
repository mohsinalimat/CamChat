//
//  PhotoOptionsVCTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit




protocol PhotoOptionsVCPresented: HKVCTransParticipator{
    
    func prepareForObjectsPresentation()
    func performUnanimatedObjectsPresentation()
    
    func prepareForObjectsDismissal()
    func performUnanimatedObjectsDismissal()
    
    func getPhotoViewSnapshotInfo() -> (snapshot: UIView, endingFrame: CGRect, endingCornerRadius: CGFloat)
    
}

class PhotoOptionsVCTransitioningBrain: HKVCTransBrain{
    
    var presenter: HKVCTransParticipator{
        return _presenter
    }
    
    var presented:PhotoOptionsVCPresented{
        return _presented as! PhotoOptionsVCPresented
    }
    
    private var snapshotInfo: (snapshot: UIView, endingFrame: CGRect, endingCornerRadius: CGFloat)!
    private func refreshSnapshotInfo(){ snapshotInfo = presented.getPhotoViewSnapshotInfo() }
    
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        container.insertSubview(presented.view, at: 0)
        refreshSnapshotInfo()
        container.addSubview(snapshotInfo.snapshot)
        snapshotInfo.snapshot.alpha = 0
        snapshotInfo.snapshot.frame = container.bounds
        presented.prepareForObjectsPresentation()
    }
    
    override func carryOutUnanimatedPresentationAction() {
        snapshotInfo.snapshot.setCornerRadius(to: snapshotInfo.endingCornerRadius)
        snapshotInfo.snapshot.alpha = 1
        snapshotInfo.snapshot.frame = snapshotInfo.endingFrame
        
        presenter.view.setCornerRadius(to: snapshotInfo.endingCornerRadius)
        presenter.view.frame = snapshotInfo.endingFrame
        presenter.view.layoutIfNeeded()
        presented.performUnanimatedObjectsPresentation()
    }
    
    override func cleanUpAfterPresentation() {
        snapshotInfo.snapshot.removeFromSuperview()
    }
    
    override func prepareForDismissal() {
        refreshSnapshotInfo()
        presenter.view.setCornerRadius(to: snapshotInfo.endingCornerRadius)
        presenter.view.frame = snapshotInfo.endingFrame
        container.addSubview(presenter.view)
        
        snapshotInfo.snapshot.setCornerRadius(to: snapshotInfo.endingCornerRadius)
        snapshotInfo.snapshot.alpha = 1
        snapshotInfo.snapshot.frame = snapshotInfo.endingFrame
        container.addSubview(snapshotInfo.snapshot)
        presented.prepareForObjectsDismissal()
    }
    
    override func carryOutUnanimatedDismissalAction() {
        snapshotInfo.snapshot.layer.cornerRadius = 0
        snapshotInfo.snapshot.alpha = 0
        snapshotInfo.snapshot.frame = container.bounds
        
        presenter.view.layer.cornerRadius = 0
        presenter.view.frame = container.bounds
        presenter.view.layoutIfNeeded()
        presented.performUnanimatedObjectsDismissal()
    }
    
    override func cleanUpAfterDismissal() {
        snapshotInfo.snapshot.removeFromSuperview()
        super.cleanUpAfterDismissal()
    }
}


class PhotoOptionsVCTransitioningDelegate: HKVCTransDelegate<PhotoOptionsVCTransitioningBrain, PhotoOptionsVCTransitioningAnimationController>{
    
    init(presenter: HKVCTransParticipator, presented: PhotoOptionsVCPresented) {
        super.init(presenter: presenter, presented: presented)
    }
}


class PhotoOptionsVCTransitioningAnimationController: HKVCTransAnimationController<PhotoOptionsVCTransitioningBrain>{
    
    override var duration: TimeInterval{
        return config == .presentation ? 0.3 : 0.15
    }
    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        if config == .presentation {
            return {UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: $1, completion: $2)}
        } else {
            return {UIView.animate(withDuration: $0, delay: 0, options: [.curveEaseOut], animations: $1, completion: $2)}
        }
    }
}

