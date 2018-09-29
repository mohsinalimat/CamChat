//
//  SimpleVideoPlayer.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import AVFoundation



class SimpleVideoPlayer: UIView{
    
    private let player: AVPlayer
    private let previewLayer: AVPlayerLayer
    
    
    
    
    init(url: URL){
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.previewLayer = AVPlayerLayer(player: player)
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(previewLayer)

        self.player.play()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {[weak self] (timer) in
            self?.startRepeatTimerUsing(asset: asset)
        }
    }
    
    private func startRepeatTimerUsing(asset: AVAsset){
        Timer.scheduledTimer(withTimeInterval: asset.duration.seconds, repeats: true) { [weak self] (timer) in
            guard let self = self else {return}
            
            self.player.pause()
            self.player.seek(to: CMTime.zero) {(succes) in
                self.player.play()
            }
        }
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer.frame = bounds
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
