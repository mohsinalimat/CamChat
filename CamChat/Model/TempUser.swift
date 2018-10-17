//
//  TempUser.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class TempUser: Equatable {
    static func == (lhs: TempUser, rhs: TempUser) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
    
    
    
    
    
    private static var imageCache = HKCache<String, UIImage>(objectLimit: 40)
    
    
    
    init(firstName: String, lastName: String, username: String, email: String, profilePicture: UIImage? = nil, uniqueID: String){
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.uniqueID = uniqueID
        
        
        
        if let image = profilePicture{
            self.profilePicture = image
            TempUser.imageCache.set(value: image, forKey: uniqueID)
        } else if let image = TempUser.imageCache.valueFor(key: uniqueID){
            self.profilePicture = image
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
        if let image = profilePicture ?? TempUser.imageCache.valueFor(key: uniqueID) {
            completion?(.success((image, false)))
        } else {
            
            Firebase.getUserProfilePicture(userID: uniqueID) { callback in
                
                switch callback{
                case .success(let image):
                    self.profilePicture = image
                    TempUser.imageCache.set(value: image, forKey: self.uniqueID)
                    completion?(.success((image, true)))
                    
                case .failure(let error): completion?(.failure(error))
                }
            }
        }
        
    }
    
    
    
    
    /// Attempts to save the receiver as a Core Data object.
    func persist(usingContext context: CoreDataContextType, _ completion: ((HKCompletionResult<User>) -> Void)?){
    
        setProfileImage { (callBack) in

            switch callBack {
            case .success:
                if self.profilePicture == nil{fatalError()}
                User.createNew(fromTempUser: self, context: context, completion: { (user) in
                    completion?(.success(user))
                })
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
