//
//  Login_SignUp_ProfilePicture.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/31/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class Login_SignUp_ProfilePicture: SignUpFormVCTemplate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonView.setButtonText(to: "Continue")
        self.inputFormView.imageBrowseButton.addAction { [unowned self] in
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        infoObject.setProfileImage(to: image)
        inputFormView.imageView.image = image
        buttonView.enable()
        picker.dismiss()
    
    }
    
    
    override var nextScreenType: SignUpFormVCTemplate.Type{
        return Login_SignUp_UserName.self
    }
    
    override var preferredInputFormViewType: LoginInputFormView.LoginFormType{
        return .profileImageChooser
    }
    
    override func configureInputFormView(form: LoginInputFormView) {
        form.titleLabel.text = "Choose a Profile Picture"
    }
    
    
    
    
    
}
