//
//  ChatMessagesCollectionView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class ChatMessagesCollectionView: UICollectionView, UIGestureRecognizerDelegate{
    
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        alwaysBounceVertical = true
        backgroundColor = .white
        keyboardDismissMode = .interactive
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.masksToBounds = true
        panGestureRecognizer.delegate = self
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
