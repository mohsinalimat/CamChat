//
//  ChatViewController.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatViewController: UIViewController{
    
  
    var tappedCell: UIView?{
        get{ return chatTransitioningDelegate.tappedCell }
        set{ chatTransitioningDelegate.tappedCell = newValue}
    }
    
    
    private let user: User

    init(presenter: HKVCTransParticipator, user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.chatTransitioningDelegate = ChatControllerTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = chatTransitioningDelegate
    }
    
   

    private var chatTransitioningDelegate: ChatControllerTransitioningDelegate!

    
    private let topInset: CGFloat = 45

    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets.top = topInset
        
        topBarView_typed.topBarRightIcon.addAction({[weak self] in self?.dismiss(animated: true)})
        collectionView.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .top: view.safeAreaLayoutGuide.topAnchor])
        
    }
    
    

    override func loadView() {
        let view = HKView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .clear
        view.didMoveToSuperviewAction = { [weak self] in self?.becomeFirstResponder() }
        view.hitTestAction = {[weak self] in self?.hitTestView(point: $0, event: $1) }
        self.view = view
        
    }
    
    private func hitTestView(point: CGPoint, event: UIEvent?) -> UIView?{
        let convertedPoint = collectionView.convert(point, from: view)
        if collectionView.point(inside: convertedPoint, with: event){
            return collectionView
        }
        return nil
    }
    
    
    
   
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override var canResignFirstResponder: Bool{
        return true
    }
    
    private lazy var collectionView: ChatMessagesCollectionView = {
        return ChatMessagesCollectionView(user: user)
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




extension ChatViewController: ChatControllerProtocol{
    
    var topBarView: UIView{
        return topBarView_typed
    }
 
}
