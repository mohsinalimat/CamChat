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
        
        let actualOutset = ((topContentOffset >= 0) ? topContentOffset : 0) - view.safeAreaInsets.top
        let totalOutset = topBarHeight
        
        if actualOutset >= totalOutset{
            
            let extraOutset = actualOutset - totalOutset
            topGradientView.alpha = 0
            topLayoutGuideHeightConstraint.constant = actualOutset
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
        
        topBar.changeIconPositionsAccordingTo(gradient: gradient, direction: direction)
        topSearchBar.changeGradientTo(gradient: gradient, direction: direction)
        adaptNavigationViewtoGradientChange(gradient: gradient, showDimmer: (gradient > 0 && direction == .horizontal), direction: direction)
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
        let endingHeight = self.view.frame.height - topBarHeight - self.view.safeAreaInsets.top
        bottomScreenTopAnchor.constant = -(endingHeight * abs(gradient))
        self.view.layoutIfNeeded()
    }
    
    
    
    
    
    
    private func adaptBackgroundColortoGradientChange(gradient: CGFloat, direction: ScrollingDirection){
        if !shouldChangeNavViewSize{return}
        
        let absGradient = abs(gradient)
        
        if direction == .vertical{
            self.centerScreenCoverView.backgroundColor = bottomScreenColor.withAlphaComponent(absGradient)
            return
        }
        
        
        let elasticPercent = solveLinearly(x: absGradient, a: 1.515, min: 0, max: 1)
        if gradient == 0{
            self.centerScreenCoverView.backgroundColor = UIColor.black.withAlphaComponent(0)
        } else if gradient < 0{
            self.centerScreenCoverView.backgroundColor = leftScreenColor.withAlphaComponent(elasticPercent)
        } else {
            centerScreenCoverView.backgroundColor = rightScreenColor.withAlphaComponent(elasticPercent)
        }
    }
    
    
    
    //  TODO: PLEASE FIX THIS FUNCTION. IT IS QUITE SHITTY
    
    private func adaptNavigationViewtoGradientChange(gradient: CGFloat, showDimmer: Bool, direction: ScrollingDirection){
        let absGradient = abs(gradient)
        
        if !shouldChangeNavViewSize{return}
        
        navigationView.changeObjectPositionsBy(gradient: gradient)
        
        
        if gradient == 0{
            navigationView.setButtonBackingAlphas(to: 0)
            navigationView.tintColor = .white
            bottomGradientView.alpha = 0
        } else if gradient < 0{
            let val = getGradientValue(minVal: 255, maxVal: 190, percentage: absGradient)
            let color = UIColor(red: val, green: val, blue: val)
            navigationView.tintColor = color
            bottomGradientView.alpha = 0
            
            let backingAlpha = solveLinearly(x: absGradient, a: 10, b: -9, min: 0, max: 1)
            
            navigationView.setButtonBackingAlphas(to: backingAlpha)
            navigationView.setButtonShadowAlphas(to: 1 - absGradient)
        } else if gradient > 0{
            
            if showDimmer{
                bottomGradientView.alpha = absGradient
            }
            
            
            
            if direction == .vertical{
                
                let val = getGradientValue(minVal: 255, maxVal: 190, percentage: absGradient)
                let color = UIColor(red: val, green: val, blue: val)
                navigationView.tintColor = color
                
                let backingAlpha = solveLinearly(x: absGradient, a: 10, b: -9, min: 0, max: 1)
                
                navigationView.setButtonBackingAlphas(to: backingAlpha)
                navigationView.setButtonShadowAlphas(to: 1 - absGradient)
                return
            }
            navigationView.tintColor = .white
            navigationView.setButtonBackingAlphas(to: 0)
            
            
            
        }
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
