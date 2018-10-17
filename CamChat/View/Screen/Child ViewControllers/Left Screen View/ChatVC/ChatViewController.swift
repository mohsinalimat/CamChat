//
//  ChatViewController.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

protocol ChatViewControllerTappedCellProvider{
    func cellFor(user: User) -> UITableViewCell?
}


class ChatViewController: UIViewController{
    
  
    private var tappedCell: UIView?{
        get{ return chatTransitioningDelegate.tappedCell }
        set{ chatTransitioningDelegate.tappedCell = newValue}
    }
    
    
    private let user: User
    private var tappedCellProvider: ChatViewControllerTappedCellProvider?

    
    convenience init(presenter: HKVCTransParticipator, tappedCellProvider: ChatViewControllerTappedCellProvider, user: User){
        self.init(presenter: presenter, user: user)
        self.tappedCellProvider = tappedCellProvider
    }
    
    init(presenter: HKVCTransParticipator, user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.chatTransitioningDelegate = ChatControllerTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = chatTransitioningDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextViewDidBeginEditing), name: UITextView.textDidBeginEditingNotification, object: self.accessoryView.textView)
    }

    
    
    @objc private func respondToTextViewDidBeginEditing(){
        tableView.scrollToBottom()
    }
    
   

    private var chatTransitioningDelegate: ChatControllerTransitioningDelegate!

    
    private let topInset: CGFloat = 45

    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets.top = topInset
        
        topBarView_typed.topBarRightIcon.addAction({[weak self] in self?.dismiss(animated: true)})
        tableView.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .top: view.topAnchor], constants: [.top: topInset + APP_INSETS.top])
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    

    

    override func loadView() {
        let view = HKView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .clear
        view.didMoveToSuperviewAction = { [weak self] in self?.becomeFirstResponder() }
        view.hitTestAction = { [weak self] in self?.hitTestView(point: $0, event: $1) }
        self.view = view
    }
    
    private func hitTestView(point: CGPoint, event: UIEvent?) -> UIView?{
        let convertedPoint = tableView.convert(point, from: view)
        if let hitTestedView = tableView.hitTest(convertedPoint, with: event){
            return hitTestedView
        }
        return nil
    }
    
    @objc private func respondToKeyboardWillChangeFrame(notification: Notification){
        
        let newKeyboardFrame = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        let keyboardHeightOnScreen = max(self.view.bounds.height - newKeyboardFrame.minY, 0)
        
        UIView.performWithoutAnimation {
            let height = max(keyboardHeightOnScreen, 0)
            let inset = height - 10
            self.tableView.contentInset.bottom = inset
            self.tableView.scrollIndicatorInsets.bottom = height
        }
    }
    

    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override var canResignFirstResponder: Bool{
        return true
    }
    
    private lazy var tableView: ChatMessagesTableView = {
        return ChatMessagesTableView(user: user, vcOwner: self)
    }()
    
    
    lazy var topBarView_typed: ChatTopBar = {
        return ChatTopBar(size: CGSize(width: UIScreen.main.bounds.width, height: topInset), user: user)
    }()
    
    
    
    lazy var backgroundView: UIView = {
        let x = HKGradientView(colors: [BLUECOLOR, DARKER_BLUECOLOR])
        x.gradientLayer.transform = CATransform3DRotate(x.gradientLayer.transform, (CGFloat.pi * 2) * 0.75, 0, 0, 1)
        
        return x
    }()
   

    
    
    
    
    private lazy var accessoryView: ChatKeyboardShortcutView = {
        return ChatKeyboardShortcutView(user: self.user)
    }()
    
    private lazy var accesoryViewWrapper = InputAccessoryViewWrapper(for: accessoryView, width: view.frame.width)
    
    

  
    override var inputAccessoryView: UIView?{
        return accesoryViewWrapper
    }
    
   
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}


extension ChatViewController: HKVCTransEventAwareParticipator{
    func prepareForPresentation() {
        tappedCell = tappedCellProvider?.cellFor(user: user)
    }
    func cleanUpAfterPresentation() {
        DataCoordinator.performChatPresentationActionsForUser(user: user)
    }

    func prepareForDismissal() {
        tappedCell = tappedCellProvider?.cellFor(user: user)
    }
    
    func cleanUpAfterDismissal() {
        DataCoordinator.performChatDismissalActionsFor(user: user)
    }
}


extension ChatViewController: ChatControllerProtocol{
    
    var topBarView: UIView{
        return topBarView_typed
    }
 
}
