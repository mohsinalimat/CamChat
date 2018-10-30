//
//  CoreDataSynchronizer.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Firebase
import Reachability

class CoreDataSynchronizer{
    
    private var messagesListener: ListenerRegistration?
    private var usersListeners = [ListenerRegistration]()
    private var reachability = Reachability()!
    
    
    private let pendingMessagesKey = "PENDING MESSAGES FOR DOWNLOAD 23094823049823"
    private var pendingMessages: Set<TempMessage>{
        get{
            if let data = UserDefaults.standard.data(forKey: pendingMessagesKey){
                return try! PropertyListDecoder().decode(Set<TempMessage>.self, from: data)
            } else { return [] }
        } set {
            let data = try! PropertyListEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: pendingMessagesKey)
        }
    }
    
    private var syncingHasBegan = false
    
    
    
    func beginSynchronization(){
        if syncingHasBegan { return }
        syncingHasBegan = true
        
        if messagesListener.isNotNil{ return }
        
        UserLoggedOutNotification.listen(sender: self) {
            self.pendingMessages.removeAll()
            self.removeListeners()
        }

        
        startListeningForNetworkConnectionChanges()
        startListeningForUserChanges()
        startListeningForMessages()
    }
    
    private func startListeningForNetworkConnectionChanges(){
        
        reachability.whenReachable = {[weak self] (reach: Reachability) -> Void in
            switch reach.connection{
            case .cellular, .wifi:
                self?.pendingMessages.forEach{self?.tryGettingDataFor(tempMessage: $0)}
            default: break
            }
        }
        try! reachability.startNotifier()
        
        
    }
    
    private func startListeningForUserChanges(){
        let allUsers = User.helper(.background).fetchAll()
        
        for user in allUsers{
            let listener = Firebase.observeUserWith(uniqueID: user.uniqueID) { (updatedTempUser) in
                if let user = User.helper(.background).getObjectWith(uniqueID: updatedTempUser.uniqueID){
                    user.updateIfNeeded(with: updatedTempUser)
                }
            }
            
            usersListeners.append(listener)
        }
    }
    
    private func startListeningForMessages(){
        messagesListener = Firebase.observeMessagesForUser(userID: DataCoordinator.currentUserUniqueID!, action: {[weak self] (callback) in
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
                    processedMessagesCount += 1
                    if message.info.hasData.isFalse{
                        self.tryGettingDataFor(tempMessage: tempMessage)
                    }
                    continue
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

                
                tempMessage.persist(sender: sender, receiver: receiver, context: .background, completion: {message in
                    processedMessagesCount += 1
                    if message!.info.hasData.isFalse{
                        self.tryGettingDataFor(tempMessage: tempMessage)
                    }
                })
            }
        }
    }
    
    
    private func tryGettingDataFor(tempMessage: TempMessage){
        DispatchQueue.main.async {
            self.pendingMessages.insert(tempMessage)
        }
        
        Firebase.downloadMediaDataFor(message: tempMessage) { (result) in
            switch result {
            case .success(let data):
                
                defer {
                    DispatchQueue.main.async {
                        self.pendingMessages = self.pendingMessages.filter({$0.uniqueID != tempMessage.uniqueID})
                    }
                }
                
                guard let message = Message.helper(.background).getObjectWith(uniqueID: tempMessage.uniqueID), message.info.hasData.isFalse else {return}
                
                
                message.context.perform {
                    switch message.info {
                    case .photo:
                        let image = UIImage(data: data)!
                        message.setMessageDataTo(PhotoVideoData.getFor(image: image, for: .messageMedia)!)
                    case .video:
                        let newURL = URLManager.getNewURLFor(urlType: .messageMedia, extension: .mp4)!
                        try! data.write(to: newURL)
                        message.setMessageDataTo(PhotoVideoData.getFor(videoAt: newURL, for: .messageMedia)!)
                    default: fatalError()
                    }
                    message.context.saveChanges()
                }
                
            case .failure:
                switch self.reachability.connection{
                case .cellular, .wifi:
                    self.tryGettingDataFor(tempMessage: tempMessage)
                case .none: break
                }
            }
        }
    }
    
    
    
    
    private func removeListeners(){
        reachability.stopNotifier()
        messagesListener?.remove()
        messagesListener = nil
        usersListeners.forEach{$0.remove()}
        usersListeners.removeAll()
        UserLoggedOutNotification.removeListener(sender: self)
    }
    
    
    deinit { removeListeners() }
    
}

