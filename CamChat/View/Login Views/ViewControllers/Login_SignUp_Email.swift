//
//  Login_SignUp_Email.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class Login_SignUp_Email: SignUpFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.setButtonText(to: "Continue")
        
     
    }
    
    override func respondToButtonViewTapped() {
        
        self.handleErrorWithOopsAlert { [unowned self, unowned buttonView, unowned inputFormView] in
            try self.infoObject.setEmail(to: self.inputFormView.topTextField.textField.text!)
            
            inputFormView.dismissKeyboard()
            UIApplication.shared.beginIgnoringInteractionEvents()
            buttonView.startShowingLoadingIndicator()
            
            DataCoordinator.signUpAndLogIn(signUpProgressionInfo: self.infoObject.output!, completion: { (callback) in
                
                UIApplication.shared.endIgnoringInteractionEvents()
                buttonView.stopShowingLoadingIndicator()
                
                switch callback{
                case .success:
                    InterfaceManager.shared.transitionToMainInterface()
                case .failure(let error):
                    self.presentOopsAlert(description: error.localizedDescription)
                }
            })
        }
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .oneTextField
    }
    
    

    
    override func configureInputFormView(form: LoginInputFormView) {
        form.topTextField.setDescriptionText(to: "Email")
        form.topTextField.textField.autocorrectionType = .no
        form.topTextField.textField.spellCheckingType = .no
        form.topTextField.textField.textContentType = .emailAddress
        form.topTextField.textField.keyboardType = .emailAddress
        form.titleLabel.text = "What's your email?"
    }
}


