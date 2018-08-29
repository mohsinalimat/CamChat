//
//  LoginVCMain.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/28/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit



class Login_MainVC: UIViewController{
    
    private let buttonHeight: CGFloat = 80
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        
        
        
        signUpButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor], constants: [.height: buttonHeight])
        
        loginButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: signUpButton.topAnchor], constants: [.height: buttonHeight])
        
        imageLayoutGuide.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor, .bottom: loginButton.topAnchor])
        
        ghostImage.pin(addTo: view, anchors: [.centerX: imageLayoutGuide.centerXAnchor, .centerY: imageLayoutGuide.centerYAnchor], constants: [.width: 70, .height: 70])
        
    }
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{return true}
    
    
    
    private lazy var ghostImage: UIImageView = {
        let x = UIImageView(image: AssetImages.snapchatGhost)
        
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    private lazy var imageLayoutGuide: UILayoutGuide = {
        let x = UILayoutGuide()
        return x
    }()
    
    private lazy var loginScreen = Login_LoginVC(presenter: self)
    private lazy var signUpScreen = Login_SignUp_Name.init(presenter: self, info: UserSignUpProgressionInfo())
    
    private lazy var loginButton: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.label.text = "LOG IN"
        x.backgroundColor = REDCOLOR
        x.addAction { [unowned self] in
            
            self.present(self.loginScreen, animated: true, completion: nil)
        }
        return x
    }()
    
    
    
    private lazy var signUpButton: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.label.text = "SIGN UP"
        x.backgroundColor = BLUECOLOR
        x.addAction { [unowned self] in
            self.present(self.signUpScreen, animated: true, completion: nil)
        }
        return x
    }()
}



