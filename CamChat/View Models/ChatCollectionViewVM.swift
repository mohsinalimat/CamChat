//
//  ChatCollectionViewVM.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData





struct ChatMessageBlock: Equatable{
    let title: String
    private(set) var messages: [Message]
    fileprivate let sender: User
    
    var senderIsCurrentUser: Bool{
        return sender.isCurrentUser
    }
    
    fileprivate init(firstMessage: Message){
        self.sender = firstMessage.sender
        self.messages = [firstMessage]
        self.title = sender.isCurrentUser ? "ME" : sender.firstName.uppercased()
    }
    
    /// Adds the message to the block's messages array if the message's sender matches the the block's sender var. Returns whether or not it added the message.
    mutating fileprivate func addIfPossible(message: Message) -> Bool{
        if message.sender === sender {
            messages.append(message)
            return true
        }
        return false
    }
}



enum InsertionResult: Equatable{
    ///Represents that a whole new block should be inserted, which is basically an entire cell.
    case block(blockIndex: IndexPath)
    
    ///Represents that only a single message should be inserted within a block. The IndexPath is that of the block of which the message is a part. The Int is
    case message(newBlock: ChatMessageBlock, newMessage: Message, newMessagesIndex: Int, blockIndex: IndexPath)
    
    /// Represents that no insertion info could be computed and that the table view should just be completely reloaded
    case reload
}


private struct InsertionCalculator {
    
    
    
    static func getInfoFor(messageToInsert: Message, currentSortedMessageBlocks: [ChatMessageBlock]) -> InsertionResult{
        
        guard var lastBlock = currentSortedMessageBlocks.last else {return .reload}
        
        if lastBlock.messages.last!.dateSent < messageToInsert.dateSent{
            if lastBlock.addIfPossible(message: messageToInsert).isTrue{
                return .message(newBlock: lastBlock, newMessage: messageToInsert, newMessagesIndex: lastBlock.messages.lastItemIndex!, blockIndex: IndexPath(item: currentSortedMessageBlocks.lastItemIndex!, section: 0))
            } else {
                return .block(blockIndex: IndexPath(row: currentSortedMessageBlocks.endIndex, section: 0))
            }
        } else {return .reload}
        
   
    }
}

protocol ChatCollectionViewVMInsertionDelegate: class {
    func shouldMake(insertions: [InsertionResult])
}



class ChatCollectionViewVM: NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource{
    
    
    private weak var collectionView: UICollectionView!
    private var controller: NSFetchedResultsController<Message>!

    private let cellID = "CellID"
    
    private weak var delegate: ChatCollectionViewVMInsertionDelegate?
    
    
    init(collectionView: UICollectionView, user: User, delegate: ChatCollectionViewVMInsertionDelegate){
        self.delegate = delegate
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.register(ChatMessagesCollectionViewCell.self, forCellReuseIdentifier: cellID)
        
        let fetch = Message.typedFetchRequest()
        fetch.predicate = NSPredicate(format: "(\(#keyPath(Message.sender.uniqueID)) == %@) OR \(#keyPath(Message.receiver.uniqueID)) == %@", user.uniqueID, user.uniqueID)
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateSent), ascending: true)]
        self.controller = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.context, sectionNameKeyPath: nil, cacheName: nil)
        handleErrorWithPrintStatement(action: {try self.controller.performFetch()})
        setMessageBlocks()
        collectionView.reloadData()
        controller.delegate = self
        
    }
    
    
    
    private var messages: [Message]{
        return controller.fetchedObjects!
    }
    
    private var messageBlocks = [ChatMessageBlock]()
    
    
    private func setMessageBlocks(){
        var blocks = [ChatMessageBlock]()
        
        defer { self.messageBlocks = blocks }
        
        if let first = messages.first{blocks.append(ChatMessageBlock(firstMessage: first))}
        else {return}
        for message in messages.dropFirst(){
            
            var lastBlock = blocks.last!
            if lastBlock.addIfPossible(message: message).isTrue{
                blocks[blocks.lastItemIndex!] = lastBlock
            } else { blocks.append(ChatMessageBlock(firstMessage: message)) }
        }
    }
    
    private var insertionUpdates = [InsertionResult]()
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertionUpdates = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let message = anObject as! Message
        switch type{
        case .delete: fatalError()
        case .move: fatalError()
        case .update: break
        case .insert:
            let update = InsertionCalculator.getInfoFor(messageToInsert: message, currentSortedMessageBlocks: messageBlocks)
            insertionUpdates.append(update)
            setMessageBlocks()
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setMessageBlocks()
        delegate?.shouldMake(insertions: insertionUpdates)
        self.insertionUpdates = []
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageBlocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessagesCollectionViewCell
        cell.setWithBlock(block: messageBlocks[indexPath.row])
        return cell
    }
}






