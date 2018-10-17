//
//  PhotoVideoPreviewVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CameraPhotoVideoPreviewVC: UIViewController{
    
    
    
    override var prefersStatusBarHidden: Bool{return true}
    
    private let photoVideoData: PhotoVideoData
    
    private var mediaIsSaved = false
    
    
    init(_ data: PhotoVideoData){
        self.photoVideoData = data
        super.init(nibName: nil, bundle: nil)
        
        self.imageView.image = data.image
        
        if case let .video(url, _) = data{
            let player = SimpleVideoPlayer(url: url) { $0.play() }
            self.playerView = player
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        imageView.pinAllSides(addTo: view, pinTo: view)
        
        if let playerView = self.playerView {
            playerView.pinAllSides(addTo: view, pinTo: view)
            view.layoutIfNeeded()
        }
        dismissButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .top: view.topAnchor], constants: [.left: 20, .top: 20 + Variations.notchHeight])
        sendButton.pin(addTo: view, anchors: [.right: view.rightAnchor, .bottom: view.bottomAnchor], constants: [.right: 20, .bottom: Variations.homeIndicatorHeight + 20])
        saveButton.pin(addTo: view, anchors: [.left: view.leftAnchor, .bottom: view.bottomAnchor], constants: [.bottom: Variations.homeIndicatorHeight + 20, .left: 20])
    }
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFill)
        x.backgroundColor = .clear
        return x
    }()
    
    private var playerView: SimpleVideoPlayer!
    
    private lazy var dismissButton: BouncyButton = {
        let x = BouncyImageButton(image: AssetImages.xIcon)
        x.addAction { [weak self] in self?.dismiss(animated: false) }
        x.pin(constants: [.height: 30, .width: 30])
        x.applyShadow(width: 1)
        return x
    }()
    
    private lazy var sendButton: SendButton = {
        let x = SendButton()
        
        x.pin(constants: [.height: 50, .width: 50])
        x.addAction { [weak self] in
            guard let self = self else {return}
        
            let sender = MemorySenderVC(presenter: self, photoVideoObjects: [self.photoVideoData], sendCompletedAction: { [weak self] (sender1) in
                sender1.dismiss(animated: true, completion: {
                    self?.dismiss(animated: false)
                })
            })
            
            sender.memorySenderWasDismissedAction = {
                self.playerView?.play()
            }
            self.playerView?.pause()
            self.present(sender)
        }
        return x
    }()
    
    private lazy var saveButton: BouncyImageButton = {
        
        let x = BouncyImageButton(image: AssetImages.downloadIcon, alternateImage: AssetImages.downloadFinishedIcon)
        x.pin(constants: [.height: 25, .width: 25])
        x.applyShadow(width: 3)
        x.addAction { [weak self] in
            guard let self = self else { return }
            if self.mediaIsSaved { return }
            self.saveButton.isUserInteractionEnabled = false
            Memory.createNew(uniqueID: NSUUID().uuidString, authorID: DataCoordinator.currentUserUniqueID!, type: self.photoVideoData, dateTaken: Date(), context: .main, completion: {_ in CoreData.mainContext.saveChanges()})
            self.mediaIsSaved = true
        }
        return x
    }()
    
    @objc private func respondToButtonTapped(){
        self.dismiss(animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
    
    
    
    deinit {
        playerView?.pause()
        if mediaIsSaved.isFalse {
            self.photoVideoData.deleteAllCorrespondingData()
        }
    }
    
    
    
}
