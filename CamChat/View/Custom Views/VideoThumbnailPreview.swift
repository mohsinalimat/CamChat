//
//  VideoThumbnailPreview.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import AVFoundation



class VideoThumbnailPreview: UIView{
    
    private static var cachedThumbnailImages = HKCache<URL, [UIImage]>(objectLimit: 50)
    
    private let desiredImageTimes = [0, 0.2, 0.4, 0.6, 0.8]
    private var currentImageIndex = 0
    private var currentImages = [UIImage]()
    
    init(){
        super.init(frame: CGRect.zero)
        imageView.pinAllSides(addTo: self, pinTo: self)
    }
    
    
    
    
    
    func setWithVideo(url: URL, completion: (() -> ())? = nil){
        currentImageIndex = 0
        currentImages.removeAll()
        
        let action = {
            DispatchQueue.main.async {
                self.imageView.image = self.currentImages.first!
                self.setUpTimer(withImages: self.currentImages)
                completion?()
            }
        }
        
        
        if let images = VideoThumbnailPreview.cachedThumbnailImages[url]{
            self.currentImages = images
            action()
        } else {
            DispatchQueue.global(qos: .background).async {
                
                self.currentImages = Memory.getImagesForVideoAt(url: url, atTimes: self.desiredImageTimes)
                VideoThumbnailPreview.cachedThumbnailImages[url] = self.currentImages
                action()
            }
        }
    }
    
    func stopPreviewing(){
        currentTimer?.invalidate()
        self.currentTimer = nil
        currentImageIndex = 0
        currentImages.removeAll()
        self.imageView.image = nil
    }
    
    
    
    
    
    private var currentTimer: Timer?
    
    private func setUpTimer(withImages images: [UIImage]){
        currentTimer?.invalidate()
        currentTimer  = Timer(timeInterval: 0.5, repeats: true, block: {[weak self] (timer) in
            guard let self = self else {timer.invalidate(); return}
            
            if let next = images.item(at: self.currentImageIndex + 1){
                self.currentImageIndex += 1
                self.imageView.image = next
            } else {
                self.currentImageIndex = 0
                self.imageView.image = images.first!
            }
            
        })
        RunLoop.current.add(currentTimer!, forMode: .common)
        
    }
    
    
    
    
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFill)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}

