//
//  SlideInTransitionDelegate.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/22/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



/// The ViewController presenting the Chat Controller may conform to this protocol so that it's topBar (if it has one) may be animated.
protocol ChatControllerTransitionAnimationParticipator: HKVCTransParticipator{
    var viewToDim: UIView {get}
    var topBarView: UIView {get}
    
}

protocol ChatControllerProtocol: HKVCTransParticipator{
    var backgroundView: UIView {get}
    var topBarView: UIView {get}
    
}




class ChatControllerAnimationPositioningBrain: HKVCTransBrain{
    
    var presenter_typed: ChatControllerTransitionAnimationParticipator? {
        return presenter as? ChatControllerTransitionAnimationParticipator
    }
    
    
    var presenter: HKVCTransParticipator {
        return _presenter
    }
    
    var presented: ChatControllerProtocol {
        return _presented as! ChatControllerProtocol
    }
    
    
    
   
    
    required init(presenter: HKVCTransParticipator, presented: HKVCTransParticipator) {
        super.init(presenter: presenter, presented: presented)
        adjustKeyboardWindows{ $0.transform = CGAffineTransform.identity }
        
    }
    
    
    
    weak var tappedCell: UIView?{
        didSet{
            guard let tappedCell = tappedCell else {return}
            let maxVal = tappedCell.frame.width - 60
            tappedCellTransformEquation = CGLinearEquation(xy(1, 0), xy(0, maxVal), min: 0, max: maxVal)!
        }
    }
    
    private var presentingViewDimmer: UIView = {
        let x = UIView()
        x.backgroundColor = .black
        x.alpha = 0
        return x
    }()
    
  
    
    
  
    
    
    
    /// This function must be called before any other function so that all of this class's vars may be initialized.
    override func prepareForPresentation(using transitionContext: UIViewControllerContextTransitioning){
        super.prepareForPresentation(using: transitionContext)
        presenter.view.isUserInteractionEnabled = false
        container.addSubview(presented.backgroundView)
        container.addSubview(presented.view)
        
        if let viewToDim = presenter_typed?.viewToDim{
            presentingViewDimmer.pinAllSides(addTo: viewToDim, pinTo: viewToDim)
        }
        
        presented.topBarView.pin(addTo: container, anchors: [.centerX: container.centerXAnchor, .top: container.topAnchor], constants: [.top: APP_INSETS.top])
        
        presented.backgroundView.frame = container.bounds

        presented.topBarView.transform = CGAffineTransform(translationX: -presented.view.frame.width, y: 0)
        presented.backgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: 1)
        presented.view.transform = CGAffineTransform(translationX: -presented.view.frame.width, y: 0)
    }
    
    
    
    
    private func adjustKeyboardWindows(_ action: (UIWindow) -> Void){
        for window in UIApplication.shared.windows where window !== UIApplication.shared.keyWindow{
            action(window)
        }
    }
    
   
    
    
    
    
    
    
    private let maxTopBarTranslation: CGFloat = 30
    
    // At 0, presentation is complete. At 1, dismissal is complete (or presentation hasn't started yet).
    
    private let chatBackgroundViewAlphaEquation = CGLinearEquation(xy(0, 1), xy(0.5, 0), min: 0, max: 1)!
    private lazy var chatTopBarTranslationEquation = CGLinearEquation(xy(0, 0), xy(1, -maxTopBarTranslation), min: -maxTopBarTranslation, max: 0)!
    private let presentingTopBarAlphaEquation = CGLinearEquation(xy(1, 1), xy(0.5, 0), min: 0, max: 1)!
    private let presentingViewDimmerEquation = CGLinearEquation(xy(0, 0.3), xy(1, 0), min: 0, max: 0.3)!
    private var tappedCellTransformEquation: CGEquation?
    
    
    
    
    
    override func carryOutUnanimatedPresentationAction() {
        super.carryOutUnanimatedPresentationAction()
        presented.view.transform = CGAffineTransform.identity
        presented.topBarView.transform = CGAffineTransform(translationX: chatBackgroundViewAlphaEquation.solve(for: 0), y: 0)
        presenter_typed?.topBarView.alpha = presentingTopBarAlphaEquation.solve(for: 0)
        presented.backgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: 0)
        presentingViewDimmer.alpha = presentingViewDimmerEquation.solve(for: 0)
        if let tappedCell = tappedCell, let equation = tappedCellTransformEquation{
            tappedCell.transform = CGAffineTransform(translationX: equation.solve(for: 0), y: 0)
        }
    }
    
    override func cleanUpAfterPresentation() {
        super.cleanUpAfterPresentation()
        if let tappedCell = tappedCell{
            tappedCell.transform = CGAffineTransform.identity
        }
    }
    
    private var myself: AnyObject?
    
    override func prepareForDismissal(){
        super.prepareForDismissal()
        container.insertSubview(presenter.view, at: 0)
        
        NotificationCenter.default.removeObserver(self)

        myself = self
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil) { [weak self ] _ in
            guard let self = self else {return}
            self.adjustKeyboardWindows{ $0.transform = CGAffineTransform.identity }
            NotificationCenter.default.removeObserver(self)
            self.myself = nil
        }
        
        
        if let tappedCell = tappedCell, let equation = tappedCellTransformEquation{
            tappedCell.transform = CGAffineTransform(translationX: equation.solve(for: 0), y: 0)
        }
    }
    

    
    /// This basically performs the unanimated dismissal action.
    
    override func carryOutUnanimatedDismissalAction() {
        super.carryOutUnanimatedDismissalAction()
        adjustViewPositionsForDismissal(accordingTo: 1)
    }
    
    func adjustViewPositionsForDismissal(accordingTo percentage: CGFloat = 1){
        presented.view.transform = CGAffineTransform(translationX: -(presented.view.frame.width * percentage), y: 0)
        adjustKeyboardWindows{$0.transform = presented.view.transform}
        presented.topBarView.transform = CGAffineTransform(translationX: chatTopBarTranslationEquation.solve(for: percentage), y: 0)
        presented.backgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: percentage)
        presenter_typed?.topBarView.alpha = presentingTopBarAlphaEquation.solve(for: percentage)
        presented.topBarView.alpha = chatBackgroundViewAlphaEquation.solve(for: percentage)
        presentingViewDimmer.alpha = presentingViewDimmerEquation.solve(for: percentage)
        
        
        if let tappedCell = tappedCell, let equation = tappedCellTransformEquation{
            tappedCell.transform = CGAffineTransform(translationX: equation[percentage], y: 0)
        }
        
    }
   
    
    override func cleanUpAfterDismissal() {
        tappedCell?.transform = CGAffineTransform.identity
        presentingViewDimmer.removeFromSuperview()
        presented.topBarView.removeFromSuperview()
        presenter.view.isUserInteractionEnabled = true
        super.cleanUpAfterDismissal()
    }
    
    
    

}





class ChatControllerTransitioningDelegate: HKVCTransDelegate<ChatControllerAnimationPositioningBrain, ChatControllerAnimationController>{
    
    private var interactor: ChatControllerInteractionController!
    
    
    
    init(presenter: HKVCTransParticipator, presented: ChatControllerProtocol) {
        super.init(presenter: presenter, presented: presented)
        interactor = ChatControllerInteractionController(brain: brain)

    }
    
    
    
    var tappedCell: UIView?{
        get{return brain.tappedCell}
        set{brain.tappedCell = newValue}
    }
    
    override func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.interactionInProgress{
            return interactor
        }
        return nil
    }
    
    
}










class ChatControllerAnimationController: HKVCTransAnimationController<ChatControllerAnimationPositioningBrain> {
    
    
    override var duration: TimeInterval{
        if config == .presentation{return 0.4} else {return 0.2}
    }
    

    
    override func getAnimator() -> (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void {
        if config == .presentation{
            return {UIView.animate(withDuration: $0, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseIn, animations: $1, completion: $2)}
        } else {
            return {UIView.animate(withDuration: $0, delay: 0, options: .curveEaseOut, animations: $1, completion: $2)}
        }
    }
    
}










private class ChatControllerInteractionController: HKVCTransInteractionController<ChatControllerAnimationPositioningBrain>, UIGestureRecognizerDelegate{
    
    
    override init(brain: ChatControllerAnimationPositioningBrain) {
        super.init(brain: brain)
        setUpGesture(for: presented.viewController)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   
    
    private var presenter: HKVCTransParticipator{
        return brain.presenter
    }
    
    private var presented: ChatControllerProtocol{
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
        self.shouldCompleteAnimation = percentage >= 0.3 || velocity >= 500
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
        let percentage = max(min(-translation / presented.view.frame.width, 1), 0)
        switch gesture.state {
        case .began: begin()
        case .changed: update(percentage: percentage, velocity: velocity)
        case .cancelled, .failed: cancel()
        case .ended: if shouldCompleteAnimation{finish(progress: percentage, velocity: velocity)} else {cancel()}
        
        default: break
            
        }
    }
}

