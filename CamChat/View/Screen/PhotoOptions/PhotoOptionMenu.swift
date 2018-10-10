//
//  PhotoOptionMenu.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Photos

private struct PhotoOption{
    
    init(image: UIImage?, text: String, action: (() -> Void)? = nil){
        self.image = image
        self.text = text
        self.action = action
    }
    
    var image: UIImage?
    var text: String
    var action: (() -> Void)?
}

protocol PhotoOptionMenuDelegate: class {
    func memoryWillBeDeleted()
}

class PhotoOptionMenu: UIView{
    
    
    private lazy var options = [
        PhotoOption(image: AssetImages.downloadIcon, text: "Save \(memoryLabel) to Camera Roll", action: { [weak self] in self?.respondToCameraRollSaveOptionTapped()}),
        PhotoOption(image: AssetImages.shareIcon, text: "Share \(memoryLabel)", action: {[weak self ] in self?.respondToShareOption()}),
        PhotoOption(image: AssetImages.trashIcon, text: "Delete \(memoryLabel)", action: {[weak self] in self?.respondToMemoryDeletionOption()}),
        PhotoOption(image: nil, text: "Send \(memoryLabel)", action: {[weak self] in self?.respondToSendOption()})
    ]
    
    
    
    
    private let memory: Memory
    
    private var memoryLabel: String{
        switch memory.info{
        case .photo: return "Photo"
        case .video: return "Video"
        }
    }
    
    private weak var vcOwner: UIViewController?
    private weak var delegate: PhotoOptionMenuDelegate?
    init(memory: Memory, vcOwner: UIViewController, delegate: PhotoOptionMenuDelegate?){
        

        self.delegate = delegate
        self.vcOwner = vcOwner
        self.memory = memory
        super.init(frame: CGRect.zero)
        setUpViews()
        setCornerRadius(to: 10)
        backgroundColor = .white
    }
    
    private var optionViews = [PhotoOptionView]()
    
    private func setUpViews(){
        
        for option in options{
            let newOptionView = PhotoOptionView(option: option)
            newOptionView.pin(addTo: self, anchors: [.left: leftAnchor, .right: rightAnchor, .height: heightAnchor, .top: optionViews.last?.bottomAnchor ?? topAnchor], multipliers: [.height: 1 / CGFloat(options.count)])
            optionViews.append(newOptionView)
            
        }
        
        let sendView = optionViews.last!
        sendView.hideLine()
        let sendButton = SendButton()
        sendButton.isUserInteractionEnabled = false
        sendButton.pin(addTo: sendView, anchors: [.centerX: sendView.imageViewLayoutGuide.centerXAnchor, .centerY: sendView.imageViewLayoutGuide.centerYAnchor], constants: [.height: 35, .width: 35])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


private class PhotoOptionView: SimpleInteractiveButton{
    private let option: PhotoOption
    init(option: PhotoOption){
        self.option = option
        
        super.init()
        if let action = option.action{addAction(action)}
        
        maximumDimmingAlpha = 0.1
        imageViewLayoutGuide.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: heightAnchor])
        imageView.pin(addTo: self, anchors: [.centerX: imageViewLayoutGuide.centerXAnchor, .centerY: imageViewLayoutGuide.centerYAnchor], constants: [.height: 25, .width: 25])
        label.pin(addTo: self, anchors: [.left: imageViewLayoutGuide.rightAnchor, .centerY: centerYAnchor])
        bottomLine.pin(addTo: self, anchors: [.left: leftAnchor, .bottom: bottomAnchor, .right: rightAnchor])
    }
    
    func showLine(){
        bottomLine.alpha = 1
    }
    
    func hideLine(){
        bottomLine.alpha = 0
    }
    
    private lazy var bottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = .lightGray
        x.pin(constants: [.height: 0.5])
        return x
    }()
    
    lazy var imageViewLayoutGuide = UILayoutGuide()
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: option.image)
        x.contentMode = .scaleAspectFit
        x.tintColor = .black
        return x
    }()
    
    private lazy var label: UILabel = {
        let x = UILabel()
        x.text = option.text
        x.font = SCFonts.getFont(type: .medium, size: 17)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}




extension PhotoOptionMenu{
    

    private func respondToCameraRollSaveOptionTapped(){
        Memory.saveToCameraRoll(memories: [self.memory]) {[weak self] (success) in
            self?.respondToCameraRollSaveCompletion(success: success)
        }
    }
    
    private func respondToCameraRollSaveCompletion(success: Bool){
        
        if success {
            if let presenting = self.vcOwner?.presentingViewController{
                self.vcOwner?.dismiss(animated: true, completion: {[weak self] in
                    self?.presentSuccessfulCameraRollSaveAlertFor(vc: presenting)
                })
            } else { self.presentSuccessfulCameraRollSaveAlertFor(vc: vcOwner!) }

        } else {
            self.vcOwner?.presentOopsAlert(description: "Something went wrong when trying to save the \(self.memoryLabel.lowercased()). Please ensure that you have allowed CamChat access to your photo library in your privacy settings.")
        }
    }

    private func presentSuccessfulCameraRollSaveAlertFor(vc: UIViewController){
        vc.presentSuccessAlert(description: "The \(self.memoryLabel.lowercased()) was successfully saved to your device!")
    }
    
    private func respondToMemoryDeletionOption(){
        
        let alert = vcOwner?.presentCCAlert(title: "Are you sure you want to delete this \(self.memoryLabel.lowercased())?", description: "Deleted photos and videos cannot be recovered.", primaryButtonText: "Delete", secondaryButtonText: "Cancel")
        alert?.addPrimaryButtonAction { [weak alert, weak self] in
            guard let self = self else { return }
            alert?.dismiss(animated: true, completion: {
                if (self.vcOwner?.presentingViewController).isNotNil{
                    self.vcOwner?.dismiss(animated: true) {
                        self.delegate?.memoryWillBeDeleted()
                        Memory.delete(memories: [self.memory])
                    }
                } else {
                    self.delegate?.memoryWillBeDeleted()
                    Memory.delete(memories: [self.memory])
                }
            })
        }
        alert?.addSecondaryButtonAction {
            alert?.dismiss()
        }
    }
    
    
    
    private func respondToShareOption(){
        let vc = Memory.getActivityVCFor(memories: [memory])
        if let presenter = vcOwner?.presentingViewController{
            vcOwner?.dismiss(animated: true) { presenter.present(vc) }
        } else { self.vcOwner?.present(vc) }
    }
    
    
    private func respondToSendOption(){
        
        if let presenting = vcOwner?.presentingViewController{
            vcOwner?.dismiss(animated: true, completion: {
                self.presentMemorySender(on: presenting)
            })
        } else {presentMemorySender(on: vcOwner!)}
    }
    
    private func presentMemorySender(on vc: UIViewController){
        let memorySender = MemorySenderVC(presenter: vc, memories: [memory]) { sender in
            
            sender.dismiss()
        }
        vc.present(memorySender)
    }
    
}
