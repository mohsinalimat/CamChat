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
    case message(blockIndex: IndexPath)
    
    case reload
}


private struct InsertionCalculator {
    
    static func getInfo(blockArray: [ChatMessageBlock], messageToInsert: Message, suggestedInsertionIndexPath: IndexPath) -> InsertionResult{
        if blockArray.isEmpty{return .reload}
        var counter = -1
        for (num, block) in blockArray.enumerated(){
            counter += block.messages.count
            if counter >= suggestedInsertionIndexPath.row{
                return .message(blockIndex: IndexPath(row: num, section: 0))
            }
        }
        if blockArray.last!.sender === messageToInsert.sender{
            return .message(blockIndex: IndexPath(row: blockArray.lastItemIndex!, section: 0))
        } else {return .block(blockIndex: IndexPath(row: blockArray.endIndex, section: 0))}
    }
}








class ChatTableViewVM: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource{
    
    
    private weak var tableView: UITableView!
    private var controller: NSFetchedResultsController<Message>!

    private let cellID = "CellID"
    
    
    
    init(tableView: UITableView, user: User){
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.register(ChatMessagesTableViewCell.self, forCellReuseIdentifier: cellID)
        
        let fetch = Message.typedFetchRequest()
       
        fetch.predicate = NSPredicate(format: "(\(#keyPath(Message.sender.uniqueID)) == %@) OR \(#keyPath(Message.receiver.uniqueID)) == %@", user.uniqueID, user.uniqueID)
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateSent), ascending: true)]
        self.controller = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        handleErrorWithPrintStatement(action: {try self.controller.performFetch()})
        setMessageBlocks()
        tableView.reloadData()
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
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      
    }
    

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        setMessageBlocks()
        tableView.reloadData()
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatMessagesTableViewCell
        cell.setWithBlock(block: messageBlocks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageBlocks.count
    }
}






