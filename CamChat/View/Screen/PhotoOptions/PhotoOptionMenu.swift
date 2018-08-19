//
//  PhotoOptionMenu.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

private struct PhotoOption{
    
    var image: UIImage?
    var text: String
    
}


class PhotoOptionMenu: UIView{
    
    
    private var options = [
        PhotoOption(image: AssetImages.shareIcon, text: "Share Photo"),
        PhotoOption(image: AssetImages.trashIcon, text: "Delete Photo"),
        PhotoOption(image: nil, text: "Send Photo")
    ]
    
    
    init(){
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
        maximumDimmingAlpha = 0.1
        imageViewLayoutGuide.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: heightAnchor])
        imageView.pin(addTo: self, anchors: [.centerX: imageViewLayoutGuide.centerXAnchor, .centerY: imageViewLayoutGuide.centerYAnchor], constants: [.height: 30, .width: 30])
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
