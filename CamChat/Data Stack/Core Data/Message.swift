//
//  DBMessage+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import Foundation
import CoreData


@objc(Message)
public class Message: NSManagedObject, ManagedObjectProtocol{
    
    static var entityName: String{
        return "Message"
    }
    

    @discardableResult static func createNew(text: String, dateSent: Date, uniqueID: String, sender: User, receiver: User) -> Message{
        
        let x = Message(context: CoreData.context)
        
        x.text = text
        x.dateSent = dateSent
        x.uniqueID = uniqueID
        x.sender = sender
        x.receiver = receiver
        
        CoreData.saveChanges()
        return x
    }
    
    
    @NSManaged private(set) var text: String
    @NSManaged private(set) var dateSent: Date
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var sender: User
    @NSManaged private(set) var receiver: User
    

}


