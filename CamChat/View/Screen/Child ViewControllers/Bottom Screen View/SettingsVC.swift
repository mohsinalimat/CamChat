//
//  SettingsVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit




class SettingsViewController: UIViewController, UIGestureRecognizerDelegate{
    private weak var screen: Screen?
    init(screen: Screen){
        self.screen = screen
        super.init(nibName: nil, bundle: nil)
    }
    
    
    private let transformEquation = CGLinearEquation(xy(0, 70), xy(1, 0))!
    
    func gradientDidChange(to gradient: CGFloat){
        let transform = transformEquation[gradient]
        contentObjectsHolderView.transform = CGAffineTransform(translationX: 0, y: transform)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.scrollToTop()
    }
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setUpViews()
    }
    
 
    
    
    
    private func setUpViews(){
        bluryView.pinAllSides(addTo: view, pinTo: view)
        contentObjectsHolderView.pinAllSides(addTo: view, pinTo: view)
        scrollViewHolderView.pinAllSides(addTo: contentObjectsHolderView, pinTo: contentObjectsHolderView)
        dismissButton.pin(addTo: contentObjectsHolderView, anchors: [.left: contentObjectsHolderView.leftAnchor, .top: contentObjectsHolderView.topAnchor], constants: [.left: 15, .top: APP_INSETS.top + 15])

    }
    
    
 
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentView.frame.height)
    }
    
  
    
    private var shouldCheckForDisablingScroll: (shouldCheck: Bool, previousContentOffset: CGPoint?) = (false, nil)
    
   
    
    
    private var topMaskGradientView: HKGradientView?
    
    private lazy var scrollViewHolderView: UIView = {
        let x = HKView()
        scrollView.pinAllSides(addTo: x, pinTo: x)
        
        let gradientView = HKGradientView()
        topMaskGradientView = gradientView
        
        x.mask = gradientView
        
        x.layoutSubviewsAction = {[unowned x, unowned gradientView, weak view] in
            gradientView.frame = x.bounds
            let colors = [.black, .black, .black, UIColor.black.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0)].map{$0.cgColor}
            
            gradientView.gradientLayer.colors = colors
            let thirdEndPoint = Double((view!.bounds.height - (view!.safeAreaInsets.bottom)) / view!.bounds.height)
            
            let fourthEndPoint = thirdEndPoint + Double(30 / view!.bounds.height)
            
            gradientView.gradientLayer.locations = [
                NSNumber(value: 0),
                NSNumber(value: Double((APP_INSETS.top + 100) / view!.bounds.height)),
                NSNumber(value: thirdEndPoint),
                NSNumber(value: fourthEndPoint),
                NSNumber(value: 1)
            ]
        }
        return x
    }()
    
    private let contentObjectsHolderView = UIView()
    
    private (set) lazy var scrollView: HKScrollView = {
        let x = SettingsScrollView()
        x.contentInsetAdjustmentBehavior = .never
        x.contentInset.top = APP_INSETS.top
        x.delegate = self
        x.panGestureRecognizer.stopInterferingWithTouchesInView()
        x.panGestureRecognizer.addTarget(self, action: #selector(respondToGesture(gesture:)))
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
        x.addAction({[weak screen = screen] in screen?.verticalScrollInteractor.snapGradientTo(screen: .center, animated: true)})
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

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}



// MARK: - SCROLLING



extension SettingsViewController: UIScrollViewDelegate{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.isScrollEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.isScrollEnabled = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top{
            shouldCheckForDisablingScroll = (true, scrollView.contentOffset)
        } else {
            shouldCheckForDisablingScroll = (false, nil)
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustMaskForScrollViewScrolled(scrollView)
        checkScrollViewForDisabling(scrollView)
    }
    
    private func checkScrollViewForDisabling(_ scrollView: UIScrollView){
        if shouldCheckForDisablingScroll.shouldCheck{
            
            defer{ shouldCheckForDisablingScroll = (false, nil) }
            
            if scrollView.contentOffset.y < shouldCheckForDisablingScroll.previousContentOffset!.y{
                
                scrollView.isScrollEnabled = false
                screen!.verticalScrollInteractor.startAcceptingTouches()
                
                return
            }
        }
        if screen!.verticalScrollInteractor.currentGradientPercentage == 1{
            screen!.verticalScrollInteractor.stopAcceptingTouches()
            scrollView.isScrollEnabled = true
        }
    }
    
    
    private func adjustMaskForScrollViewScrolled(_ scrollView: UIScrollView){
        let equation = CGLinearEquation(xy(-scrollView.adjustedContentInset.top, 1), xy(-scrollView.adjustedContentInset.top + 50, 0), min: 0, max: 1)!
        let num = equation[scrollView.contentOffset.y]
        topMaskGradientView?.gradientLayer.colors?[0] = UIColor.black.withAlphaComponent(num).cgColor
    }
    
    
    @objc private func respondToGesture(gesture: UIPanGestureRecognizer){
        if gesture.state == .ended{
            scrollView.isScrollEnabled = true
            shouldCheckForDisablingScroll = (false, nil)
        }
    }
    
    
    
    
    
    
    
}


private class SettingsScrollView: HKScrollView{
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl{return true}
        return super.touchesShouldCancel(in: view)
    }
}



