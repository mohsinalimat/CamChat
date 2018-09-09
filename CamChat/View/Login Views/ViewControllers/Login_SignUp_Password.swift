//
//  Login_SignUp_Password.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit

class Login_SignUp_Password: SignUpFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.setButtonText(to: "Continue")
    
        
    
    }
    
    override var nextScreenType: SignUpFormVCTemplate.Type{
        return Login_SignUp_Email.self
    }
    
    override func respondToButtonViewTapped() {
        self.handleErrorWithOopsAlert {
            try self.infoObject.setPassword(to: self.inputFormView.topTextField.textField.text!)
            super.respondToButtonViewTapped()
        }
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .oneTextField
    }

    

    override func configureInputFormView(form: LoginInputFormView) {
        form.topTextField.setDescriptionText(to: "Password")
        form.topTextField.textField.textContentType = .password
        form.topTextField.textField.keyboardType = .asciiCapable
        form.titleLabel.text = "Choose a password"
        form.topDescriptionLabel.text = "Your password should be at least \(UserSignUpProgressionInfo.minimumPasswordLength) characters."
    }
    
}
