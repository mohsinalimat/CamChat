//
//  LoginScrollVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit



/// TODO: increase the hit area of the back button
class LoginFormVCTemplate: UIViewController, LoginInputFormViewDelegate{
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()

        view.backgroundColor = .red
        
        inputFormView.invalidateIntrinsicContentSize()
        view.layoutIfNeeded()
        inputFormView.delegate = self
        inputFormView.topTextField.textField.becomeFirstResponder()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(respondToApplicationWillEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        activateTopTextFieldIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
                if !text.removeWhiteSpaces().isEmpty{
                    buttonView.enable()
                    return
                }
            }
            buttonView.disable()
            
        case .twoTextFields:
            if let topText = topText, let bottomText = bottomText{
                if !topText.removeWhiteSpaces().isEmpty && !bottomText.removeWhiteSpaces().isEmpty{
                    buttonView.enable()
                    return
                }
            }
            buttonView.disable()
        }
    }
    
    @objc private func respondToApplicationWillEnterForegroundNotification(){
        activateTopTextFieldIfNeeded()
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
        UIView.animate(withDuration: animationTime) {
            
            let originalInsets = self.view.safeAreaInsets.bottom - self.additionalSafeAreaInsets.bottom
            
            self.additionalSafeAreaInsets.bottom = keyboardFrame.height - originalInsets
            self.scrollView.contentSize = self.view.safeAreaLayoutGuide.layoutFrame.size
            self.scrollView.contentSize.height -= self.buttonView.intrinsicContentSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let desiredScrollingSpace = self.inputFormView.intrinsicContentSize.height + 20
        if scrollView.contentSize.height < desiredScrollingSpace{
            self.scrollView.contentSize.height = desiredScrollingSpace
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    private func setUpViews(){
        view.addSubview(scrollView)
        view.addSubview(buttonView)
        view.addSubview(backButton)
        scrollView.addSubview(inputFormView)
        scrollView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor, .bottom: view.bottomAnchor])
        
        buttonView.pin(anchors: [.left: view.leftAnchor, .bottom: view.safeAreaLayoutGuide.bottomAnchor, .right: view.rightAnchor])
        backButton.pin(anchors: [.left: view.leftAnchor, .top: view.safeAreaLayoutGuide.topAnchor], constants: [.left: 15, .top: 18])
        
        inputFormView.pin(anchors: [.centerX: scrollView.contentLayoutGuide.centerXAnchor, .centerY: scrollView.contentLayoutGuide.centerYAnchor])
        view.layoutIfNeeded()

    }
    
    
 
    

    lazy var inputFormView: LoginInputFormView = {
        let x = LoginInputFormView(formType: preferredInputFormViewType)
        configureInputFormView(form: x)
        return x
    }()
    
    var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .twoTextFields
    }
    
    func configureInputFormView(form: LoginInputFormView){
        
    }
    
    lazy var scrollView: HKScrollView = {
        let x = HKScrollView()
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
    
    lazy var backButton: UIImageView = {
        let x = UIImageView(image: AssetImages.arrowChevron)
        x.transform = CGAffineTransform(rotationAngle: .pi)
        x.contentMode = .scaleAspectFit
        x.tintColor = BLUECOLOR
        x.pin(constants: [.height: 23, .width: 23])
        x.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToBackButtonPressed(gesture:)))
        x.addGestureRecognizer(gesture)
        return x
    }()
    
    @objc func respondToBackButtonPressed(gesture: UITapGestureRecognizer){
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
}
