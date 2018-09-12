//
//  ChatMessagesCollectionView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData



class ChatMessagesCollectionView: UICollectionView{
    
    private var viewModel: ChatCollectionViewVM?
    private let user: User
    init(user: User) {
        self.user = user
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        alwaysBounceVertical = true
        backgroundColor = .white
        keyboardDismissMode = .interactive
        setCornerRadius(to: 10)
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contentInset.top = ChatMessagesCollectionViewCell.leftInset
        contentInset.bottom = ChatMessagesCollectionViewCell.leftInset
        self.viewModel = ChatCollectionViewVM(collectionView: self, user: user, delegate: self)
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}

extension ChatMessagesCollectionView: ChatCollectionViewVMInsertionDelegate{
    
    func shouldMake(insertions: [InsertionResult]) {
        
        let action = {
            if insertions.contains(.reload){self.reloadData(); return}
            for insertion in insertions{
                switch insertion{
                case .block(blockIndex: let index): self.insertItems(at: [index])
                    
                case .message(newBlock: let block, newMessage: let newMessage, newMessagesIndex: let newMessageIndex, blockIndex: let blockIndex):
                    if let cell = self.cellForItem(at: blockIndex) as? ChatMessagesCollectionViewCell{
                        cell.setWithBlock(newBlock: block, insertingNewMessage: newMessage, atIndex: newMessageIndex)
                    } else {
                        self.insertItems(at: [blockIndex])
                    }
                default: break
                    
                }
            }
        }
        
        performBatchUpdates(action, completion: nil)
    }
}



