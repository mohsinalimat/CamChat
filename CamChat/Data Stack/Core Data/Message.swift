//
//  DBMessage+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import HelpKit
import CoreData


@objc(Message)
public class Message: NSManagedObject, ManagedObjectProtocol{
    
    static var entityName: String{
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
            
            sender.notifyOfMessageCreation(message: x)
            receiver.notifyOfMessageCreation(message: x)
            completion?(x)
        }
    }
    
    
    @NSManaged private(set) var text: String
    @NSManaged private(set) var dateSent: Date
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var sender: User
    @NSManaged private(set) var receiver: User
    @NSManaged private (set) var usersToWhomThisIsTheMostRecentMessage: Set<User>
    
    var currentUserIsReceiver: Bool{
        return receiver === DataCoordinator.currentUser
    }
    
    var currentUserIsSender: Bool{
        return sender === DataCoordinator.currentUser
    }
}


