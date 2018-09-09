//
//  LoginScrollVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit


class SignUpFormVCTemplate: LoginFormVCTemplate{
    var infoObject: UserSignUpProgressionInfo
    
    private lazy var nextScreen = nextScreenType.init(presenter: self, info: infoObject)
    
    var nextScreenType: SignUpFormVCTemplate.Type{
        return SignUpFormVCTemplate.self
    }
    
    required init(presenter: HKVCTransParticipator, info: UserSignUpProgressionInfo){
        
        self.infoObject = info
        super.init(presenter: presenter)
        buttonView.addAction({[unowned self] in self.respondToButtonViewTapped()})
    }
    
    
    
    
    /// It is the job of subclasses to set the info object with the info they've collected from the user and/or update Firestore all BEFORE they call super. It is also the responsibility of the very last signup screen to NOT call super and PRESENT THE MAIN INTERFACE instead.
    func respondToButtonViewTapped(){
        self.present(self.nextScreen)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}











class LoginFormVCTemplate: UIViewController, LoginInputFormViewDelegate{
    
    
    private var customTransitioningDelegate: LoginVCTransitioningDelegate!
    
    init(presenter: HKVCTransParticipator){
        super.init(nibName: nil, bundle: nil)
        self.customTransitioningDelegate = LoginVCTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = customTransitioningDelegate
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        view.setCornerRadius(to: 10)

        view.backgroundColor = .red
        
        inputFormView.invalidateIntrinsicContentSize()
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        activateTopTextFieldIfNeeded()
        super.viewWillAppear(animated)
    }
    
  
    
    

    
    func textFieldDidReturn(textField: LoginTextFieldView) {
        if textField === inputFormView.topTextField && inputFormView.formType == .twoTextFields{
            inputFormView.bottomTextField.textField.becomeFirstResponder()
        } else {
            buttonView.carryOutAction()
        }
    }
    
    func textFieldTextDidChange(textField: LoginTextFieldView, text: String?) {
        let topText = inputFormView.topTextField.textField.text
        let bottomText = inputFormView.bottomTextField.textField.text
        
        switch inputFormView.formType{
        case .oneTextField:
            if let text = topText{
                if !text.withTrimmedWhiteSpaces().isEmpty{
                    buttonView.enable()
                    return
                }
            }
            buttonView.disable()
            
        case .twoTextFields:
            if let topText = topText, let bottomText = bottomText{
                if !topText.withTrimmedWhiteSpaces().isEmpty && !bottomText.withTrimmedWhiteSpaces().isEmpty{
                    buttonView.enable()
                    return
                }
            }
            buttonView.disable()
            
        default: break
        }
    }
    
    
    
    private func activateTopTextFieldIfNeeded(){
        if !inputFormView.topTextField.textField.isFirstResponder && !inputFormView.topTextField.textField.isFirstResponder{
            inputFormView.topTextField.textField.becomeFirstResponder()
        }
    }
    

    
    
    
    @objc  private func respondToKeyboardFrameChange(notification: NSNotification){
        
        let keyboardFrame = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        let animationTime = notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! TimeInterval
        view.layoutIfNeeded()
        UIView.animate(withDuration: animationTime > 0 ? animationTime : 0.2) {
            
            let keyboardHeightOnScreen = max(self.view.bounds.height - keyboardFrame.minY, 0)
            self.additionalSafeAreaInsets.bottom = max(keyboardHeightOnScreen - APP_INSETS.bottom, 0)
            
            
            self.adaptScrollViewContentSizeToContentIfNeeded()

            self.view.layoutIfNeeded()
        }
    }
    
    private func adaptScrollViewContentSizeToContentIfNeeded(){
        self.scrollView.contentSize = self.view.safeAreaLayoutGuide.layoutFrame.size
        self.scrollView.contentSize.height -= self.buttonView.intrinsicContentSize.height
        
        let desiredScrollingSpace = self.inputFormView.intrinsicContentSize.height + 20
        if scrollView.contentSize.height < desiredScrollingSpace{
            self.scrollView.contentSize.height = desiredScrollingSpace
            
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adaptScrollViewContentSizeToContentIfNeeded()
    }
    
    
    private func setUpViews(){
        view.addSubview(scrollView)
        view.addSubview(buttonView)
        view.addSubview(backButton)
        scrollView.addSubview(inputFormView)
        scrollView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor, .bottom: view.bottomAnchor])
        
        buttonView.pin(anchors: [.left: view.leftAnchor, .bottom: view.safeAreaLayoutGuide.bottomAnchor, .right: view.rightAnchor])
        backButton.pin(anchors: [.left: view.leftAnchor, .top: view.topAnchor], constants: [.left: 15, .top: 18 + Variations.notchHeight])
        
        inputFormView.pin(anchors: [.centerX: scrollView.contentLayoutGuide.centerXAnchor, .centerY: scrollView.contentLayoutGuide.centerYAnchor])
        
        
        bottomSeamHider.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor], constants: [.height: APP_INSETS.bottom])
        
        view.layoutIfNeeded()

    }
    
    
 
    

    lazy var inputFormView: LoginInputFormView = {
        let x = LoginInputFormView(formType: preferredInputFormViewType)
        configureInputFormView(form: x)
        x.delegate = self

        return x
    }()
    
    var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .twoTextFields
    }
    
    func configureInputFormView(form: LoginInputFormView){
        
    }
    
    lazy var scrollView: HKScrollView = {
        let x = HKScrollView()
        x.delaysContentTouches = false
        x.backgroundColor = .white
        x.alwaysBounceVertical = true
        x.contentSize = self.view.safeAreaLayoutGuide.layoutFrame.size
        x.contentSize.height -= self.buttonView.intrinsicContentSize.height
        x.contentInset.bottom = buttonView.intrinsicContentSize.height
        return x
    }()
    
    var buttonView: LoginButtonView = {
        let x = LoginButtonView()
        x.disable()
        return x
    }()
    

    
    lazy var backButton: UIView = {
        let x = BouncyImageButton(image: AssetImages.arrowChevron.rotatedBy(._180)!.templateImage)
        x.tintColor = BLUECOLOR
        x.pin(constants: [.height: 23, .width: 23])
        x.addAction { [unowned self] in self.respondToBackButtonTapped()}
        return x
    }()
    
 
    
    func respondToBackButtonTapped(){
        inputFormView.topTextField.textField.resignFirstResponder()
        inputFormView.bottomTextField.textField.resignFirstResponder()
        self.dismiss(animated: true)
        
    }
    
    
    ///Because at this point I just wanna be done with these login screens🙄.
    private lazy var bottomSeamHider: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        return x
    }()
    
    
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    

}



