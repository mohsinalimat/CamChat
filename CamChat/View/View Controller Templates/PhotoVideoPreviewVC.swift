//
//  PhotoVideoPreviewVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class PhotoVideoPreviewVC: UIViewController{
    
    enum MediaType { case photo(UIImage), video(URL) }
    
    override var prefersStatusBarHidden: Bool{return true}
    
    private let mediaType: MediaType
    
    private var mediaIsSaved = false
    
    
    init(_ mediaType: MediaType){
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
        
        switch mediaType {
        case .photo(let image): self.imageView.image = image
        case .video(let url):
            self.imageView.image = Memory.getImageForVideoAt(url: url)
            
            let player = SimpleVideoPlayer(url: url) { (videoPlayer) in
                videoPlayer.play()
            }
            
            self.playerView = player
            
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusBar.alpha = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        statusBar.alpha = 1
        
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
        return x
    }()
    
    private lazy var saveButton: BouncyImageButton = {
        let x = BouncyImageButton(image: AssetImages.downloadIcon)
        x.pin(constants: [.height: 25, .width: 25])
        x.applyShadow(width: 3)
        x.addAction { [weak self] in
            guard let self = self else {return}
            if self.mediaIsSaved{return}
            
            let memoryType: PhotoVideoData
            
            switch self.mediaType { 
            case .photo(let image): memoryType = PhotoVideoData.getFor(image: image)!
            case .video(let url): memoryType = PhotoVideoData.getFor(videoAt: url)!
            }
        
            Memory.createNew(uniqueID: NSUUID().uuidString, authorID: DataCoordinator.currentUserUniqueID!, type: memoryType, dateTaken: Date(), context: .background, completion: {_ in CoreData.backgroundContext.saveChanges()})
            
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
        if mediaIsSaved.isFalse{
            
            switch mediaType{
            case .video(let url):
                
                handleErrorWithPrintStatement {
                    try FileManager.default.removeItem(at: url)
                }
            default: break
            }
        }
    }
    
    
    
}
