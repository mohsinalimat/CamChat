//
//  MessageSender.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Reachability


struct MemoryBatchSendRequest{
    var memories: [Memory]
    var text: String?
    var users: [User]
}


class MessageSender {
    
    let reachability = Reachability()!
    
    private var unsyncedMessageSendingDates = [String: (dateSent: Date, observer: HKManagedObjectObserver)]()
    
    func localDateSentForUnsyncedMessageWith(messageID: String) -> Date?{
        return unsyncedMessageSendingDates[messageID]?.dateSent
    }
    
    func send(message: TempMessage, sender: User, receiver: User) throws {
        guard sender.managedObjectContext === CoreData.mainContext && receiver.managedObjectContext === CoreData.mainContext else {
            throw HKError(description: "The context of the sender and receiver objects must be the main context.")
        }
        message.persist(sender: sender, receiver: receiver, context: .main, completion: { persistedMessage in
            CoreData.mainContext.saveChanges()
            self.handleStoredMessage(message: persistedMessage!)
            MessageWasSentNotification.post(with: message)
        })
    }
    
    private func handleStoredMessage(message: Message){
        let observer = message.observe { (change) in
            if message.isOnServer {
                self.unsyncedMessageSendingDates[message.uniqueID] = nil
            }
        }!
        unsyncedMessageSendingDates[message.uniqueID] = (Date(), observer)
    }
    
    
    
    func sendBatch(request: MemoryBatchSendRequest) throws{
        let error = HKError(description: "Only use managedObjects from the mainContext for use with this function")
        for user in request.users where user.context != CoreData.mainContext { throw error }
        for memory in request.memories where memory.context != CoreData.mainContext { throw error }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
}
