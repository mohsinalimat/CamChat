//
//  Login_SignUp_Name.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class Login_SignUp_Name: SignUpFormVCTemplate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        buttonView.setButtonText(to: "Sign Up & Accept")
        
        
    }
    
    override var nextScreenType: SignUpFormVCTemplate.Type {
        return Login_SignUp_UserName.self
    }
    
    override func respondToButtonViewTapped() {
        self.handleErrorWithOopsAlert {
            try self.infoObject.setFirstName(to: self.inputFormView.topTextField.textField.text!)
            try self.infoObject.setLastName(to: self.inputFormView.bottomTextField.textField.text!)
            super.respondToButtonViewTapped()
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
    
    override func respondToBackButtonTapped() {
        inputFormView.topTextField.textField.resignFirstResponder()
        inputFormView.bottomTextField.textField.resignFirstResponder()
        super.respondToBackButtonTapped()
    }
    
    
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .twoTextFields
    }
    
    
}
