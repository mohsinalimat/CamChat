//
//  MessageSender.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Reachability


struct MemoryBatchSendRequest{
    var memories: [Memory]
    var text: String?
    var users: [User]
}


class MessageSender {
    
    
    
    private var unsyncedMessageSendingDates = [String: (dateSent: Date, observer: HKManagedObjectObserver)]()
    
    func localDateSentForUnsyncedMessageWith(messageID: String) -> Date?{
        return unsyncedMessageSendingDates[messageID]?.dateSent
    }
    
    func send(message: TempMessage, sender: User, receiver: User) throws {
        guard sender.managedObjectContext === CoreData.mainContext && receiver.managedObjectContext === CoreData.mainContext else {
            throw HKError(description: "The context of the sender and receiver objects must be the main context.")
        }
        message.persist(sender: sender, receiver: receiver, context: .main, completion: { persistedMessage in
            CoreData.mainContext.saveChanges()
            self.handleStoredMessage(message: persistedMessage!)
            MessageWasSentNotification.post(with: message)
        })
    }
    
    private func handleStoredMessage(message: Message){
        let observer = message.observe { (change) in
            if message.isOnServer {
                self.unsyncedMessageSendingDates[message.uniqueID] = nil
            }
        }!
        unsyncedMessageSendingDates[message.uniqueID] = (Date(), observer)
    }
    
    
    
    /** Do not use this to send Memories!!! That will result in the actual photoVideoData not being coppied into a Message object, which means when the Memory is deleted, the actual data for the Message object will be deleted as well. So bad things will happen.
     
     Use the sendBatch function to send memories.
 
     **/
    
    func sendMessageUsingSingleMediaItem(_ media: PhotoVideoData, receivers: [User]) throws{
        for user in receivers where user.context != CoreData.mainContext{throw HKError.unknownError}
        let data: TempMessageUploadData
        switch media{
        case .photo: data = .photo(media)
        case .video: data = .video(media)
        }
        receivers.forEach{_sendBatchIndividualMessage(data: data, receiver: $0)}
    }
    
    func sendBatch(request: MemoryBatchSendRequest) throws{
        let error = HKError(description: "Only use managedObjects from the mainContext for use with this function")
        for user in request.users where user.context != CoreData.mainContext { throw error }
        for memory in request.memories where memory.context != CoreData.mainContext { throw error }
        let uploadDataObjects = request.memories.map{$0.info.getCopy()!}.map { (data) -> TempMessageUploadData in
            switch data{
            case .photo: return .photo(data);
            case .video: return .video(data)
            }
        }
        
        for user in request.users{
            uploadDataObjects.forEach{_sendBatchIndividualMessage(data: $0, receiver: user)}
            if let text = request.text{
                _sendBatchIndividualMessage(data: .text(text), receiver: user)
            }
        }
    }
    
    private func _sendBatchIndividualMessage(data: TempMessageUploadData, receiver: User){
        let message = TempMessage(data: .forUpload(data), dateSent: Date(), uniqueID: NSUUID().uuidString, senderID: DataCoordinator.currentUserUniqueID!, receiverID: receiver.uniqueID, wasSeenByReceiver: false, isOnServer: false)
        try! send(message: message, sender: DataCoordinator.currentUser!, receiver: receiver)
    }
}
