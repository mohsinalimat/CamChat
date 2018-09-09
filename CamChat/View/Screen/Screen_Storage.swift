//  Screen.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit





class Screen: UIViewController, PageScrollingInteractorDelegate, SCScrollViewDelegate, UIGestureRecognizerDelegate{
    
    
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        view.clipsToBounds = true
        
        // This is only to ensure they are initialized right now, since they are being lazily loaded. Page Scrolling Interactors start accepting touches by default.
        verticalScrollInteractor.startAcceptingTouches()
        horizontalScrollInteractor.startAcceptingTouches()        
    }
    

    

    lazy var leftScreen: SCScrollView = {
        let x = ConversationsTableVC()
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
        let x = PhotoLibraryCollectionVC(screen: self)
        self.addChild(x)
        x.delegate = self
        x.additionalSafeAreaInsets.bottom = subviewsBottomSafeAreaInset
        x.additionalSafeAreaInsets.top = topBarHeight
        
        return x
    }()
    
     lazy var bottomScreen: SettingsViewController = {
        let x = SettingsViewController(screen: self)
        x.additionalSafeAreaInsets.bottom = subviewsBottomSafeAreaInset
        self.addChild(x)
        x.view.alpha = 0
        return x
    }()

    lazy var centerScreenCoverView: UIView = {
        let x = UIView()
        x.isUserInteractionEnabled = false
        x.backgroundColor = UIColor.black.withAlphaComponent(0)
        return x
    }()

    lazy var topGradientView: HKGradientView = {
        let x = HKGradientView(colors: [UIColor.black.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0)])
        x.alpha = 0
        return x
    }()
    
    lazy var bottomGradientView: HKGradientView = {
        let  x = HKGradientView(colors: [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.5)])
        x.alpha = 0
        return x
    }()
    
   
    
    lazy var topBar_typed: ScreenTopBar = {
        let x = ScreenTopBar(delegate: self)
        return x
    }()
    
    
    lazy var topBarBottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor(red: 200, green: 200, blue: 200)
        x.applyShadow(width: 0.1)
        return x
    }()
    

    
 
    lazy var navigationView: ButtonNavigationView = {
        let x = ButtonNavigationView(delegate: self)
        return x
    }()
    
    lazy var horizontalScrollInteractor: PageScrollingInteractor = {
        let x = PageScrollingInteractor(delegate: self, direction: .horizontal)
        x.onlyAcceptInteractionInSpecifiedDirection = true
        return x
    }()
    
    lazy var verticalScrollInteractor: PageScrollingInteractor = {
        let x = PageScrollingInteractor(delegate: self, direction: .vertical)
        x.multiplier = 1.4
        x.gesture.delegate = self
        x.onlyAcceptInteractionInSpecifiedDirection = true
        return x
    }()
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
   

    

    var shouldChangeNavViewSize = true

    
    
    let topBarHeight: CGFloat = 45
    let subviewsBottomSafeAreaInset: CGFloat = 100
    
    
    var topBarHeightConstraint: NSLayoutConstraint!
    var topBarTopContraint: NSLayoutConstraint!
    
    var rightScreenLeftAnchor: NSLayoutConstraint!
    var leftScreenRightAnchor: NSLayoutConstraint!
    
    
    var leftScreenColor = BLUECOLOR
    var rightScreenColor = REDCOLOR
    
    
    
    
    
    
    
    let navigationViewBackingAlphaEquation = CGLinearEquation(xy(-1, 1), xy(-0.8, 0), min: 0, max: 1)!
    
    let navigationViewTintColorEquation = CGLinearEquation(xy(-1, 190), xy(0, 255), min: 190, max: 255)!
    
    let navigationButtonsShadowAlphaEquation = CGQuadEquation(xy(-1, 0), xy(0, 1), xy(1, 0), min: 0, max: 1)!
    let bottomGradientViewAlpha_horizontal = CGLinearEquation(xy(0, 0), xy(1, 1), min: 0, max: 1)!
    
    let backgroundViewAlphaEquation = CGQuadEquation(xy(-0.7, 1), xy(0, 0), xy(0.7, 1), min: 0, max: 1)!
    


    
    
    

    
    
    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }

}
