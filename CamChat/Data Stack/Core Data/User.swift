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
public class User: NSManagedObject, ManagedObjectProtocol {
    
    static var entityName: String{
        return "User"
    }
    
    
    
    
    @discardableResult static func createNew(lastName: String, firstName: String, username: String, email: String, profilePicture: UIImage?, uniqueID: String) -> User{
        
        
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

    @NSManaged private(set) var receivedMessages: Set<Message>
    @NSManaged private(set) var sentMessages: Set<Message>

    
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
