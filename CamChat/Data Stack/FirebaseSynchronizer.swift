//
//  FirebaseSynchronizer.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/18/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Reachability
import FirebaseStorage

class FirebaseSynchronizer {
    

    private let pendingMessagesKey = "PENDING MESSAGES FOR UPLOAD 2134I2O3I4U2"
    private var pendingMessages: Set<TempMessage>{
        get {
            if let data = UserDefaults.standard.data(forKey: pendingMessagesKey){
                return try! PropertyListDecoder().decode(Set<TempMessage>.self, from: data)
            } else { return [] }
        } set {
            let data = try! PropertyListEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: pendingMessagesKey)
        }
    }
    
    private var reachability = Reachability()!
    
    private var syncingHasBegun = false
    
    func beginSynchronization(){
        
        if syncingHasBegun{return}
        syncingHasBegun = true
        
        UserLoggedOutNotification.listen(sender: self) {
            self.pendingMessages.removeAll()
            self.removeListeners()
        }
        
        MessageWasSeenNotification.listen(sender: self) { (message, wasSeenLocally) in
            if wasSeenLocally{
                Firebase.markMessageAsSeen(message: message)
            }
        }
        MessageWasSentNotification.listen(sender: self) { (message) in
            self.tryUploading(message: message)
        }
        CurrentUsersNameWasChangedNotification.listen(sender: self) { (args) in
            Firebase.updateNameOfUser(userID: DataCoordinator.currentUserUniqueID!, firstName: args.newFirstName, lastName: args.newLastName)
        }
    
        reachability.whenReachable = {[weak self] (reach: Reachability) -> Void in
            switch reach.connection {
            case .cellular, .wifi: self?.tryUploadingPendingMessages()
            case .none: break
            }
        }
        handleErrorWithPrintStatement { try reachability.startNotifier() }
        
    }
    

    
    
    
    private func tryUploadingPendingMessages(){
        pendingMessages.forEach{self.tryUploading(message: $0)}
    }
    
    
    private func tryUploading(message: TempMessage){
        self.pendingMessages.insert(message)
        Firebase.send(message: message) { callback in
            switch callback {
            case .success:
                self.pendingMessages = self.pendingMessages.filter({$0.uniqueID != message.uniqueID })
            case .failure:
                switch self.reachability.connection{
                case .cellular, .wifi: self.tryUploading(message: message)
                default: break
                }
            }
        }
    }

    private func removeListeners(){
        reachability.stopNotifier()
        MessageWasSeenNotification.removeListener(sender: self)
        MessageWasSentNotification.removeListener(sender: self)
        UserLoggedOutNotification.removeListener(sender: self)
        CurrentUsersNameWasChangedNotification.removeListener(sender: self)
        
    }
    
    deinit { removeListeners() }
    
    
}
