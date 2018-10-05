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
    
    private var player: AVPlayer!
    private var previewLayer: AVPlayerLayer!
    
    
    
    init(url: URL, setUpCompletionHandler: ((SimpleVideoPlayer) -> Void)? = nil){
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: playerItem)
            self.previewLayer = AVPlayerLayer(player: self.player)
            
            DispatchQueue.main.async {
                
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer.backgroundColor = UIColor.clear.cgColor
                self.layer.addSublayer(self.previewLayer)
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] (timer) in
                    guard let self = self else {timer.invalidate(); return}
                    if self.player.currentTime() == playerItem.duration{
                        self.player.seek(to: CMTime.zero, completionHandler: { _ in
                            self.player.play()
                        })
                    }
                }
                setUpCompletionHandler?(self)
            }
        }
    }

    
    func play(){
        player?.play()
    }
    
    func pause(){
        player?.pause()
    }
    
    
    func rewindToBeginning(){
        self.player?.seek(to: CMTime.zero)
    }
    

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
