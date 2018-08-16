//
//  Screen_Interaction.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


extension Screen{
    
    
    func SCScrollViewDidScroll(scrollView: SCScrollView, topContentOffset: CGFloat) {
        guard let topBarHeightConstraint = topBarHeightConstraint else {return}
        
        let actualOutset = max(topContentOffset, 0) - APP_INSETS.top
        let totalOutset = topBarHeight
        
        if actualOutset >= totalOutset{
            
            let extraOutset = actualOutset - totalOutset
            topGradientView.alpha = 0
            topBarHeightConstraint.constant = actualOutset
            statusBar.frame.origin.y = extraOutset * 0.3
            self.view.layoutIfNeeded()
            
        } else {
            adjustTopGradientLayerViewTo_ScrollViewScrolled(scrollView: scrollView)
        }
    }
    
    
    
    func respondToNavigationButtonTapped(type: ButtonNavigationView.ButtonType){
        
        
        if verticalScrollInteractor.currentlyFullyVisibleScreen == .last && type != .cameraCapture{
            shouldChangeNavViewSize = false
            verticalScrollInteractor.snapGradientTo(screen: .center, animated: false)
            shouldChangeNavViewSize = true
        }
        
        switch type{
        case .cameraCapture:
            verticalScrollInteractor.snapGradientTo(screen: .center, animated: true)
            horizontalScrollInteractor.snapGradientTo(screen: .center, animated: true)
        case .chat:
            horizontalScrollInteractor.snapGradientTo(screen: .first, animated: true)
        case .photoLibrary:
            horizontalScrollInteractor.snapGradientTo(screen: .last, animated: true)
        case .settings:
            verticalScrollInteractor.snapGradientTo(screen: .last, animated: true)
        }
    }
    
    
    func gradientDidSnap(fromScreen: PageScrollingInteractor.ScreenType, toScreen: PageScrollingInteractor.ScreenType, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
        if toScreen == .center{
            
            horizontalScrollInteractor.activate()
            verticalScrollInteractor.activate()
            horizontalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = true
            verticalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = true
            
        } else if interactor == horizontalScrollInteractor{
            
            verticalScrollInteractor.deactivate()
            horizontalScrollInteractor.activate()
            horizontalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = false
            
        } else if interactor == verticalScrollInteractor{
            
            horizontalScrollInteractor.deactivate()
            verticalScrollInteractor.activate()
            verticalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = false
            
        }
    }
    
    
    func gradientDidChange(to gradient: CGFloat, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
        
        if gradient < 0 && direction == .vertical{
            verticalScrollInteractor.snapGradientTo(screen: .center, animated: false)
            return
        }
        
        switch direction{
        case .horizontal:
            adjustHorizontalViewsToGradientChange(gradient: gradient)
            adjustTopGradientLayerViewTo_GradientChange(gradient: gradient)
        case .vertical:
            adjustVerticalViewsToGradientChange(gradient: gradient)
        }
        
        
        topBar_typed.adaptTo(gradient: gradient, direction: direction)
        adaptNavigationViewtoGradientChange(gradient: gradient, direction: direction)
        adaptBackgroundColortoGradientChange(gradient: gradient, direction: direction)
    }
    
    
    private func adjustHorizontalViewsToGradientChange(gradient: CGFloat){
        
        let gradientPointValue = horizontalScrollInteractor.currentGradientPointValue
        
        if gradient == 0{
            leftScreenRightAnchor.constant = 0
            rightScreenLeftAnchor.constant = 0
            topGradientView.alpha = 0
        } else if gradient < 0{
            rightScreenLeftAnchor.constant = 0
            leftScreenRightAnchor.constant = abs(gradientPointValue)
        } else {
            leftScreenRightAnchor.constant = 0
            rightScreenLeftAnchor.constant = -abs(gradientPointValue)
        }
        self.view.layoutIfNeeded()
    }
    
    private func adjustVerticalViewsToGradientChange(gradient: CGFloat){
        let endingHeight = self.view.frame.height - topBarHeight - APP_INSETS.top
        bottomScreenTopAnchor.constant = -(endingHeight * abs(gradient))
        self.view.layoutIfNeeded()
    }
    
    
    
    
    
    
    private func adaptBackgroundColortoGradientChange(gradient: CGFloat, direction: ScrollingDirection){
        if !shouldChangeNavViewSize{return}
        
        let alpha = backgroundViewAlphaEquation.solve(for: gradient)
        centerScreenCoverView.alpha = alpha
        
        if direction == .vertical{
            self.centerScreenCoverView.backgroundColor = bottomScreenColor
            return
        }
        
    
        if gradient == 0{
            self.centerScreenCoverView.backgroundColor = .black
        } else if gradient < 0{
            self.centerScreenCoverView.backgroundColor = leftScreenColor
        } else {
            centerScreenCoverView.backgroundColor = rightScreenColor
        }
    }
    
    
    
    
    
    
    private func adaptNavigationViewtoGradientChange(gradient: CGFloat, direction: ScrollingDirection){
        
        
        if !shouldChangeNavViewSize{return}
        
        navigationView.changeObjectPositionsBy(gradient: gradient)
        
        let shadowAlphas = navigationButtonsShadowAlphaEquation.solve(for: gradient)
        let gradientAlpha = bottomGradientViewAlpha_horizontal.solve(for: gradient)
        let backingAlpha: CGFloat
        let buttonColorVal: CGFloat
        
        
        switch direction{
        case .horizontal:
            backingAlpha = navigationViewBackingAlphaEquation_horizontal.solve(for: gradient)
            buttonColorVal = navigationViewTintColorEquation_horizontal.solve(for: gradient)
            bottomGradientView.alpha = gradientAlpha
        case .vertical:
            backingAlpha = navigationViewBackingAlphaEquation_vertical.solve(for: gradient)
            buttonColorVal = navigationViewTintColorEquation_vertical.solve(for: gradient)
        }
        
        navigationView.tintColor = UIColor(red: buttonColorVal, green: buttonColorVal, blue: buttonColorVal)
        navigationView.setButtonBackingAlphas(to: backingAlpha)
        navigationView.setButtonShadowAlphas(to: shadowAlphas)
    }
    
    
    private func adjustTopGradientLayerViewTo_ScrollViewScrolled(scrollView: SCScrollView){
        topGradientView.alpha = getCurrentSuggestedTopGradientViewAlphaFor(scrollView: scrollView)
    }
    
    private func adjustTopGradientLayerViewTo_GradientChange(gradient: CGFloat){
        
        let scrollView: SCScrollView
        
        if gradient == 0 { topGradientView.alpha = 0; return }
        else if gradient < 0{ scrollView = leftScreen}
        else {scrollView = rightScreen}
        
        
        let endAlpha = getCurrentSuggestedTopGradientViewAlphaFor(scrollView: scrollView)
        
        topGradientView.alpha = endAlpha * abs(gradient)
        
        
    }
    
    private func getCurrentSuggestedTopGradientViewAlphaFor(scrollView: SCScrollView) -> CGFloat{
        
        
        let actualOutset = ((scrollView.topContentOffset >= 0) ? scrollView.topContentOffset : 0) - view.safeAreaInsets.top
        let totalOutset = topBarHeight
        
        if actualOutset <= totalOutset{
            return 1 - (actualOutset / totalOutset)
        } else {
            return 0
        }
    }
    
    
    
    
}
