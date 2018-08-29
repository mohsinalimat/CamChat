//
//  FireStore.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Firebase
import FirebaseAuth

let Firebase = FirebaseManager.shared


private struct UserKeys{
    static var userCollection = "Users"
    static var uniqueID = "uniqueID"
    static var firstName = "firstName"
    static var lastName = "lastName"
    static var email = "email"
    static var username = "username"
}




class FirebaseManager{
    private init() { FirebaseApp.configure() }
    fileprivate static var shared = FirebaseManager()
    
    
    
    private var firestore: Firestore{
        return Firestore.firestore()
    }
    
    private var usersCollection: CollectionReference{
        return firestore.collection(UserKeys.userCollection)
    }
    
    
    func configure(){
        let settings = firestore.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestore.settings = settings
    }
    
    
    
    func logIn(loginInfo: LoginInfo, completion: @escaping (User?, Error?) -> Void){
        Auth.auth().signIn(withEmail: loginInfo.email, password: loginInfo.password) { (result, error) in
            if let result = result{
                self.getUser(userID: result.user.uid, completion: { (user, error) in
                    if let user = user{ user.setAsCurrentUser(); completion(user, nil) }
                    else {completion(nil, error ?? HKError.unknownError)}
                })
            } else {completion(nil, error ?? HKError.unknownError)}
        }
    }
    
    
    func signUpAndSignIn(with info: UserSignUpProgressionInfo, errorHandler: @escaping (Error?) -> Void) {
        if info.progressionIsComplete.isFalse{
            errorHandler(HKError(description: "all user info fields were not filled out"))
        }
        Auth.auth().createUser(withEmail: info.email!, password: info.password!) { (result, error) in
            if let result = result {
                let user = User(signUpProgressionInfo: info, uniqueID: result.user.uid)!
                user.setAsCurrentUser()
                self.addUserToDatabase(user: user)
                errorHandler(nil)
            }
            else {errorHandler(error)}
        }
    }
    
    func logOut() throws {
        do{ try Auth.auth().signOut() }
        catch { throw error }
        User.setCurrentUser(to: nil)
    
    }
    
    func addUserToDatabase(user: User){
        let x = UserKeys.self
        let dict = [x.uniqueID: user.uniqueID, x.firstName: user.firstName, x.lastName: user.lastName, x.username: user.username, x.email: user.email]
        usersCollection.document(user.uniqueID).setData(dict)
    }
    
    func getAllUsers(completion: @escaping ([User]?, Error?) -> Void){
        usersCollection.getDocuments { (querySnapshot, error) in
            if let qSnapshot = querySnapshot{
                let users = qSnapshot.documents.map { self.parseUserDocumentInfo(from: $0.data()) }.filterOutNils()
                completion(users, nil)
            } else {completion(nil, error ?? HKError.unknownError)}
        }
    }
    
    func getUser(userID: String, completion: @escaping (User?, Error?) -> Void){
        usersCollection.document(userID).getDocument { (snapshot, error) in
            if let snapshot = snapshot, let user = self.parseUserDocumentInfo(from: snapshot.data()) {completion(user, nil)}
            else {completion(nil, error ?? HKError.unknownError)}
        }
    }
    
    private func parseUserDocumentInfo(from dict: [String: Any]?) -> User?{
        if let dict = dict,
            let email = dict[UserKeys.email] as? String,
            let firstName = dict[UserKeys.firstName] as? String,
            let lastName = dict[UserKeys.lastName] as? String,
            let username = dict[UserKeys.username] as? String,
            let uniqueId = dict[UserKeys.uniqueID] as? String
        {
            return User(firstName: firstName, lastName: lastName, email: email, username: username, uniqueID: uniqueId)
        } else {return nil}
    }
    
    
    
    
    
    
}

