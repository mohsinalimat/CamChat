//
//  PhotoVideoWindoViewer.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class PhotoVideoWindowViewer: UIWindow{
    
    typealias SnapshotInfo = (snapshot: UIView, frame: CGRect, cornerRadius: CGFloat, topCutOffHeight: CGFloat)

    
    private var keyboardSnapshots: [UIView]
    private var keyboardWindows: [UIWindow]
    private var previousWindow: UIWindow
    private var photoVideoData: PhotoVideoData
    private var snapshotInfo: SnapshotInfo

    private var snapshot: UIView{
        return snapshotInfo.snapshot
    }
    
    private var viewController: PhotoVideoWindowVC
    
    private var gesture: DirectionAwarePanGesture!
    
    var presentationWillBeginAction: (() -> Void)?
    var dismissalAnimationDidEndAction: (() -> Void)?
    
    init(currentWindow: UIWindow, data: PhotoVideoData, snapshotInfo: SnapshotInfo){
        self.snapshotInfo = snapshotInfo
        photoVideoData = data
        self.keyboardWindows = UIApplication.shared.windows.filter{$0.isKeyWindow.isFalse}
        self.keyboardSnapshots = keyboardWindows.map{$0.snapshotView(afterScreenUpdates: false)!}
        viewController = PhotoVideoWindowVC(photoVideoData: data)
        previousWindow = currentWindow
        super.init(frame: UIScreen.main.bounds)
        windowLevel = .alert
        keyboardWindows.forEach{$0.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)}
        keyboardSnapshots.forEach { currentWindow.addSubview($0) }
        self.isHidden = false
        
        let gesture = DirectionAwarePanGesture(target: self, action: #selector(respondToPanGestureRecognizer(gesture:)))
        gesture.stopInterferingWithTouchesInView()
        self.gesture = gesture
        self.addGestureRecognizer(gesture)
        
        setUpViews()
        rootViewController = viewController


        
        presentationWillBeginAction?()
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseOut], animations: {
            self.performUnanimatedPresentation()
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.1) {
            self.snapshot.alpha = 0
        }
        
        
    }
    
    private func setUpViews(){
        addSubview(dimmerView)
        dimmerView.frame = UIScreen.main.bounds
        dimmerView.alpha = 0
        
        addSubview(contentView)
        contentView.frame = snapshotInfo.frame
        contentView.setCornerRadius(to: snapshotInfo.cornerRadius)
        
        addSubview(snapshot)
        snapshot.frame = snapshotInfo.frame
        viewToEnterForDismissal.pin(addTo: self, anchors: [.bottom: bottomAnchor, .left: leftAnchor, .right: rightAnchor, .top: topAnchor], constants: [.top: snapshotInfo.topCutOffHeight])
    }
    
    private func performUnanimatedPresentation(){
        [contentView, snapshot].forEach { $0.frame = self.bounds }

        dimmerView.alpha = 1
        contentView.setCornerRadius(to: 0)
    }
    
    
    
    private lazy var dimmerViewAlphaEquation = CGLinearEquation(xy(0,1), xy(200, 0), min: 0, max: 1)!
    
    private var originalFingerPosition: CGPoint?
    
    private let minimumPresentedViewScale: CGFloat = 0.3
    
    private lazy var presentedViewTranslationEquation = CGLinearEquation(xy(0, 1), xy(UIScreen.main.bounds.height - 200, minimumPresentedViewScale), min: minimumPresentedViewScale, max: 1)!
    
    
    
    private func moveViewsBy(translation: CGPoint){
        guard let originalPosition = originalFingerPosition else {return}
        let newFingerPoint = originalPosition + translation
        
        let scaleTranslation = presentedViewTranslationEquation.solve(for: translation.y)
        let transform = CGAffineTransform(scaleX: scaleTranslation, y: scaleTranslation)
        [contentView, snapshot].forEach{
            $0.transform = transform
            $0.move(pointInBounds: originalPosition, toPointInSuperViewsBounds: newFingerPoint)
        }
        dimmerView.alpha = dimmerViewAlphaEquation[translation.y]
    }
    
    private func performUnanimatedDismissalActions(){
        [contentView, snapshot].forEach{
            $0.transform = CGAffineTransform.identity
            $0.setCornerRadius(to: snapshotInfo.cornerRadius)
            $0.frame = viewToEnterForDismissal.convert(snapshotInfo.frame, from: self)
            viewToEnterForDismissal.addSubview($0)
        }

        contentView.layoutIfNeeded()
        snapshot.alpha = 1
        dimmerView.alpha = 0
    }
    
    
    
    private func cleanUpAfterDismissal() {
        
        keyboardWindows.forEach { $0.transform = CGAffineTransform.identity }
        keyboardSnapshots.forEach { $0.removeFromSuperview() }
        keyboardWindows.forEach{$0.layoutIfNeeded()}
        
        self.contentView.videoPlayer?.pause()
        [contentView, snapshot].forEach { $0.removeFromSuperview() }
        
        isHidden = true
    }
    
    
    
    
    private var shouldCompleteAnimation = false
    
    
    @objc private func respondToPanGestureRecognizer(gesture: DirectionAwarePanGesture){
        
        if gesture.swipingDirection != .towardBottom {return}
        
        var translation = gesture.translation(in: self)
        if translation.y < 0 {translation = CGPoint(x: translation.x, y: translation.y * 0.2)}
        let velocity = abs(gesture.velocity(in: self).y)
        
        switch gesture.state {
            
        case .began: begin()
        case .changed: update(translation: translation, velocity: velocity)
        case .cancelled, .failed: cancel()
        case .ended: if shouldCompleteAnimation{ finish() } else { cancel() }
            
        default: break
        }
        
        
    }
    
    private func begin(){
        shouldCompleteAnimation = false
        contentView.isUserInteractionEnabled = false
        self.originalFingerPosition = gesture.location(in: self)
    }
    
    private func update(translation: CGPoint, velocity: CGFloat){
        self.shouldCompleteAnimation = translation.y >= 50 || (velocity >= 500 && translation.y > 50)
        self.moveViewsBy(translation: translation)
    }
    
    private func cancel(){
        shouldCompleteAnimation = false
        contentView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.moveViewsBy(translation: CGPoint.zero)
        }) { (success) in
            
        }
    }

    
    private func finish(){
        shouldCompleteAnimation = false
        gesture.isEnabled = false
        let animationDuration = 0.4
        Timer.scheduledTimer(withTimeInterval: animationDuration - 0.01, repeats: false) { (timer) in
            // For some reason when I put this in the 'cleanUpAfterDismissal' function, it causes the photoVideoPreview view  to blink... for some stupid reason.
            self.dismissalAnimationDidEndAction?()
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: {
            self.performUnanimatedDismissalActions()
        }) { (success) in
            
            self.cleanUpAfterDismissal()
        }
    }
    
    
    
    
    
    
    
    private var viewToEnterForDismissal: UIView = {
        let x = UIView()
        x.clipsToBounds = true
        x.isUserInteractionEnabled = false
        return x
        
    }()
    
    
    private lazy var contentView: PhotoVideoWindowContentView = {
        let x = PhotoVideoWindowContentView(photoVideoData: photoVideoData)
        
        x.saveButton.addAction { [weak self, weak x] in
            guard let self = self, let x = x else {return }
            self.viewController.respondToSaveButtonTapped()
        }

        
    
        return x
    }()
    

    
    private lazy var dimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = .black
        return x
    }()
    
    
 
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}













private class PhotoVideoWindowVC: UIViewController{
    private let photoVideoData: PhotoVideoData
    
    init(photoVideoData: PhotoVideoData){
        self.photoVideoData = photoVideoData
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .red
        view.superview?.backgroundColor = .clear

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.frame.origin.x += UIScreen.main.bounds.width
    }
    

    
    
    private var photoVideoName: String{
        return photoVideoData.isVideo ? "video" : "photo"
    }
    
    
    func respondToSaveButtonTapped(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraRollAction = UIAlertAction(title: "Save to Camera Roll", style: .default) {[weak self] (action) in
            guard let self = self else { return }
            
            
            Memory.saveToCameraRoll(photoVideoData: [self.photoVideoData], completion: { wasSuccessful in
                if wasSuccessful {
                    self.presentSuccessAlert(description: "The \(self.photoVideoName) was successfully saved to your camera roll.")
                } else {
                    self.presentOopsAlert(description: "Something went wrong when trying to save the \(self.photoVideoName) to your camera roll.")
                }
            })
        }
        
        
        let saveToMemoriesAction = UIAlertAction(title: "Save to Memories", style: .default) {[weak self] (action) in
            guard let self = self else {return}
            
            Memory.createNew(uniqueID: NSUUID().uuidString, authorID: DataCoordinator.currentUserUniqueID!, type: self.photoVideoData.getCopy(for: .memory)!, dateTaken: Date(), context: .main, completion: { memory in
                CoreData.mainContext.saveChanges()
                self.presentSuccessAlert(description: "The \(self.photoVideoName) was successfully saved to your memories.")
            })
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cameraRollAction)
        actionSheet.addAction(saveToMemoriesAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet)
    }
    
    

    
    
    

    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}








private class PhotoVideoWindowContentView: UIView {
    
    private let photoVideoData: PhotoVideoData
    
    init(photoVideoData: PhotoVideoData){
        self.photoVideoData = photoVideoData
        super.init(frame: CGRect.zero)
        imageView.pinAllSides(addTo: self, pinTo: self)
        videoPlayer?.pinAllSides(addTo: self, pinTo: self)
        saveButton.pin(addTo: self, anchors: [.left: leftAnchor, .bottom: bottomAnchor], constants: [.left: 20, .bottom: Variations.homeIndicatorHeight + 20])
       
    }
    

    
    private(set) lazy var imageView: UIImageView = {
        let x = UIImageView(image: photoVideoData.image, contentMode: .scaleAspectFill)
        return x
    }()
    
    private(set) lazy var videoPlayer: SimpleVideoPlayer? = {
        if case let .video(url, _) = self.photoVideoData {
            let x = SimpleVideoPlayer(url: url, setUpCompletionHandler: { $0.play() })
            return x
        } else { return nil }
    }()
    
    private let buttonSizes: CGFloat = 30
    

    
    private(set) lazy var saveButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.downloadIcon)
        x.pin(constants: [.height: buttonSizes, .width: buttonSizes])
        x.applyShadow(width: 5)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
