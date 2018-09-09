//
//  ChatMessagesCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatMessagesCollectionViewCell: UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.pin(addTo: self, anchors: [.centerY: centerYAnchor, .left: leftAnchor], constants: [.left: 20])
    }
    
    
    func setWith(message: Message){
        let senderText = message.sender == DataCoordinator.currentUser! ? "Me: " : "Them: "
        label.text = senderText + message.text
        print("should have set label text to \(label.text!)")
    }
    
    
    private lazy var label: UILabel = {
        let x = UILabel()
        return x
    }()
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}
