//
//  PhotoVideoWindoViewer.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class PhotoVideoWindowViewer: UIWindow{
    typealias SnapshotInfo = (snapshot: UIView, frame: CGRect, cornerRadius: CGFloat)
    
    
    
    private var keyboardSnapshots: [UIView]
    private var keyboardWindows: [UIWindow]
    private var previousWindow: UIWindow
    private var photoVideoData: PhotoVideoData
    private var snapshotInfo: SnapshotInfo
    
    
    
    init(currentWindow: UIWindow, data: PhotoVideoData, snapshotInfo: SnapshotInfo){
        self.snapshotInfo = snapshotInfo
        photoVideoData = data
        self.keyboardWindows = UIApplication.shared.windows.filter{$0.isKeyWindow.isFalse}
        self.keyboardSnapshots = keyboardWindows.map{$0.snapshotView(afterScreenUpdates: true)!}
        previousWindow = currentWindow
        super.init(frame: UIScreen.main.bounds)
        windowLevel = .alert
        keyboardWindows.forEach{$0.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)}
        keyboardSnapshots.forEach{currentWindow.addSubview($0)}
        self.isHidden = false
        prepareForPresentation()
        
        
    }
    
    
    
    
    private func prepareForPresentation(){
        
    }
    
    private func performPresentation(){
        
    }
    
    
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: photoVideoData.image, contentMode: .scaleAspectFill)
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
