//  Screen.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit





class Screen: UIViewController, PageScrollingInteractorDelegate, SCScrollViewDelegate{
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setUpViews()
        
        
        // This is only to ensure they are initialized right now, since they are being lazily loaded. Page Scrolling Interactors are active by default.
        verticalScrollInteractor.activate()
        horizontalScrollInteractor.activate()
        
    }
    
    
    
    
    
    
    
    
    
    lazy var leftScreen: SCScrollView = {
        let x = ChatTableView()
        self.addChild(x)
        x.delegate = self
        x.additionalSafeAreaInsets.bottom = subviewsBottomSafeAreaInset
        x.additionalSafeAreaInsets.top = topBarHeight
        return x
    }()
    
    lazy var centerScreen: UIViewController = {
        let x = CameraVC()
        self.addChild(x)
        x.additionalSafeAreaInsets.bottom = subviewsBottomSafeAreaInset
        x.additionalSafeAreaInsets.top = topBarHeight
        return x
    }()
    
    lazy var rightScreen: SCScrollView = {
        let x = PhotoLibraryTableView()
        self.addChild(x)
        x.delegate = self
        x.additionalSafeAreaInsets.bottom = subviewsBottomSafeAreaInset
        x.additionalSafeAreaInsets.top = topBarHeight
        return x
    }()
    
     lazy var bottomScreen: UIViewController = {
        let x = SettingsViewController()
        self.addChild(x)
        return x
    }()
    
    let topSearchBar: SCSearchBar = {
        let x = SCSearchBar()
        x.isUserInteractionEnabled = false
        return x
    }()
    
    lazy var centerScreenCoverView: UIView = {
        let x = UIView()
        x.isUserInteractionEnabled = false
        x.backgroundColor = UIColor.black.withAlphaComponent(0)
        return x
    }()

    lazy var topGradientView: GradientView = {
        let x = GradientView(colors: [UIColor.black.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0)])
        x.alpha = 0
        return x
    }()
    
    lazy var bottomGradientView: GradientView = {
        let  x = GradientView(colors: [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.5)])
        x.alpha = 0
        return x
    }()
    
    
    lazy var topBar: ScreenTopBar = {
        let x = ScreenTopBar()
        return x

    }()
    
    lazy var topBarBottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor(red: 200, green: 200, blue: 200)
        x.applyShadow(width: 0.1)
        return x
    }()
    
    

    
    lazy var topBarLayoutGuide: UILayoutGuide = UILayoutGuide()
 
    lazy var navigationView: ButtonNavigationView = {
        let x = ButtonNavigationView()
        x.setButtonActions(to: self.respondToNavigationButtonTapped)
        return x
    }()
    
    lazy var horizontalScrollInteractor: PageScrollingInteractor = {
        let x = PageScrollingInteractor(delegate: self, direction: .horizontal)
        x.onlyAcceptInteractionInSpecifiedDirection = true
        return x
    }()
    
    lazy var verticalScrollInteractor: PageScrollingInteractor = {
        let x = PageScrollingInteractor(delegate: self, direction: .vertical)
        x.onlyAcceptInteractionInSpecifiedDirection = true
        return x
    }()

    

    var shouldChangeNavViewSize = true

    
    
    let topBarHeight: CGFloat = 45
    let subviewsBottomSafeAreaInset: CGFloat = 100
    
    
    var topLayoutGuideHeightConstraint: NSLayoutConstraint!
    var topLayoutGuideTopConstraint: NSLayoutConstraint!
    
    var bottomScreenTopAnchor: NSLayoutConstraint!
    var rightScreenLeftAnchor: NSLayoutConstraint!
    var leftScreenRightAnchor: NSLayoutConstraint!
    
    
    var leftScreenColor = BLUECOLOR
    var rightScreenColor = REDCOLOR
    var bottomScreenColor = UIColor.orange
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
