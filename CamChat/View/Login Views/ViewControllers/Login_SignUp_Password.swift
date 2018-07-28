//
//  Login_SignUp_Password.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit

class Login_SignUp_Password: LoginFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.setButtonText(to: "Continue")
        
        buttonView.addAction {
            self.present(Login_SignUp_Email(), animated: false, completion: nil)
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
        form.topDescriptionLabel.text = "Your password should be at least 8 characters."
    }
    
}
