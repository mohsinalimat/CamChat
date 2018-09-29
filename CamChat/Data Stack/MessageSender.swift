//
//  MessageSender.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

/**
 
 In case you're lost as to the point of this class, here it is. The actual 'dateSent' property of a Message object, at some point, is gonna be merged with Firebase's server time or an estimate thereof, which is gonna be independent of the time on the user's device. Therefore, this property is not dependable enough to be compared against 'Date()' to see exactly how long ago, according to the device's time, the user actually attempted to send the message.

 This class exists so that the app can know how long ago the user attempted to send a message that has not been uploaded to firebase as yet due to connectivity issues.
 **/


class MessageSender {
    
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
}
