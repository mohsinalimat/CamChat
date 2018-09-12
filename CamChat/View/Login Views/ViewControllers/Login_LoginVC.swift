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
        buttonView.addAction { [unowned self] in self.handleButtonViewTapped()}
    }
    
    private func handleButtonViewTapped(){
        let email = self.inputFormView.topTextField.textField.text!
        let password = self.inputFormView.bottomTextField.textField.text!
        
        self.handleErrorWithOopsAlert {
            let loginInfo = try LoginInfo(email: email, password: password)
            
            self.inputFormView.dismissKeyboard()
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.buttonView.startShowingLoadingIndicator()
            
            DataCoordinator.logIn(info: loginInfo, completion: { (callback) in
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.buttonView.stopShowingLoadingIndicator()
                
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
        return .twoTextFields
    }
    

    
    override func configureInputFormView(form: LoginInputFormView) {
        form.topTextField.setDescriptionText(to: "email")
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
    override func respondToBackButtonTapped() {
        inputFormView.dismissKeyboard()
        super.respondToBackButtonTapped()
    }
    
    
    
    
    
}















