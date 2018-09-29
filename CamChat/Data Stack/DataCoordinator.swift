//
//  DataCoordinator.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

let DataCoordinator = CCDataCoordinator.shared

class CCDataCoordinator{
    
    fileprivate static var shared = CCDataCoordinator()
    private init() {  }
    
    
    var currentUserUniqueID: String?{
        return currentUserInfo.currentUserUniqueID
    }
    
    var currentUser: User?{
        return currentUserInfo.currentUser
    }
    
    var userIsLoggedIn: Bool{
        return currentUserInfo.userIsLoggedIn
    }
    
    func localDateSentForUnsyncedMessageWith(messageID: String) -> Date?{
        guard let messageSender = messageSender else {return nil}
        return messageSender.localDateSentForUnsyncedMessageWith(messageID: messageID)
    }
    
    func send(message: TempMessage, sender: User, receiver: User) throws {
        guard let messageSender = messageSender else {throw HKError.unknownError}
        do { try messageSender.send(message: message, sender: sender, receiver: receiver) }
        catch { throw error }
    }

    
    private var currentUserInfo = CurrentUserInfo()
    private var messageSender: MessageSender?
 
    
    func configure(){
        if userIsLoggedIn{
            beginSyncing()
            self.messageSender = MessageSender()
        }
    }
    
    func signUpAndLogIn(signUpProgressionInfo: SignUpProgressionOuput, completion: @escaping (HKCompletionResult<User>) -> Void){
        Firebase.signUpAndSignIn(with: signUpProgressionInfo, completion: { callback in
            DispatchQueue.main.async {
                self.handleLoginCompletionActions(completion: completion, callback: callback)
            }
        })
    }
    
    func logIn(info: LoginInfo, completion: @escaping (HKCompletionResult<User>) -> Void){
        Firebase.logIn(loginInfo: info) { (callback) in
            DispatchQueue.main.async {
                self.handleLoginCompletionActions(completion: completion, callback: callback)
            }
        }
    }
    
    
    private func handleLoginCompletionActions(completion: @escaping (HKCompletionResult<User>) -> Void, callback: HKCompletionResult<TempUser>){
        
        switch callback{
        case .success(let tempUser):
            tempUser.persist(usingContext: .main) { (callback) in
                switch callback {
                case .success(let user):
                    CoreData.mainContext.saveChanges()
                    self.messageSender = MessageSender()
                    UserLoggedInNotification.post(with: user)
                    completion(.success(user))
                    self.beginSyncing()
                case .failure(let error):
                    handleErrorWithPrintStatement { try self.logOut() }
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            handleErrorWithPrintStatement { try self.logOut() }
            completion(.failure(error))
        }
    }
    
    
    func logOut() throws{
        do {
            try Firebase.logOut()
            endSyncing()
            messageSender = nil
            UserLoggedOutNotification.post()
            CoreData.performAndSaveChanges(context: .background) {
                Message.helper(.background).deleteAllObjects()
                User.helper(.background).deleteAllObjects()
            }
        } catch { throw error }
    }
    
    
 
    
    func performChatPresentationActionsForUser(user: User){
        user.startSeeningAllSentMessages()
    }
    
    
    func performChatDismissalActionsFor(user: User){
        let context = user.managedObjectContext!
        context.perform {
            user.stopSeeningAllSentMessages()
            if user.messages.isEmpty{
                context.delete(user)
                context.saveChanges()
            }
        }
    }

    
    
    
    private var coreDataSyncer: CoreDataSynchronizer?
    private var firebaseSyncer: FirebaseSynchronizer?

    
    
    private func beginSyncing(){
        coreDataSyncer = CoreDataSynchronizer()
        coreDataSyncer!.beginSynchronization()
        
        firebaseSyncer = FirebaseSynchronizer()
        firebaseSyncer!.beginSynchronization()
    }
    
    private func endSyncing(){
        coreDataSyncer = nil
        firebaseSyncer = nil
    }
    
    
    
    
    
}
