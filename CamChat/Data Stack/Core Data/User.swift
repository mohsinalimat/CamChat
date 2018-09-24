//
//  DBUser+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import HelpKit


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
        return self.uniqueID == DataCoordinator.currentUserUniqueID
    }
    
    
    
    static func createNew(fromTempUser user: TempUser, context: CoreDataContextType, completion: ((User) -> Void)? = nil){
    
        context.context.perform {
            if let user = User.helper(context).getObjectWith(uniqueID: user.uniqueID){ completion?(user); return }
            
            let x = User(context: context.context)
            x.lastName = user.lastName
            x.firstName = user.firstName
            x.username = user.username
            x.email = user.email
            x.uniqueID = user.uniqueID
            
            if let data = user.profilePicture?.data{
                x.profilePictureData = data
            } else {
                fatalError("the profile picture must be set on the provided TempUser object")
            }
            completion?(x)
        }
    }
    
    @NSManaged private(set) var lastName: String
    @NSManaged private(set) var username: String
    @NSManaged private(set) var firstName: String
    @NSManaged private(set) var email: String
    @NSManaged private var profilePictureData: Data
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var mostRecentMessage: Message?

    @NSManaged private(set) var receivedMessages: Set<Message>
    @NSManaged private(set) var sentMessages: Set<Message>
    
    var messages: Set<Message>{
        return receivedMessages.union(sentMessages)
    }
    
    
    /// This represents the user who's received messages will automtically be seened when received. (Due to their chat currently being open.)
    private static var currentUserIDForSeening: String?
    
    
    func startSeeningAllSentMessages(){
        User.currentUserIDForSeening = self.uniqueID
        managedObjectContext!.perform {
            self.sentMessages.forEach{$0.markAsSeenIfNeeded()}
            self.managedObjectContext!.saveChanges()
        }
    }
    
    func stopSeeningAllSentMessages(){
        User.currentUserIDForSeening = nil
    }
    
    
    func notifyOfMessageCreation(message: Message){
        self.mostRecentMessage = self.getMostRecentMessage()
        if self.uniqueID == User.currentUserIDForSeening && message.sender == self {
            message.markAsSeenIfNeeded()
        }
    }
    
    func notifyOfMessageDeletion(message: Message){
        managedObjectContext!.perform {
            self.mostRecentMessage = self.getMostRecentMessage()
        }
        
    }
    
    
    private func getMostRecentMessage() -> Message? {
        let request = Message.typedFetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Message.sender.uniqueID))  == %@ OR \(#keyPath(Message.receiver.uniqueID)) == %@", self.uniqueID, self.uniqueID)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateSent), ascending: false)]
        request.fetchLimit = 1
        
        var messageToReturn: Message?
        do{ messageToReturn = try self.context.fetch(request).first }
        catch { fatalError() }
        
        return messageToReturn
    }
   
    
    
    var profilePicture: UIImage {
        return NSKeyedUnarchiver.unarchiveObject(with: profilePictureData) as! UIImage
    }
    
    var fullName: String{
        return firstName + " " + lastName
    }
    
   
    var tempUser: TempUser {
        return TempUser(firstName: firstName, lastName: lastName, username: username, email: email, profilePicture: profilePicture, uniqueID: uniqueID)
    }
    
    
    
}
