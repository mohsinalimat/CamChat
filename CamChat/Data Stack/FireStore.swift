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
import FirebaseStorage




let Firebase = FirebaseManager.shared


private struct UserKeys{
    
    static var userCollection = "Users"
    static var uniqueID = "uniqueID"
    static var firstName = "firstName"
    static var lastName = "lastName"
    static var email = "email"
    static var username = "username"
    
    static var chatPartnerID = "chatPartnerID"
    static var messagesCollection = "Messages"
    static var messageID = "messageID"
}

private struct MessageKeys{
    static var messagesCollection = "Messages"
    static var uniqueID = "uniqueID"
    static var senderID = "senderID"
    static var receiverID = "receiverID"
    static var dateSent = "dateSent"
    static var text = "text"
}




class FirebaseManager{
    private init() { FirebaseApp.configure() }
    fileprivate static var shared = FirebaseManager()
    
    var currentUser: Firebase.User?{
        return Auth.auth().currentUser
    }
    
    private var firestore: Firestore{
        return Firestore.firestore()
    }
    
    var usersCollection: CollectionReference{
        return firestore.collection(UserKeys.userCollection)
    }
    var messagesCollection: CollectionReference{
        return firestore.collection(MessageKeys.messagesCollection)
    }
    
    func messagesCollectionForUserWith(userID: String) -> CollectionReference{
        return usersCollection.document(userID).collection(UserKeys.messagesCollection)
    }
    
    
    
    private var profilePicturesFolder: StorageReference{
        return Storage.storage().reference(withPath: "UserProfilePictures")
    }
    
    
    func configure(){
        let settings = firestore.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestore.settings = settings
    }
    
    
    
    func logIn(loginInfo: LoginInfo, completion: @escaping (HKCompletionResult<TempUser>) -> Void){
        Auth.auth().signIn(withEmail: loginInfo.email, password: loginInfo.password) { (result, error) in
            
            if let result = result{
                self.getUser(userID: result.user.uid, completion: { completion($0) })
            } else {completion(.failure(error ?? HKError.unknownError))}
        }
    }
    
    
    func signUpAndSignIn(with info: SignUpProgressionOuput, completion: @escaping (HKCompletionResult<TempUser>) -> Void) {
        Auth.auth().createUser(withEmail: info.email, password: info.password) { (result, error) in
            if let result = result {
                self.addUserToDatabase(info: info, uniqueID: result.user.uid, completion: {
                    completion($0)
                })
            } else { completion(.failure(error ?? HKError.unknownError)) }
        }
    }
    
    func logOut() throws {
        do{ try Auth.auth().signOut() }
        catch { throw error }
    }
    
    
    
    
    private func addUserToDatabase(info: SignUpProgressionOuput, uniqueID: String, completion: ((HKCompletionResult<TempUser>) -> Void)?){
        
        let compressedImageData = info.profilePicture.jpegData(compressionQuality: 0.5)!
        
        
        profilePicturesFolder.child(uniqueID).putData(compressedImageData, metadata: nil) { (meta, error) in
            if let error = error{completion?(.failure(error)); return}
            
            let x = UserKeys.self
            let dict = [x.uniqueID: uniqueID, x.firstName: info.firstName, x.lastName: info.lastName, x.username: info.username, x.email: info.email]
            self.usersCollection.document(uniqueID).setData(dict)
            
            let user = self.parseUserDocumentInfo(from: dict, profilePicture: UIImage(data: compressedImageData)!)!
            
            completion?(.success(user))
        }
    }
    
    
    
    func getUser(userID: String, completion: @escaping (HKCompletionResult<TempUser>) -> Void){
        usersCollection.document(userID).getDocument { (snapshot, error) in
            if let snapshot = snapshot, let user = self.parseUserDocumentInfo(from: snapshot.data()) {
                completion(.success(user))
            }
            else { completion(.failure(error ?? HKError.unknownError)) }
        }
    }
    
    private func parseUserDocumentInfo(from dict: [String: Any]?, profilePicture: UIImage? = nil) -> TempUser?{
        if let dict = dict,
            let email = dict[UserKeys.email] as? String,
            let firstName = dict[UserKeys.firstName] as? String,
            let lastName = dict[UserKeys.lastName] as? String,
            let username = dict[UserKeys.username] as? String,
            let uniqueId = dict[UserKeys.uniqueID] as? String {
            return TempUser(firstName: firstName, lastName: lastName, username: username, email: email, profilePicture: profilePicture, uniqueID: uniqueId)
        } else { return nil }
    }
    
    
    
    
    
    func getUserProfilePicture(userID: String, completion: @escaping (HKCompletionResult<UIImage>) -> Void){
        profilePicturesFolder.child(userID).getData(maxSize: Int64.max) { (data, error) in
            if let data = data, let image = UIImage(data: data){
                completion(.success(image))
            } else {
                completion(.failure(error ?? HKError.unknownError))
                
            }
        }
    }
    
    
    
    
    func getAllUsers(completion: @escaping(HKCompletionResult<[TempUser]>) -> Void){
        guard let currentUser = currentUser else {fatalError("There must be a current user for this function to work!")}
        usersCollection.order(by: UserKeys.firstName).getDocuments(completion: { (snapshot, error) in
            if let snapshot = snapshot{
                
                let users = snapshot.documents.map{self.parseUserDocumentInfo(from: $0.data())!}
                let results = users.filter({$0.uniqueID != currentUser.uid})
                
                completion(.success(results))
            } else {completion(.failure(error ?? HKError.unknownError))}
        })
        
    }
    
    
    
    func send(message: TempMessage){
        precondition(self.currentUser.isNotNil, "There must be a current user for this function to work!")
        
        let dict: [String: Any] = [
            MessageKeys.uniqueID: message.uniqueID,
            MessageKeys.dateSent: message.dateSent,
            MessageKeys.receiverID: message.receiverID,
            MessageKeys.senderID: message.senderID,
            MessageKeys.text: message.text
        ]
        
        let writeBatch = Firebase.firestore.batch()
        
        // Updating the main messages Collection
        
        let newMessageDoc = messagesCollection.document(message.uniqueID)
        writeBatch.setData(dict, forDocument: newMessageDoc)
        
        // Updating the current user's personal messages Collection
        
        let currentUserMessageDoc = self.messagesCollectionForUserWith(userID: currentUser!.uid).document(message.uniqueID)
        let currentUserData = [
            UserKeys.messageID: message.uniqueID,
            UserKeys.chatPartnerID: message.chatPartnerID!
        ]
        writeBatch.setData(currentUserData, forDocument: currentUserMessageDoc)
        
        // Updating the chatPartner's personal messages Collection
        
        let chatPartnerMessageDoc = messagesCollectionForUserWith(userID: message.chatPartnerID!).document(message.uniqueID)
        let chatPartnerData = [
            UserKeys.messageID: message.uniqueID,
            UserKeys.chatPartnerID: currentUser!.uid
        ]
        writeBatch.setData(chatPartnerData, forDocument: chatPartnerMessageDoc)
        writeBatch.commit()
    }
    
    
    
    
    
    
    
    @discardableResult func observeMessagesForUser(userID: String, action: @escaping (HKCompletionResult<[TempMessage]>) -> Void) -> ListenerRegistration{
        
        return messagesCollectionForUserWith(userID: userID).addSnapshotListener {[weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let snapshot = snapshot{
                var messages = [TempMessage](){
                    didSet{
                        if messages.count >= snapshot.documentChanges.count
                        { action(.success(messages)) }
                    }
                }
                
                for change in snapshot.documentChanges{
                    let messageID = change.document.data()[UserKeys.messageID] as! String
                    self.getMessageFor(messageID: messageID, completion: { (callback) in
                        switch callback{
                        case .success(let message): messages.append(message)
                        case .failure: return
                        }
                    })
                }
            } else { action(.failure(error ?? HKError.unknownError ))}
        }
    }
    
    
    
    private func getMessageFor(messageID: String, completion: @escaping (HKCompletionResult<TempMessage>) -> Void){
        
        messagesCollection.document(messageID).getDocument { (snapshot, error) in
            if let snapshot = snapshot{
                let dict = snapshot.data()!
                
                let receiver = dict[MessageKeys.receiverID] as! String
                let sender = dict[MessageKeys.senderID] as! String
                let uniqueID = dict[MessageKeys.uniqueID] as! String
                let date = (dict[MessageKeys.dateSent] as! Timestamp).dateValue()
                let text = dict[MessageKeys.text] as! String
                
                let message = TempMessage(text: text, dateSent: date, uniqueID: uniqueID, senderID: sender, receiverID: receiver)
                
                completion(.success(message))
            } else { completion(.failure(error ?? HKError.unknownError)) }
        }
        
    }
    
    
    
    
    
    
    
    
    
    /// Deletes all user database entries, and user profile pictures from firebase.
    func cleanOutEntireDatabase(){
        let writeBatch = firestore.batch()
        
        usersCollection.getDocuments { (snapshot, error) in
            if let snapshot = snapshot{
                for item in snapshot.documents{
                    let uniqueID = item.data()[UserKeys.uniqueID]! as! String
                    self.messagesCollectionForUserWith(userID: uniqueID).delete(writeBatch: writeBatch)
                    self.profilePicturesFolder.child(uniqueID).delete(completion: nil)
                    writeBatch.deleteDocument(self.usersCollection.document(uniqueID))
                }
            }
        }
        writeBatch.commit()
    }
    
    
    
    
    
    
    
}


extension CollectionReference{
    
    func delete(writeBatch: WriteBatch? = nil){
        getDocuments { (snapshot, error) in
            if let snapshot = snapshot{
                for doc in snapshot.documents{
                    let doc = self.document(doc.documentID)
                    if let writeBatch = writeBatch{
                        writeBatch.deleteDocument(doc)
                    } else { doc.delete() }
                }
            }
        }
    }
}

