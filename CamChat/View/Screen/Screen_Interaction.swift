//
//  Screen_Interaction.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


extension Screen {
    
    
    func SCScrollViewDidScroll(scrollView: SCScrollView, topContentOffset: CGFloat) {
        guard let topBarHeightConstraint = topBarHeightConstraint else {return}
        
        let actualOutset = max(topContentOffset, 0) - APP_INSETS.top
        let totalOutset = topBarHeight
        if actualOutset <= totalOutset + 2{
            topBar_typed.isUserInteractionEnabled = true
        } else { topBar_typed.isUserInteractionEnabled = false }
        
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
    
    
    
    func gradientWillBeginChanging(interactor: PageScrollingInteractor, direction: ScrollingDirection) {
        if direction == .horizontal{
            if interactor.currentlyFullyVisibleScreen == .center {
                leftScreen.viewWillAppear(true)
                rightScreen.viewWillAppear(true)
                centerScreen.viewWillDisappear(true)
            }
            if interactor.currentlyFullyVisibleScreen == .first{
                leftScreen.viewWillDisappear(true)
                centerScreen.viewWillAppear(true)
            }
            if interactor.currentlyFullyVisibleScreen == .last{
                rightScreen.viewWillDisappear(true)
                centerScreen.viewWillAppear(true)
            }
        }
        
        if direction == .vertical{
            if interactor.currentlyFullyVisibleScreen == .center{
                centerScreen.viewWillDisappear(true)
                bottomScreen.viewWillAppear(true)
            }
            if interactor.currentlyFullyVisibleScreen == .last{
                bottomScreen.viewWillDisappear(true)
                centerScreen.viewWillAppear(true)
            }
        }
    }
    
    
    func gradientDidSnap(fromScreen: PageScrollingInteractor.ScreenType, toScreen: PageScrollingInteractor.ScreenType, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
        if toScreen == .center{
            
            horizontalScrollInteractor.startAcceptingTouches()
            verticalScrollInteractor.startAcceptingTouches()
            horizontalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = true
            verticalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = true
            
        } else if interactor == horizontalScrollInteractor{
            
            verticalScrollInteractor.stopAcceptingTouches()
            horizontalScrollInteractor.startAcceptingTouches()
            horizontalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = false
            
        } else if interactor == verticalScrollInteractor{
            
            horizontalScrollInteractor.stopAcceptingTouches()
            verticalScrollInteractor.startAcceptingTouches()
            verticalScrollInteractor.onlyAcceptInteractionInSpecifiedDirection = false
            
        }
        
        if toScreen == fromScreen{return}
        
        
        let verticalDict = [PageScrollingInteractor.ScreenType.center: centerScreen, .last: bottomScreen]
        let horizontalDict = [PageScrollingInteractor.ScreenType.first: leftScreen, .center: centerScreen, .last: rightScreen]
        
        if direction == .horizontal{
            horizontalDict[fromScreen]!.viewDidDisappear(true)
            horizontalDict[toScreen]!.viewDidAppear(true)
        }
        
        if direction == .vertical{
            verticalDict[fromScreen]!.viewDidDisappear(true)
            verticalDict[toScreen]!.viewDidAppear(true)
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
            adaptBackgroundColortoHorizontalGradientChange(gradient: gradient)
            topBar_typed.adaptTo(gradient: gradient, direction: direction)
        case .vertical:
            adjustVerticalViewsToGradientChange(gradient: gradient)
            bottomScreen.gradientDidChange(to: gradient)
        }
        adaptNavigationViewtoGradientChange(gradient: gradient, direction: direction)
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
        bottomScreen.view.alpha = gradient
    }
    
    
    
    
    
    
    private func adaptBackgroundColortoHorizontalGradientChange(gradient: CGFloat){
        if !shouldChangeNavViewSize{return}
    
        centerScreenCoverView.alpha = backgroundViewAlphaEquation.solve(for: gradient)
        
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
        
        navigationView.setButtonShadowAlphas(to: shadowAlphas)
        
        if direction == .horizontal{
            let backingAlpha = navigationViewBackingAlphaEquation.solve(for: gradient)
            navigationView.setButtonBackingAlphas(to: backingAlpha)
            let buttonColorVal = navigationViewTintColorEquation.solve(for: gradient)
            navigationView.tintColor = UIColor(red: buttonColorVal, green: buttonColorVal, blue: buttonColorVal)
            bottomGradientView.alpha = gradientAlpha

            
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
        
        if actualOutset <= totalOutset{ return 1 - (actualOutset / totalOutset) }
        else { return 0 }
    }

}
