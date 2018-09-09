//
//  TempUser.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class TempUser {
    
    
    private static var cache = HKCache<String, UIImage>(objectLimit: 40)
    
    
    init(firstName: String, lastName: String, username: String, email: String, profilePicture: UIImage? = nil, uniqueID: String){
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.uniqueID = uniqueID
        
        
        if let image = profilePicture{
            self.profilePicture = image
            TempUser.cache.set(value: image, forKey: uniqueID)
        }
        
    }
    
    var fullName: String{
        return firstName + " " + lastName
    }
    var lastName: String
    var username: String
    var firstName: String
    var email: String
    private(set) var profilePicture: UIImage?
    var uniqueID: String
    
    
    
    func setProfileImage(_ completion: ((HKCompletionResult<(image: UIImage, wasDownloaded: Bool)>) -> Void)?){
        if let image = profilePicture ?? TempUser.cache.valueFor(key: uniqueID) {
            completion?(.success((image, false)))
        } else {
            
            Firebase.getUserProfilePicture(userID: uniqueID) { callback in
                
                switch callback{
                case .success(let image):
                    self.profilePicture = image
                    TempUser.cache.set(value: image, forKey: self.uniqueID)
                    completion?(.success((image, true)))
                    
                case .failure(let error): completion?(.failure(error))
                }
            }
        }
        
    }
    
    
    /// Attempts to save the receiver as a Core Data object.
    func persist(_ completion: ((HKCompletionResult<User>) -> Void)?){
        
        setProfileImage { (callBack) in

            switch callBack{
            case .success(let args):
                let user = User.createNew(lastName: self.lastName, firstName: self.firstName, username: self.username, email: self.email, profilePicture: args.image, uniqueID: self.uniqueID)
                completion?(.success(user))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
