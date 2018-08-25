//
//  SettingsVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class SettingsViewController: UIViewController, UIGestureRecognizerDelegate{
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setUpViews()
    }
    private func setUpViews(){
        bluryView.pinAllSides(addTo: view, pinTo: view)
        scrollView.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .top: view.topAnchor, .bottom: view.bottomAnchor])
        dismissButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .top: view.topAnchor], constants: [.left: 15, .top: APP_INSETS.top + 15])

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentView.frame.height)
    }
    
    private lazy var scrollView: HKScrollView = {
        let x = SettingsScrollView()
        x.contentInsetAdjustmentBehavior = .never
        x.contentInset.top = APP_INSETS.top
        contentView.pin(addTo: x, anchors: [.top: x.contentLayoutGuide.topAnchor, .left: x.contentLayoutGuide.leftAnchor, .right: x.contentLayoutGuide.rightAnchor])
        
        
        // This is just an arbitrary length to avoid ugly autolayout console errors. The real size will be set in viewDidLayoutSubviews.
        x.contentSize = CGSize(width: 1000, height: 1000)
        x.showsVerticalScrollIndicator = false
        x.alwaysBounceVertical = true
        x.delaysContentTouches = false
        x.contentOffset.y = -x.adjustedContentInset.top
        return x
    }()
    
    private lazy var dismissButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.xIcon)
        x.applyShadow(width: 5)
        x.pin(constants: [.height: 30, .width: 30])
        x.addAction({[unowned screen = Screen.main] in screen.verticalScrollInteractor.snapGradientTo(screen: .center, animated: true)})
        return x
    }()
    
    private lazy var contentView: SettingsScrollContentView = {
        let x = SettingsScrollContentView(vcOwner: self)
        return x
    }()
    
    
    private lazy var bluryView: UIVisualEffectView = {
        let x = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return x
    }()

}


private class SettingsScrollView: HKScrollView{
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl{return true}
        return super.touchesShouldCancel(in: view)
    }
}



