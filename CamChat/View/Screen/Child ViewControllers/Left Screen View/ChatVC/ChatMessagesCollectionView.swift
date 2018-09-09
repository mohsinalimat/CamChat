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
    
    
    private var viewModel: CoreDataListViewVM<ChatMessagesCollectionView>!
    private let user: User
    init(user: User) {
        self.user = user
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        alwaysBounceVertical = true
        backgroundColor = .white
        keyboardDismissMode = .interactive
        setCornerRadius(to: 10)
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        viewModel = CoreDataListViewVM(delegate: self)
        
        
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}


extension ChatMessagesCollectionView: CoreDataListViewVMDelegate{
    var fetchRequest: NSFetchRequest<Message> {
        let fetch = Message.typedFetchRequest()
        
        fetch.predicate = NSPredicate(format: "(\(#keyPath(Message.sender.uniqueID)) == %@) OR \(#keyPath(Message.receiver.uniqueID)) == %@", user.uniqueID, user.uniqueID)
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateSent), ascending: true)]
        return fetch
    }
    
    
    
    
    var listView: UICollectionView{
        return self
    }
    
    func configureCell(_ cell: ChatMessagesCollectionViewCell, at indexPath: IndexPath, for object: Message) {
    
        cell.setWith(message: object)
    }
    
    
    
    
    
    
}
