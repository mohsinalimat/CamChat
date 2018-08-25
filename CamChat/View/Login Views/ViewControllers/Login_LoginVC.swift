//
//  Login_LoginVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

class Login_LoginVC: LoginFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonView.setButtonText(to: "Log In")
        buttonView.addAction {
            self.present(Screen.main, animated: true, completion: nil)
        }
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .twoTextFields
    }
    

    
    override func configureInputFormView(form: LoginInputFormView) {
        form.topTextField.setDescriptionText(to: "email or username")
        form.bottomTextField.setDescriptionText(to: "password")
        form.titleLabel.text = "Log In"
        form.bottomDescriptionLabel.text = "Forgot password?"
        form.bottomDescriptionLabel.textAlignment = .center
        form.bottomDescriptionLabel.textColor = BLUECOLOR
        form.bottomDescriptionLabel.font = SCFonts.getFont(type: .medium, size: 12)
        
        
        form.topTextField.textField.textContentType = .emailAddress
        form.topTextField.textField.keyboardType = .emailAddress
        form.bottomTextField.textField.isSecureTextEntry = true
        form.bottomTextField.textField.textContentType = .password
    }

    @objc override func respondToBackButtonPressed(gesture: UITapGestureRecognizer) {
        
        inputFormView.topTextField.textField.resignFirstResponder()
        inputFormView.bottomTextField.textField.resignFirstResponder()
        super.respondToBackButtonPressed(gesture: gesture)
    }
    
    
    
    
    
    
    
}















