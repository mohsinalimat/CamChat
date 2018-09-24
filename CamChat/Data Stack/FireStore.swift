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
    
    struct MessageKeys{
        static var chatPartnerID = "chatPartnerID"
        static var messagesCollection = "Messages"
        static var messageID = "messageID"
        static var wasSeen = "wasSeen"
    }
    
}

private struct MessageKeys{
    static var messagesCollection = "Messages"
    static var uniqueID = "uniqueID"
    static var senderID = "senderID"
    static var receiverID = "receiverID"
    static var dateSent = "dateSent"
    static var text = "text"
    static var wasSeen = "wasSeen"
}




class FirebaseManager{
    private init() { FirebaseApp.configure() }
    fileprivate static var shared = FirebaseManager()
    
    
    
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
        return usersCollection.document(userID).collection(UserKeys.MessageKeys.messagesCollection)
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
        DispatchQueue.main.async {
            self.profilePicturesFolder.child(userID).getData(maxSize: Int64.max) { (data, error) in
                if let data = data, let image = UIImage(data: data){
                    completion(.success(image))
                } else {
                    completion(.failure(error ?? HKError.unknownError))
                    
                }
            }
        }
        
    }
    
    
    
    
    func getAllUsers(completion: @escaping(HKCompletionResult<[TempUser]>) -> Void){
        guard let currentUserID = DataCoordinator.currentUserUniqueID else {fatalError("There must be a current user for this function to work!")}
        usersCollection.order(by: UserKeys.firstName).getDocuments(completion: { (snapshot, error) in
            if let snapshot = snapshot{
                
                let users = snapshot.documents.map{self.parseUserDocumentInfo(from: $0.data())!}
                let results = users.filter({$0.uniqueID != currentUserID})
                
                completion(.success(results))
            } else {completion(.failure(error ?? HKError.unknownError))}
        })
        
    }
    
    
    
    func send(message: TempMessage){
        guard let currentUser = DataCoordinator.currentUser else {return}
        
        let dict: [String: Any] = [
            MessageKeys.uniqueID: message.uniqueID,
            MessageKeys.dateSent: FieldValue.serverTimestamp(),
            MessageKeys.receiverID: message.receiverID,
            MessageKeys.senderID: message.senderID,
            MessageKeys.text: message.text,
            MessageKeys.wasSeen: message.wasSeenByReceiver
        ]
        
        let writeBatch = Firebase.firestore.batch()
        
        // Updating the main messages Collection
        
        let newMessageDoc = messagesCollection.document(message.uniqueID)
        writeBatch.setData(dict, forDocument: newMessageDoc)
        
        // Updating the current user's personal messages Collection
        
        let currentUserMessageDoc = self.messagesCollectionForUserWith(userID: currentUser.uniqueID).document(message.uniqueID)
        let currentUserData: [String: Any] = [
            UserKeys.MessageKeys.messageID: message.uniqueID,
            UserKeys.MessageKeys.chatPartnerID: message.chatPartnerID!,
            UserKeys.MessageKeys.wasSeen: message.wasSeenByReceiver
        ]
        writeBatch.setData(currentUserData, forDocument: currentUserMessageDoc)
        
        // Updating the chatPartner's personal messages Collection
        
        let chatPartnerMessageDoc = messagesCollectionForUserWith(userID: message.chatPartnerID!).document(message.uniqueID)
        let chatPartnerData: [String: Any] = [
            UserKeys.MessageKeys.messageID: message.uniqueID,
            UserKeys.MessageKeys.chatPartnerID: DataCoordinator.currentUser!.uniqueID,
            UserKeys.MessageKeys.wasSeen: message.wasSeenByReceiver
        ]
        writeBatch.setData(chatPartnerData, forDocument: chatPartnerMessageDoc)
        writeBatch.commit()
    }
    
    
    
    /// WARNING: IF YOU EVER ENABLE CHAT DELETION, THIS FUNCTION WILL INTERFERE WITH THAT!!! FIX IT!!
    func markMessageAsSeen(message: TempMessage){
        messagesCollection.document(message.uniqueID).setData([MessageKeys.wasSeen: true], merge: true)
        for id in [message.senderID, message.receiverID]{
            messagesCollectionForUserWith(userID: id).document(message.uniqueID).setData([UserKeys.MessageKeys.wasSeen: true], merge: true)
        }
    }
    
    
    
    
    
    @discardableResult func observeMessagesForUser(userID: String, action: @escaping (HKCompletionResult<Set<TempMessage>>) -> Void) -> ListenerRegistration{
        
        return messagesCollectionForUserWith(userID: userID).addSnapshotListener(includeMetadataChanges: true) {[weak self] (snapshot, error) in
            guard let self = self else { return }
            if let snapshot = snapshot {
                var messages = Set<TempMessage>(){
                    didSet{
                        if messages.count >= snapshot.documentChanges.count
                        { action(.success(messages)) }
                    }
                }
                
                
                for change in snapshot.documentChanges(includeMetadataChanges: true){
                    
                    let messageID = change.document.documentID
                    
                    self.getMessageFor(messageID: messageID, completion: { (callback) in
                        switch callback{
                        case .success(let message):
                            messages.insert(message)
                        case .failure: return
                        }
                    })
                }
            } else { action(.failure(error ?? HKError.unknownError ))}
        }
    }
    
    
    
    private func getMessageFor(messageID: String, completion: @escaping (HKCompletionResult<TempMessage>) -> Void){
        
        messagesCollection.document(messageID).getDocument { (snapshot, error) in
                if let snapshot = snapshot {
                    let dict = snapshot.data(with: ServerTimestampBehavior.estimate)!
                    
                    let receiver = dict[MessageKeys.receiverID] as! String
                    let sender = dict[MessageKeys.senderID] as! String
                    let uniqueID = dict[MessageKeys.uniqueID] as! String
                    let date = (dict[MessageKeys.dateSent] as! Timestamp).dateValue()
                    let text = dict[MessageKeys.text] as! String
                    let wasSeen = dict[MessageKeys.wasSeen] as! Bool
                    
                    let isOnServer = snapshot.metadata.isFromCache.isFalse
                    let message = TempMessage(text: text, dateSent: date, uniqueID: uniqueID, senderID: sender, receiverID: receiver, wasSeenByReceiver: wasSeen, isOnServer: isOnServer)
                    
                    completion(.success(message))
                } else { completion(.failure(error ?? HKError.unknownError)) }
            }
            
        
        
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

