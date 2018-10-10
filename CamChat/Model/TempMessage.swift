//
//  TempMessage.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

enum TempMessageDownloadData: Hashable{
    case text(String)
    case photo(messageID: String)
    case video(messageID: String)
}

enum TempMessageUploadData: Hashable{
    case text(String)
    case photo(PhotoVideoData)
    case video(PhotoVideoData)
}

enum TempMessageData: Hashable{
    case forUpload(TempMessageUploadData)
    case forDownload(TempMessageDownloadData)
}


class TempMessage: NSObject, Codable{
    
   
    init(data: TempMessageData, dateSent: Date, uniqueID: String, senderID: String, receiverID: String, wasSeenByReceiver: Bool, isOnServer: Bool){
        self.data = data
        self.dateSent = dateSent
        self.uniqueID = uniqueID
        self.senderID = senderID
        self.receiverID = receiverID
        self.wasSeenByReceiver = wasSeenByReceiver
        self.isOnServer = isOnServer
    }
    
    let data: TempMessageData
    let dateSent: Date
    let uniqueID: String
    let senderID: String
    let receiverID: String
    let wasSeenByReceiver: Bool
    let isOnServer: Bool
    
    var chatPartnerID: String?{
        guard let currentUserID = DataCoordinator.currentUserUniqueID else {return nil}
        if senderID == currentUserID{return receiverID}
        if receiverID == currentUserID{return senderID}
        else {return nil}
    }
    
    func persist(sender: User? = nil, receiver: User? = nil, context: CoreDataContextType, completion: ((Message?) -> Void)? = nil){
        context.context.perform {
            let _sender: User
            if let sender = sender{_sender = sender}
            else {
                if let sender = User.helper(context).getObjectWith(uniqueID: self.senderID){_sender = sender}
                else {completion?(nil); return}
            }
            
            let _receiver: User
            if let receiver = receiver{_receiver = receiver}
            else {
                if let receiver = User.helper(context).getObjectWith(uniqueID: self.receiverID){_receiver = receiver}
                else {completion?(nil); return}
            }
            
            Message.createNew(usingTempMessage: self, sender: _sender, receiver: _receiver, context: context, completion: { (message) in
                completion?(message)
            })
            
        }
        
    }
    
}
