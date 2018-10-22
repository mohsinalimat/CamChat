//
//  CurrentUserInfo.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit





class CurrentUserInfo{
    
    private let IS_USER_LOGGED_IN_KEY = "IS USER LOGGED IN"
    private let CURRENT_USER_UNIQUE_ID = "CURRENT USER UNIQUE ID"
    
    private(set) var userIsLoggedIn: Bool{
        get { return UserDefaults.standard.bool(forKey: IS_USER_LOGGED_IN_KEY) }
        set { UserDefaultsStandard[IS_USER_LOGGED_IN_KEY] = newValue }
    }
    
    private(set) var currentUserUniqueID: String?{
        get { return UserDefaults.standard.string(forKey: CURRENT_USER_UNIQUE_ID) }
        set { UserDefaultsStandard[CURRENT_USER_UNIQUE_ID] = newValue }
    }
    
    private var _cachedCurrentUser: User?
    
    var currentUser: User?{
        if userIsLoggedIn.isFalse{return nil}
        if let user = _cachedCurrentUser{return user}
        if let userID = currentUserUniqueID, let user = User.helper(.main).getObjectWith(uniqueID: userID){
            _cachedCurrentUser = user
            return user
        } else {fatalError()}
    }
    
    func changeCurrentUsersNameTo(firstName: String, lastName: String){
        guard let currentUser = currentUser else {fatalError()}
        try! currentUser.changeNameTo(firstName: firstName, lastName: lastName){[weak currentUser] in
            CurrentUsersNameWasChangedNotification.post(with: (firstName, lastName, currentUser!.fullName))
        }
        
    }
    
    
    init(){
        UserLoggedInNotification.listen(sender: self) { [weak self] (user) in
            self?.userIsLoggedIn = true
            self?._cachedCurrentUser = user
            self?.currentUserUniqueID = user.uniqueID
        }
        UserLoggedOutNotification.listen(sender: self) { [weak self] in
            self?.userIsLoggedIn = false
            self?.currentUserUniqueID = nil
            self?._cachedCurrentUser = nil
            
        }
    }
    
    
}
