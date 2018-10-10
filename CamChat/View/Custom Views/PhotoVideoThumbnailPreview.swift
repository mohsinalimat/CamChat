//
//  PhotoVideoThumbnailPreview.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class PhotoVideoThumbnailPreview: UIView{
    

    init() {
        super.init(frame: CGRect.zero)
    
        backgroundColor = UIColor.gray(percentage: 0.8)
        
        imageView.pinAllSides(addTo: self, pinTo: self)
        videoPreviewer.pinAllSides(addTo: self, pinTo: self)
        clipsToBounds = true
    
    }
    private var currentData: PhotoVideoData?
    
    var hasData: Bool{
        return currentData.isNotNil
    }
    
    func setWith(data: PhotoVideoData?){
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
            }
        }
        
    }
    
    private var videoPreviewer: VideoThumbnailPreview = {
        let x = VideoThumbnailPreview()
        return x
    }()
    
    private var imageView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFill)
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


