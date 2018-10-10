//
//  DBMessage+CoreDataClass.swift
//  
//
//  Created by Patrick Hanna on 9/1/18.
//
//

import HelpKit


@objc(Message)
public class Message: NSManagedObject, ManagedObjectProtocol{
    
    static var entityName: String {
        return "Message"
    }
    
    
    static func createNew(usingTempMessage message: TempMessage, sender: User, receiver: User, context: CoreDataContextType, completion: ((Message) -> Void)? = nil){
        
        context.context.perform {
            if let message = Message.helper(context).getObjectWith(uniqueID: message.uniqueID){completion?(message); return}
            
            let x = Message(context: context.context)
            
            let messageData: MessageData
            
            switch message.data{
            case .forUpload(let uploadData):
                switch uploadData{
                case .photo(let data):messageData = .photo(data)
                case .video(let data):messageData = .video(data)
                case .text(let text): messageData = .text(text)
                }
            case .forDownload(let downloadData):
                switch downloadData{
                case .photo: messageData = .photo(nil)
                case .video: messageData = .video(nil)
                case .text(let text): messageData = .text(text)
                }
            }
            
            x.data = try! JSONEncoder().encode(messageData)
            x.dateSent = message.dateSent
            x.uniqueID = message.uniqueID
            x.sender = sender
            x.receiver = receiver
            x.wasSeenByReceiver = message.wasSeenByReceiver
            x.isOnServer = message.isOnServer
            
            sender.notifyOfMessageCreation(message: x)
            receiver.notifyOfMessageCreation(message: x)
            completion?(x)
        }
    }
    
    /// Is only to be called when network code wishes to update the object according to remote changes.
    func updateFromServerIfNeededWith(tempMessage: TempMessage){
        precondition(tempMessage.uniqueID == uniqueID)
        if tempMessage.wasSeenByReceiver && self.wasSeenByReceiver.isFalse{
            self.wasSeenByReceiver = true
            MessageWasSeenNotification.post(with: (message: getTempMessage(), wasSeenLocally: false))
        }
        if tempMessage.isOnServer && self.isOnServer.isFalse{
            self.isOnServer = true
        }
        if tempMessage.dateSent != self.dateSent{
            self.dateSent = tempMessage.dateSent
        }
    }
    
    /// Is only to be called LOCALLY when the current user sees the message.
    func markAsSeenIfNeeded(){
        if wasSeenByReceiver.isFalse{
            wasSeenByReceiver = true
            MessageWasSeenNotification.post(with: (message: getTempMessage(), wasSeenLocally: true))
        }
    }
    
    
    
    @NSManaged private var data: Data
    @NSManaged private(set) var dateSent: Date
    @NSManaged private(set) var uniqueID: String
    @NSManaged private(set) var sender: User
    @NSManaged private(set) var receiver: User
    @NSManaged private(set) var wasSeenByReceiver: Bool
    @NSManaged private(set) var isOnServer: Bool
    
    
    
    var info: MessageData{
        return try! JSONDecoder().decode(MessageData.self, from: data)
    }
    
    func setMessageDataTo(_ data: PhotoVideoData){
        if info.hasData.isTrue{return}
        let newData: MessageData
        switch info {
        case .photo: newData = .photo(data)
        case .video: newData = .video(data)
        default: fatalError()
        }
        self.data = try! JSONEncoder().encode(newData)
    }
    

    
    /// this guesses whether you want it to be for upload or download based on the avilabilty of its media information
    func getTempMessage() -> TempMessage{
        let tempMessageData: TempMessageData
        switch info{
        case .photo(let photoVideoData):
            if let data = photoVideoData {
                tempMessageData = .forUpload(.photo(data))
            } else { tempMessageData = .forDownload(.photo(messageID: uniqueID)) }
            
        case .video(let photoVideoData):
            if let data = photoVideoData{
                tempMessageData = .forUpload(.video(data))
            } else { tempMessageData = .forDownload(.video(messageID: uniqueID)) }
        case .text(let text):
            tempMessageData = .forUpload(.text(text))
        }
        
        return TempMessage(data: tempMessageData, dateSent: dateSent, uniqueID: uniqueID, senderID: sender.uniqueID, receiverID: receiver.uniqueID, wasSeenByReceiver: wasSeenByReceiver, isOnServer: isOnServer)
    }
    
    

    
    var currentUserIsReceiver: Bool{
        return receiver.uniqueID == DataCoordinator.currentUserUniqueID
    }
    
    var currentUserIsSender: Bool{
        return sender.uniqueID == DataCoordinator.currentUserUniqueID
    }
}


