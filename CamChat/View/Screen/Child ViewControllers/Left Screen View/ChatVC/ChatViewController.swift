//
//  ChatViewController.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatViewController: UIViewController{
    
    private let topInset: CGFloat = 50

    init(){
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = slideTransitionDelegate
    }

    
    
    private lazy var slideTransitionDelegate = SlideInTransitioningDelegate(viewController: self, direction: .left)
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        topBarLayoutGuide.pin(addTo: view, anchors: [.top: view.safeAreaLayoutGuide.topAnchor, .left: view.leftAnchor, .right: view.rightAnchor], constants: [.height: topInset])
        collectionView.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .top: topBarLayoutGuide.bottomAnchor])
        topLabel.pin(addTo: view, anchors: [.centerX: topBarLayoutGuide.centerXAnchor, .centerY: topBarLayoutGuide.centerYAnchor])
        topBarLeftIcon.pin(addTo: view, anchors: [.centerY: topBarLayoutGuide.centerYAnchor, .left: topBarLayoutGuide.leftAnchor], constants: [.left: 10])
        topBarRightIcon.pin(addTo: view, anchors: [.centerY: topBarLayoutGuide.centerYAnchor, .right: topBarLayoutGuide.rightAnchor], constants: [.right: 10])
        
        
    }
    
    

    override func loadView() {
        let view = HKView()
        view.backgroundColor = BLUECOLOR
        view.didMoveToSuperviewAction = {
            self.becomeFirstResponder()
        }
        view.isUserInteractionEnabled = true
        self.view = view
        
    }
    
    
    
   
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override var canResignFirstResponder: Bool{
        return true
    }
    
    private lazy var collectionView: ChatMessagesCollectionView = {
        return ChatMessagesCollectionView()
    }()
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        x.font = SCFonts.getFont(type: .medium, size: 20)
        x.text = "Pharez"
        x.textColor = .white
        return x
    }()

    private lazy var topBarRightIcon: BouncyButton = {
        let x = BouncyButton(image: AssetImages.arrowChevron)
        x.pin(constants: [.height: 20, .width: 20])
        x.addAction({
            self.dismiss(animated: true, completion: nil)
        })
        return x
    }()
    
    private lazy var topBarLeftIcon: BouncyButton = {
        let x = BouncyButton(image: AssetImages.threeLineMenuIcon)
        x.pin(constants: [.height: 20, .width: 20])
        return x
    }()
    

   
    
    private lazy var topBarLayoutGuide = UILayoutGuide()
    
    private lazy var accessoryView: ChatKeyboardShortcutView = {
        return ChatKeyboardShortcutView()
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








