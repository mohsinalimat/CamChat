//
//  MessageSender.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Reachability





class MessageSender {
    
    
    
    private var unsyncedMessageSendingDates = [String: (dateSent: Date, observer: HKManagedObjectObserver)]()
    
    func localDateSentForUnsyncedMessageWith(messageID: String) -> Date?{
        return unsyncedMessageSendingDates[messageID]?.dateSent
    }
    

  
    
    
    func sendMessages(uploadObjects: [TempMessageUploadData], receivers: [User] ) throws{
        let error = HKError(description: "Only use managedObjects from the mainContext for use with this function")
        for receiver in receivers where receiver.context != CoreData.mainContext { throw error }
    
        for receiver in receivers{
            for object in uploadObjects{
                let message = TempMessage(data: .forUpload(object), dateSent: Date(), uniqueID: NSUUID().uuidString, senderID: DataCoordinator.currentUserUniqueID!, receiverID: receiver.uniqueID, wasSeenByReceiver: false, isOnServer: false)
                send(message: message, sender: DataCoordinator.currentUser!, receiver: receiver)
            }
        }
    }

    
    private func send(message: TempMessage, sender: User, receiver: User) {
        
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
    
}
