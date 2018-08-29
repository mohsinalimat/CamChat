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
        self.handleErrorWithOopsAlert {
            try self.infoObject.setEmail(to: self.inputFormView.topTextField.textField.text!)
            Firebase.signUpAndSignIn(with: self.infoObject, errorHandler: { (error) in
                if let error = error {
                    self.presentOopsAlert(description: error.localizedDescription)
                } else {
                    self.present(Screen.main, animated: true, completion: nil)
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


