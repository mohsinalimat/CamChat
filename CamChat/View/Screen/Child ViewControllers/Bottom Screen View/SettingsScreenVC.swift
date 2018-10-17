//
//  SettingsScreenVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class SettingsScreenVC: UITableViewController{
    
    var screenTitle: String{
        return "NO TITLE SPECIFIED"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = screenTitle
        tableView.rowHeight = 45
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    
    private lazy var dismissButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.arrowChevron.rotatedBy(._180)!.templateImage)
        x.pin(constants: [.height: 20, .width: 20])
        x.activationArea = { [weak x] in
            return x?.bounds.inset(by: UIEdgeInsets(allInsets: -20))
        }
        x.addAction {[weak self] in self?.dismiss() }
        x.tintColor = BLUECOLOR
        return x
    }()
    
}
