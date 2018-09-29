//
//  DBMessage+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import HelpKit


@objc(Message)
public class Message: NSManagedObject, ManagedObjectProtocol{
    
    static var entityName: String {
        return "Message"
    }
    
    
    static func createNew(usingTempMessage message: TempMessage, sender: User, receiver: User, context: CoreDataContextType, completion: ((Message) -> Void)? = nil){
        
        context.context.perform {
            if let message = Message.helper(context).getObjectWith(uniqueID: message.uniqueID){completion?(message); return}
            
            let x = Message(context: context.context)
            
            x.text = message.text
            x.dateSent = message.dateSent
            x.uniqueID = message.uniqueID
            x.sender = sender
            x.receiver = receiver
            x.wasSeenByReceiver = message.wasSeenByReceiver
            x.isOnServer = message.isOnServer
            
            sender.notifyOfMessageCreation(message: x)
            receiver.notifyOfMessageCreation(message: x)
            completion?(x)
        }
    }
    
    /// Is only to be called when network code wishes to update the object according to remote changes.
    func updateFromServerIfNeededWith(tempMessage: TempMessage){
        
        if tempMessage.wasSeenByReceiver && self.wasSeenByReceiver.isFalse{
            self.wasSeenByReceiver = true
            MessageWasSeenNotification.post(with: (message: self.tempMessage, wasSeenLocally: false))
        }
        if tempMessage.isOnServer && self.isOnServer.isFalse{
            self.isOnServer = true
        }
        if tempMessage.dateSent != self.dateSent{
            self.dateSent = tempMessage.dateSent
        }
    }
    
    /// Is only to be called LOCALLY when the current user sees the message.
    func markAsSeenIfNeeded(){
        if wasSeenByReceiver.isFalse{
            wasSeenByReceiver = true
            MessageWasSeenNotification.post(with: (message: tempMessage, wasSeenLocally: true))
        }
    }
    
    
    
    @NSManaged private(set) var text: String
    @NSManaged private(set) var dateSent: Date
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var sender: User
    @NSManaged private(set) var receiver: User
    @NSManaged private(set) var wasSeenByReceiver: Bool
    @NSManaged private(set) var isOnServer: Bool
    
    
    
    var tempMessage: TempMessage{
        return TempMessage(text: text, dateSent: dateSent, uniqueID: uniqueID, senderID: sender.uniqueID, receiverID: receiver.uniqueID, wasSeenByReceiver: wasSeenByReceiver, isOnServer: isOnServer)
    }
    
    var currentUserIsReceiver: Bool{
        return receiver.uniqueID == DataCoordinator.currentUserUniqueID
    }
    
    var currentUserIsSender: Bool{
        return sender.uniqueID == DataCoordinator.currentUserUniqueID
    }
}


