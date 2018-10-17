//
//  PhotoVideoThumbnailPreview.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import NVActivityIndicatorView


class PhotoVideoThumbnailPreview: UIView{
    

    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.gray(percentage: 0.8)
        
        imageView.pinAllSides(addTo: self, pinTo: self)
        videoPreviewer.pinAllSides(addTo: self, pinTo: self)
        loadingIndicator.pin(addTo: self, anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor], constants: [.height: spinnerSize, .width: spinnerSize])
        clipsToBounds = true
    }
    private var currentData: PhotoVideoData?
    
    var hasData: Bool{
        return currentData.isNotNil
    }
    
    func setWith(data: PhotoVideoData?, completion: (() -> ())? = nil){
        self.currentData = data
        videoPreviewer.stopPreviewing()
        imageView.image = nil
        
        
        guard let data = data else { return }
        DispatchQueue.global(qos: .background).async {
            let imageData: Data
            switch data {
            case let .photo(_ , thumbnailURL):
                imageData = try! Data(contentsOf: thumbnailURL)
            case let .video(url, thumbnailURL):
                imageData = try! Data(contentsOf: thumbnailURL)
                self.videoPreviewer.setWithVideo(url: url)
            }
            let image = UIImage(data: imageData)!

            DispatchQueue.main.async {
                self.imageView.image = image
                completion?()
            }
        }
        
    }
    
    private var videoPreviewer: VideoThumbnailPreview = {
        let x = VideoThumbnailPreview()
        x.backgroundColor = .clear
        return x
    }()
    
    private var imageView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFill)
        return x
    }()
    private let spinnerSize: CGFloat = 25

    private lazy var loadingIndicator: NVActivityIndicatorView = {
        let x = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize), type: .circleStrokeSpin, color: BLUECOLOR, padding: nil)
        x.alpha = 0
        return x
    }()
    
    func startShowingLoadingIndicator(color: UIColor = BLUECOLOR){
        loadingIndicator.alpha = 1
        loadingIndicator.color = color
        loadingIndicator.startAnimating()
        
    }
    func stopShowingLoadingIndicator(){
        loadingIndicator.stopAnimating()
        loadingIndicator.alpha = 0
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


