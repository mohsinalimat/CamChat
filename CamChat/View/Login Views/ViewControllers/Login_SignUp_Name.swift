//
//  Login_SignUp_Name.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class Login_SignUp_Name: LoginFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonView.setButtonText(to: "Sign Up & Accept")
        buttonView.addAction {
            self.present(Login_SignUp_UserName(), animated: false, completion: nil)
        }
        
        
    }
    
    private let bottomDescription = "By tapping Sign Up & Accept, you acknowledge that you have read the Privacy Policy and agree to the Terms of Service."
    

    
    override func configureInputFormView(form: LoginInputFormView) {
        form.topDescriptionLabel.text = bottomDescription
        form.topTextField.setDescriptionText(to: "First Name")
        form.bottomTextField.setDescriptionText(to: "Last Name")
        form.topTextField.textField.textContentType = .name
        form.bottomTextField.textField.autocapitalizationType = .words
        form.bottomTextField.textField.autocapitalizationType = .words
        form.titleLabel.text = "What's your name?"
        form.bottomDescriptionLabel.text = bottomDescription
    }
    
    @objc override func respondToBackButtonPressed(gesture: UITapGestureRecognizer) {
        
        inputFormView.topTextField.textField.resignFirstResponder()
        inputFormView.bottomTextField.textField.resignFirstResponder()
        
        super.respondToBackButtonPressed(gesture: gesture)
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .twoTextFields
    }
    
    
}
