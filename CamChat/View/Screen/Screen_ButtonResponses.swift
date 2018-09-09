//
//  Screen_ButtonResponses.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

extension Screen: CCSearchBarDelegate{
    func searchBarTapped() {
        topBar_typed.topSearchBar.layoutIfNeeded()
        let searchBarHeight = topBar_typed.topSearchBar.frame.height
        present(CCSearchController(searchBarHeight: searchBarHeight), animated: true)
    }
}

extension Screen: ScreenButtonsTopBarDelegate{

    func newChatButtonTapped() {

    }
    
    func flashButtonTapped(to isOn: Bool) {

    }
    
    func cameraFlipButtonTapped() {

    }
    
    func photoLibrarySelectButtonTapped() {

    }
}


extension Screen: ButtonNavigationViewDelegate{
    func navigationButtonTapped(type: ButtonNavigationView.ButtonType) {
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
}
