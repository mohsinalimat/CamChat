//
//  SlideInTransitionDelegate.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/22/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



/// The ViewController presenting the Chat Controller may conform to this protocol so that it's topBar (if it has one) may be animated.
@objc protocol ChatControllerTransitionAnimationParticipator: class{
    var view: UIView!{get}
    var viewToDim: UIView! {get}
    var topBarView: UIView {get}
}

/// The Chat Controller conforms to this protocol.
@objc protocol ChatControllerProtocol: class{
    var backgroundView: UIView{get}
    var topBarView: UIView {get}
    var view: UIView! {get}
}




fileprivate class ChatControllerAnimationPositioningBrain{
    
    
    
    init(){
        adjustKeyboardWindows{$0.transform = CGAffineTransform.identity}
    }
    
    private weak var container: UIView!
    
    private weak var chatControllerDelegate: ChatControllerProtocol?
    
    private weak var chatView: UIView!
    private weak var chatBackgroundView: UIView!
    private weak var chatTopBar: UIView!
    
    private weak var presentingView: UIView!
    private weak var presentingViewTopBar: UIView?
    private weak var presentingViewToDim: UIView?
    private weak var presentingParticipator: ChatControllerTransitionAnimationParticipator?
    private weak var presentingViewController: UIViewController!
    
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
    
  
    
    
    private func initializeVars(basedOn transitionContext: UIViewControllerContextTransitioning){
        
        guard let chatVC = transitionContext.viewController(forKey: .to)! as? ChatControllerProtocol else {
            fatalError("ChatControllerAnimationPositioningBrain is being used to present a viewController that is not a ChatController")
        }
        chatControllerDelegate = chatVC
        
        chatView = chatVC.view
        chatBackgroundView = chatVC.backgroundView
        chatTopBar = chatVC.topBarView
        
        if let participator = transitionContext.viewController(forKey: .from)! as? ChatControllerTransitionAnimationParticipator{
            self.presentingView = participator.view
            self.presentingViewTopBar = participator.topBarView
            self.presentingViewToDim = participator.viewToDim
        } else {
            presentingView = transitionContext.view(forKey: .from)!
        }
        container = transitionContext.containerView
        presentingViewController = transitionContext.viewController(forKey: .from)!
    }
    
    
    
    
    /// This function must be called before any other function so that all of this class's vars may be initialized.
    func prepareForPresentation(using transitionContext: UIViewControllerContextTransitioning){
        
        initializeVars(basedOn: transitionContext)
        presentingViewController.view.isUserInteractionEnabled = false
        container.addSubview(chatBackgroundView)
        container.addSubview(chatView)
        
        if let viewToDim = presentingViewToDim{
            presentingViewDimmer.pinAllSides(addTo: viewToDim, pinTo: viewToDim)
        }
        
        
        

        chatTopBar.pin(addTo: container, anchors: [.centerX: container.centerXAnchor, .top: container.safeAreaLayoutGuide.topAnchor])
        
        chatBackgroundView.frame = container.bounds

        chatTopBar.transform = CGAffineTransform(translationX: -chatView.frame.width, y: 0)
        chatBackgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: 1)
        chatView.transform = CGAffineTransform(translationX: -chatView.frame.width, y: 0)
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
    
    
    
    
    /// This basically performs the unanimated presentation action.
    
    func adjustViewPositionsForPresentation(){
        chatView.transform = CGAffineTransform.identity
        chatTopBar.transform = CGAffineTransform(translationX: chatBackgroundViewAlphaEquation.solve(for: 0), y: 0)
        presentingViewTopBar?.alpha = presentingTopBarAlphaEquation.solve(for: 0)
        chatBackgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: 0)
        presentingViewDimmer.alpha = presentingViewDimmerEquation.solve(for: 0)
        if let tappedCell = tappedCell, let equation = tappedCellTransformEquation{
            tappedCell.transform = CGAffineTransform(translationX: equation.solve(for: 0), y: 0)
        }
    }
    
    
   
    
    func prepareForDismissal(){
        container.insertSubview(presentingView, at: 0)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardDismissal), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    
    /// This basically performs the unanimated dismissal action.
    
    func adjustViewPositionsForDismissal(accordingTo percentage: CGFloat = 1){
        chatView.transform = CGAffineTransform(translationX: -(chatView.frame.width * percentage), y: 0)
        adjustKeyboardWindows{$0.transform = chatView.transform}
        chatTopBar.transform = CGAffineTransform(translationX: chatTopBarTranslationEquation.solve(for: percentage), y: 0)
        chatBackgroundView.alpha = chatBackgroundViewAlphaEquation.solve(for: percentage)
        presentingViewTopBar?.alpha = presentingTopBarAlphaEquation.solve(for: percentage)
        chatTopBar.alpha = chatBackgroundViewAlphaEquation.solve(for: percentage)
        presentingViewDimmer.alpha = presentingViewDimmerEquation.solve(for: percentage)
        
        
        if let tappedCell = tappedCell, let equation = tappedCellTransformEquation{
            tappedCell.transform = CGAffineTransform(translationX: equation.solve(for: percentage), y: 0)
        }
        
    }
    
    @objc private func respondToKeyboardDismissal(){
        adjustKeyboardWindows{$0.transform = CGAffineTransform.identity}
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func afterDismissalCleanUp(){
        tappedCell?.transform = CGAffineTransform.identity
        presentingViewDimmer.removeFromSuperview()
        chatTopBar.removeFromSuperview()
        presentingViewController.view.isUserInteractionEnabled = true
    }

}





class ChatControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate{
    
    private let brain = ChatControllerAnimationPositioningBrain()
    private let interactor: ChatControllerInteractionController
    init(chatVC: UIViewController){
        
        self.interactor = ChatControllerInteractionController(chatVC: chatVC, brain: brain)
        super.init()
    }
    
    var tappedCell: UIView?{
        get{return brain.tappedCell}
        set{brain.tappedCell = newValue}
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ChatControllerAnimationController(config: .presentation, brain: brain)
    }
    
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ChatControllerAnimationController(config: .dismissal, brain: brain)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.interactor.interactionInProgress{
            return interactor
        }
        return nil
    }
    
    
}











private class ChatControllerAnimationController: NSObject, UIViewControllerAnimatedTransitioning{
    
    enum Config{ case presentation, dismissal }
    
    private let config: Config
    private weak var brain: ChatControllerAnimationPositioningBrain!
    
    init(config: Config, brain: ChatControllerAnimationPositioningBrain){
        self.config = config
        self.brain = brain
        super.init()
    }
    
    private let presentationDuration = 0.4
    private let dismissalDuration = 0.2
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch config{
        case .presentation: return presentationDuration
        case .dismissal: return dismissalDuration
        }
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let completion: (Bool) -> Void = { _ in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        switch config{
        
        case .presentation:
            brain.prepareForPresentation(using: transitionContext)
            UIView.animate(withDuration: presentationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.brain.adjustViewPositionsForPresentation()
            }, completion: completion)
        
        case .dismissal:
            brain.prepareForDismissal()
            UIView.animate(withDuration: dismissalDuration, delay: 0, options: .curveEaseOut, animations: {
                self.brain.adjustViewPositionsForDismissal()
            }, completion: {_ in completion(true); self.brain.afterDismissalCleanUp() })
        }
    }
}




private class InteractionController: NSObject, UIViewControllerInteractiveTransitioning{
    private var context: UIViewControllerContextTransitioning?
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
    }
    
    func update(_ percentage: CGFloat){
        context?.updateInteractiveTransition(percentage)
    }
    func cancelInteraction(){
        context?.cancelInteractiveTransition()
    }
    
    func completeTransition(_ didComplete: Bool){
        context?.completeTransition(didComplete)
    }
    
    func completeInteraction(){
        context?.finishInteractiveTransition()
    }
}





private class ChatControllerInteractionController: InteractionController{
    
    
    private weak var brain: ChatControllerAnimationPositioningBrain!
    private weak var chatVC: UIViewController!
    init(chatVC: UIViewController, brain: ChatControllerAnimationPositioningBrain){
        self.brain = brain
        self.chatVC = chatVC
        super.init()
        setUpGesture(for: chatVC)
    }
    
    
    
    
    private var shouldCompleteAnimation = false
    var interactionInProgress = false
    
    private func setUpGesture(for vc: UIViewController){
        
        let gesture = DirectionAwarePanGesture(target: self, action: #selector(respondToGesture(gesture:)))
        vc.view.addGestureRecognizer(gesture)
        
    }
    
    private func begin(){
        interactionInProgress = true
        chatVC.dismiss(animated: true)
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
        let remainingPoints = remainingProgress * chatVC.view.frame.width
        let time = min(Double(remainingPoints / velocity), 0.3)
        
        UIView.animate(withDuration: time, delay: 0, options: .curveEaseOut, animations: {
            self.brain.adjustViewPositionsForDismissal(accordingTo: 1)
        }) { (success) in
            super.completeTransition(true)
            self.brain.afterDismissalCleanUp()
        }
        self.completeInteraction()
    }
    
    @objc private func respondToGesture(gesture: DirectionAwarePanGesture){
        if gesture.direction != .horizontal{return}
        
        
        let translation = gesture.translation(in: chatVC.view).x
        let velocity = abs(gesture.velocity(in: chatVC.view).x)
        let percentage = max(min(-translation / chatVC.view.frame.width, 1), 0)
        
        switch gesture.state {
        case .began: begin()
        case .changed: update(percentage: percentage, velocity: velocity)
        case .cancelled, .failed: cancel()
        case .ended: if shouldCompleteAnimation{finish(progress: percentage, velocity: velocity)} else {cancel()}
        
        default: break
            
        }
        
        
    }
}

