//
//  SettingsNavigationVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class SettingsNavigationVC: UINavigationController{
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        viewControllers.append(self.rootViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setCornerRadius(to: 7)
        navigationBar.tintColor = BLUECOLOR
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: CCFonts.getFont(type: .bold, size: 20), .foregroundColor: BLUECOLOR]
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
    
    var rootViewController: UIViewController{
        return UIViewController()
    }
    
}

