//
//  Screen_ButtonResponses.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

import AVKit

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
        centerScreen.isFlashEnabled = isOn
    }
    
    func cameraFlipButtonTapped() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.centerScreen.flipCamera()
        }
    }
    
    func photoLibrarySelectButtonTapped() {
        rightScreen.selectionButtonTapped()
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


extension Screen: CameraDelegate{
   
    
    
    func willTakePhoto() {
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func didTakePhoto(image: UIImage) {
        UIApplication.shared.endIgnoringInteractionEvents()
        self.present(PhotoVideoPreviewVC(.photo(image)), animated: false)
    }
    
    func didStartRecordingVideo() {
        self.performBeginningRecordingAnimationActions()
    }
    
    func willFinishRecordingVideo() {
        
    }
    
    func didFinishRecordingVideo(url: URL) {
        let previewer = PhotoVideoPreviewVC(.video(url))
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {[weak self] (timer) in
            self?.present(previewer, animated: false)
            self?.performEndingRecordingAnimationActions()
        }
    }
}


extension Screen{
    
    private var viewsToDimDuringVideoRecordingSession: [UIView]{
        return [topBarBottomLine,
                topBar_typed.topSearchBar,
                topBar_typed.buttonTopBar.flashIcon,
                navigationView.chatButton,
                navigationView.settingsButton,
                navigationView.photoButton
        ]
    }
    
    fileprivate func performBeginningRecordingAnimationActions(){
        self.horizontalScrollInteractor.stopAcceptingTouches()
        self.verticalScrollInteractor.stopAcceptingTouches()
        self.topBar_typed.topSearchBar.isUserInteractionEnabled = false
        addGestureToCameraSwitchIcon()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.viewsToDimDuringVideoRecordingSession.forEach{ $0.alpha = 0 }
            self.statusBarShouldBeHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        
    }
    
    fileprivate func performEndingRecordingAnimationActions(){
        
        self.horizontalScrollInteractor.startAcceptingTouches()
        self.verticalScrollInteractor.startAcceptingTouches()
        self.topBar_typed.topSearchBar.isUserInteractionEnabled = true
        removeGestureFromCameraSwitchIcon()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.viewsToDimDuringVideoRecordingSession.forEach{ $0.alpha = 1 }
            self.statusBarShouldBeHidden = false
        })
    }
    
    
    
    private var cameraFlipButton: BouncyImageButton{return topBar_typed.buttonTopBar.cameraFlipIcon}
    
    private func addGestureToCameraSwitchIcon(){
        temporaryCameraSwitchButtonGesture = UITapGestureRecognizer(target: self, action: #selector(respondToTapGesture(gesture:)))
        cameraFlipButton.addGestureRecognizer(temporaryCameraSwitchButtonGesture!)
        cameraFlipButton.isEnabled = false
    }
    
    private func removeGestureFromCameraSwitchIcon(){
        
        cameraFlipButton.removeGestureRecognizer(temporaryCameraSwitchButtonGesture!)
        temporaryCameraSwitchButtonGesture = nil
        cameraFlipButton.isEnabled = true
    }
    
    @objc private func respondToTapGesture(gesture: UITapGestureRecognizer){
        cameraFlipButton.tapBegan()
        DispatchQueue.global(qos: .userInitiated).async {
            self.centerScreen.flipCamera()
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            self.cameraFlipButton.tapEnded()
        })
    }
    
   
    
    
}
