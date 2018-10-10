//
//  MemorySenderVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class MemorySenderVC: SearchTableVC{
    
    private let bottomBarHeight: CGFloat = 60
    private var customTransitioningDelegate: MemorySenderTransioningDelegate!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

    private var memories: [Memory]?
    
    private let photoVideoObjects: [PhotoVideoData]
    private let sendCompletionAction: ((MemorySenderVC) -> Void)?
    
    var userDidDismissMemorySenderAction: (() -> ())?
    
    convenience init(presenter: HKVCTransParticipator, memories: [Memory], sendCompletedAction: ((MemorySenderVC) -> Void)?){
        self.init(presenter: presenter, photoVideoObjects: memories.map{$0.info}, sendCompletedAction: sendCompletedAction)
        self.memories = memories
    }
    
    
    init(presenter: HKVCTransParticipator, photoVideoObjects: [PhotoVideoData], sendCompletedAction: ((MemorySenderVC) -> Void)?){
        self.sendCompletionAction = sendCompletedAction
        self.photoVideoObjects = photoVideoObjects
        super.init()
        self.customTransitioningDelegate = MemorySenderTransioningDelegate(presenter: presenter, presented: self)
        self.transitioningDelegate = customTransitioningDelegate
        view.backgroundColor = .clear
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.pinAllSides(addTo: view, pinTo: view)
        view.sendSubviewToBack(blur)
        
        backButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.left: 15])
        searchIcon.pin(addTo: view, anchors: [.left: backButton.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.left: 10])
        searchTextField.pin(addTo: view, anchors: [.left: searchIcon.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.left: 10])
        clearTextButton.pin(addTo: view, anchors: [.left: searchTextField.rightAnchor, .right: view.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.left: 10, .right: 10])
        
        let bottomBarPins = bottomBar.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor], constants: [.height: bottomBarHeight, .bottom: APP_INSETS.bottom])
        bottomBarBottomConstraint = bottomBarPins.bottom!
        
        bottomBarBackgroundView.pin(addTo: view, anchors: [.left: bottomBar.leftAnchor, .right: bottomBar.rightAnchor, .top: bottomBar.topAnchor, .height: bottomBar.heightAnchor], constants: [.height: APP_INSETS.bottom])
        view.bringSubviewToFront(bottomBar)
        [bottomBar, bottomBarBackgroundView].forEach{
            $0.transform = bottomBarInvisibleTransform
            $0.alpha = 0
        }
        
        
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil, using: {[weak self ] in self?.respondToKeyboardFrameDidChange(notification: $0)})
        
    }
    
    private lazy var bottomBarInvisibleTransform = CGAffineTransform(translationX: 0, y: APP_INSETS.bottom + bottomBarHeight)
    
    private var bottomBarBottomConstraint: NSLayoutConstraint!
    

    
    private func respondToKeyboardFrameDidChange(notification: Notification){
        let newKeyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeightOnScreen = UIScreen.main.bounds.height - newKeyboardFrame.minY
        let animationTime = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let newBottomConstant = -max(keyboardHeightOnScreen, APP_INSETS.bottom)
        
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: {
            self.bottomBarBottomConstraint.constant = newBottomConstant
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    private func respondToSelectedUsersChanged(to users: [User]){
        bottomBar.setWith(users: users)
        
        let views = [self.bottomBar, self.bottomBarBackgroundView]
        
        let action: () -> ()
     
        if users.isEmpty{
            action = {
                self.additionalSafeAreaInsets.bottom = 0
                views.forEach{
                    $0.transform = self.bottomBarInvisibleTransform
                    $0.alpha = 0
                }
            }
        } else {
            action = {
                self.additionalSafeAreaInsets.bottom = self.bottomBarHeight + 3

                views.forEach{
                    $0.transform = CGAffineTransform.identity
                    $0.alpha = 1
                }
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: action, completion: nil)
        
    }

    
    
    private lazy var backButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.arrowChevron.rotatedBy(._180)!.templateImage)
        x.pin(constants: [.height: 20, .width: 20])
        x.addAction({[weak self] in
            self?.searchTextField.resignFirstResponder()
            self?.dismiss()
            self?.userDidDismissMemorySenderAction?()
        })
        return x
    }()
    
    private lazy var searchIcon: BouncySearchIcon = {
        let x = BouncySearchIcon()
        x.pin(constants: [.height: 25, .width: 25])
        return x
    }()
    
    private lazy var searchTextField: UITextField = {
        let x = UITextField()
        x.keyboardAppearance = .dark
        x.autocorrectionType = .no
        x.tintColor = CCSearchConstants.searchTintColor
        x.attributedPlaceholder = NSAttributedString(string: "Send To...", attributes: [.font: CCSearchConstants.searchLabelFont, .foregroundColor: UIColor.gray(percentage: 0.7)])
        x.font = CCSearchConstants.searchLabelFont
        x.delegate = self
        x.textColor = CCSearchConstants.searchTintColor
        x.addTextDidChangeListener({[weak self] (newText) in
            guard let self = self else {return}
            self._tableView.searchTextChanged(to: newText)
            if self.searchTextField.hasValidText{
                self.setShowTextClearButtonTo(true)
            } else { self.setShowTextClearButtonTo(false) }
        })
        return x
    }()
    
    override var tableView: UITableView{
        return _tableView
    }
    
    private lazy var _tableView: MemorySenderTableView = {
        let tableView = MemorySenderTableView()
        tableView.selectedUsers.addChangeObserver(self, action: {[weak self] (users) in
            self?.respondToSelectedUsersChanged(to: users)
        })
        return tableView
    }()
    
    

    private lazy var clearTextButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.cancelButton)
        x.transform = CGAffineTransform(scaleX: 0.000001, y: 0.000001)
        x.addAction {[weak self] in
            self?.searchTextField.setTextTo(newText: "")
        }  
        x.pin(constants: [.height: 20, .width: 20])
        return x
    }()
    
    private lazy var bottomBar: MemorySenderBottomBar = {
        let x = MemorySenderBottomBar()
        
        x.sendButton.addAction { [weak self] in
            guard let self = self else {return}
            if let memories = self.memories {
                let request = MemoryBatchSendRequest(memories: memories, text: nil, users: self._tableView.selectedUsers.value)
                try! DataCoordinator.sendBatch(request: request)
            } else {
                for object in self.photoVideoObjects{
                    try! DataCoordinator.sendMessageUsingSingleMediaItem(object, receivers: self._tableView.selectedUsers.value)
                }
            }
            self.sendCompletionAction?(self)
        }
        return x
    }()
    
    private lazy var bottomBarBackgroundView: UIView = {
        let x = UIView()
        x.backgroundColor = BLUECOLOR
        return x
    }()
    
    private func setShowTextClearButtonTo(_ bool: Bool){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            let tinyScalVal: CGFloat = 0.00000001
            self.clearTextButton.transform = bool ? CGAffineTransform.identity : CGAffineTransform(scaleX: tinyScalVal, y: tinyScalVal)
        }, completion: nil)
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension MemorySenderVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchIcon.bounce()
    }
}



