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
    
    func adjustViewPositionsForDismissal(accordingTo val: CGFloat){
        
        presented.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width * val, y: 0)
    }
    
    override func carryOutUnanimatedDismissalAction() {
        super.carryOutUnanimatedDismissalAction()
        adjustViewPositionsForDismissal(accordingTo: 1)
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
    private var interactionController: MemorySenderInteractionController!
    override init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        
        super.init(presenter: presenter, presented: presented)
        self.interactionController = MemorySenderInteractionController(brain: brain)
        presented.viewController.modalPresentationStyle = .overCurrentContext
    }
    
    override func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactionController.interactionInProgress{
            return interactionController
        } else {return nil}
    }
}




/// Umm, hi, hello, this is literally the EXACT same code from the chat controller transitioning interaction controller. As in, I literally copy and pasted the code. So if you find yourself having to copy and paste this one more time, please just make it into its own class and have all the various interaction controllers inherit from it.

class MemorySenderInteractionController: HKVCTransInteractionController<MemorySenderTransitioningBrain>, UIGestureRecognizerDelegate{
    
    
    override init(brain: MemorySenderTransitioningBrain) {
        super.init(brain: brain)
        setUpGesture(for: presented.viewController)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView{return false}
        return true
    }
    
    
    private var presenter: HKVCTransParticipator{
        return brain.presenter
    }
    
    private var presented: HKVCTransParticipator{
        return brain.presented
    }
    
    private func setUpGesture(for vc: UIViewController){
        
        let gesture = DirectionAwarePanGesture(target: self, action: #selector(respondToGesture(gesture:)))
        gesture.delegate = self
        gesture.stopInterferingWithTouchesInView()
        
        vc.view.addGestureRecognizer(gesture)
        
    }
    
    private func begin(){
        interactionInProgress = true
        presented.viewController.dismiss(animated: true)
        brain.prepareForDismissal()
    }
    
    private func update(percentage: CGFloat, velocity: CGFloat) {
        self.shouldCompleteAnimation = percentage >= 0.5 || (velocity >= 500 && percentage > 0.2)
        brain.adjustViewPositionsForDismissal(accordingTo: percentage)
        super.update(percentage)
    }
    
    func cancel(){
        interactionInProgress = false
        shouldCompleteAnimation = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.brain.adjustViewPositionsForDismissal(accordingTo: 0)
        }) { (success) in
            super.completeTransition(false)
        }
        self.cancelInteraction()
    }
    
    private func finish(progress: CGFloat, velocity: CGFloat) {
        interactionInProgress = false
        shouldCompleteAnimation = false
        let remainingProgress = 1 - progress
        let remainingPoints = remainingProgress * presented.view.frame.width
        let time = min(Double(remainingPoints / velocity), 0.3)
        
        UIView.animate(withDuration: time, delay: 0, options: .curveEaseOut, animations: {
            self.brain.adjustViewPositionsForDismissal(accordingTo: 1)
        }) { (success) in
            super.completeTransition(true)
            self.brain.cleanUpAfterDismissal()
        }
        self.completeInteraction()
    }
    
    @objc private func respondToGesture(gesture: DirectionAwarePanGesture){
        if gesture.scrollingDirection != .horizontal{return}
        
        let translation = gesture.translation(in: presented.view).x
        let velocity = abs(gesture.velocity(in: presented.view).x)
        let percentage = max(min(translation / presented.view.frame.width, 1), 0)
        switch gesture.state {
        case .began: begin()
        case .changed: update(percentage: percentage, velocity: velocity)
        case .cancelled, .failed: cancel()
        case .ended: if shouldCompleteAnimation{finish(progress: percentage, velocity: velocity)} else {cancel()}
            
        default: break
            
        }
    }
    
    
    
}

