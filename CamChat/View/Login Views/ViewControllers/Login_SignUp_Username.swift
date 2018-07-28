//
//  Login_SignUp_Name.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit

class Login_SignUp_UserName: LoginFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.setButtonText(to: "Continue")

        buttonView.addAction {
            self.present(Login_SignUp_Password(), animated: false, completion: nil)
        }
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .oneTextField
    }
    
    private let bottomDescription = "By tapping Sign Up & Accept, you acknowledge that you have read the Privacy Policy and agree to the Terms of Service."
    
    override func configureInputFormView(form: LoginInputFormView) {
        form.topDescriptionLabel.text = bottomDescription
        form.topTextField.setDescriptionText(to: "Username")
        form.topTextField.textField.autocapitalizationType = .none
        form.titleLabel.text = "Pick a username"
        form.topDescriptionLabel.text = "Your username is how friends add you on Camchat."
    }
}
