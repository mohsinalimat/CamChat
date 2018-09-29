//
//  CoreDataSynchronizer.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Firebase


class CoreDataSynchronizer{
    
    private var listener: ListenerRegistration?
    
    func beginSynchronization(){
        

        if listener.isNotNil{ return }
        listener = Firebase.observeMessagesForUser(userID: DataCoordinator.currentUserUniqueID!, action: {[weak self] (callback) in
            guard let self = self else { return }
            
            switch callback {
                
            case .success(let messages):
                CoreData.backgroundContext.perform {
                    self.syncCoreDataWith(messages: messages)
                }
            case .failure(let error): print(error)
            }
            
        })
    }
    
   
    
    private func syncCoreDataWith(messages: Set<TempMessage>){
        CoreData.backgroundContext.perform {
            let messagesSorted = Dictionary(grouping: messages, by: {$0.chatPartnerID!})
            guard let currentUser = User.helper(.background).getObjectWith(uniqueID: DataCoordinator.currentUserUniqueID!) else {return}
            
  
            for (userID, userMessages) in messagesSorted{
                
                if User.helper(.background).hasStoredObjectWith(uniqueID: userID).isFalse{
                    
                    self.getUserFor(userID: userID) {
                        self.storeMessagesFor(userID: userID, user: $0, messages: userMessages, currentUser: currentUser)
                    }
                } else {
                    let user = User.helper(.background).getObjectWith(uniqueID: userID)!
                    self.storeMessagesFor(userID: userID, user: user, messages: userMessages, currentUser: currentUser)
                }
            }
        }
    }
    
    
    
    
    private func getUserFor(userID: String, completion: @escaping (User) -> Void){
        Firebase.getUser(userID: userID) { (callback) in
            
            switch callback {
            case .success(let tempUser):
                CoreData.backgroundContext.perform {
                    tempUser.persist(usingContext: .background){ (callback) in
                        
                        switch callback{
                        case .success(let user):
                            
                            CoreData.backgroundContext.perform {
                                completion(user)
                            }
                            
                        case .failure(let error): print(error)
                        }
                    }
                }
            case .failure(let error): print(error)
                
            }
        }
        
    }
    






    
    private func storeMessagesFor(userID: String, user: User, messages: [TempMessage], currentUser: User){
        CoreData.backgroundContext.perform {
            
            var processedMessagesCount = 0{
                didSet{
                    if processedMessagesCount >= messages.count{ CoreData.backgroundContext.saveChanges() }
                }
            }
            
            for tempMessage in messages {
                
                
                if let message = Message.helper(.background).getObjectWith(uniqueID: tempMessage.uniqueID){
                    message.updateFromServerIfNeededWith(tempMessage: tempMessage)
                    processedMessagesCount += 1; continue
                }
                
                
                let receiver: User = {
                    if user.uniqueID == tempMessage.receiverID{return user}
                    else if currentUser.uniqueID == tempMessage.receiverID{return currentUser}
                    else { fatalError() }
                }()
                
                let sender: User = {
                    if user.uniqueID == tempMessage.senderID { return user }
                    else if currentUser.uniqueID == tempMessage.senderID { return currentUser }
                    else { fatalError() }
                }()

                
                tempMessage.persist(sender: sender, receiver: receiver, context: .background, completion: {_ in processedMessagesCount += 1})
            }
        }
        
        
    }
    
    
    
    deinit { listener?.remove() }
    
}

