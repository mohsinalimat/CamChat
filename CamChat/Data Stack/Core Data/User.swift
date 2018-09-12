//
//  DBUser+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import HelpKit
import CoreData


fileprivate extension UIImage{
    var data: Data{
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

@objc(User)
public class User: NSManagedObject, ManagedObjectProtocol{
    
    static var entityName: String{
        return "User"
    }
    
    var isCurrentUser: Bool{
        return self.uniqueID == DataCoordinator.currentUser?.uniqueID
    }
    
    
    @discardableResult static func createNew(lastName: String, firstName: String, username: String, email: String, profilePicture: UIImage?, uniqueID: String) -> User{
        
        if User.hasStoredObjectWith(uniqueID: uniqueID){
            return User.getObjectWith(uniqueID: uniqueID)!
        }
        
        let x = User(context: CoreData.context)
        x.lastName = lastName
        x.firstName = firstName
        x.username = username
        x.email = email
        x.uniqueID = uniqueID
        
        if let data = profilePicture?.data{
            x.profilePictureData = data
        }
        
        
        CoreData.saveChanges()
        return x
    }
    
    @NSManaged private(set) var lastName: String
    @NSManaged private(set) var username: String
    @NSManaged private(set) var firstName: String
    @NSManaged private(set) var email: String
    @NSManaged private var profilePictureData: Data?
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var mostRecentMessage: Message?

    @NSManaged private var receivedMessages: Set<Message>
    @NSManaged private var sentMessages: Set<Message>
    
    var messages: Set<Message>{
        return receivedMessages.union(sentMessages)
    }

    
    func notifyOfMessageCreation(message: Message){
        if (message.sender === self || message.receiver === self).isFalse{return}
        if let mostRecent = mostRecentMessage{
            if message.dateSent > mostRecent.dateSent{ mostRecentMessage = message }
        } else { mostRecentMessage = message }
        CoreData.saveChanges()
    }
    
    func notifyOfMessageDeletion(message: Message){
        let sortedMessages = messages.filter{$0 !== message}.sorted(by: {$0.dateSent < $1.dateSent})
        self.mostRecentMessage = sortedMessages.last
        CoreData.saveChanges()
    }
    
    /// Deletes the receiver permenantly if it has no messages associated with it.
    func deleteIfNotNeeded(){
        if messages.isEmpty{ delete() }
    }
    
    
    var profilePicture: UIImage? {
        if let data = profilePictureData{
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIImage
        } else {return nil}
    }
    
    var fullName: String{
        return firstName + " " + lastName
    }
    
   
    var tempUser: TempUser {
        return TempUser(firstName: firstName, lastName: lastName, username: username, email: email, profilePicture: profilePicture, uniqueID: uniqueID)
    }
    
    
    
}
