//
//  TempMessage.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


struct TempMessage{

    var text: String
    var dateSent: Date
    var uniqueID: String
    var senderID: String
    var receiverID: String
    
    var chatPartnerID: String?{
        if senderID == Firebase.currentUser?.uid{return receiverID}
        if receiverID == Firebase.currentUser?.uid{return senderID}
        else {return nil}
    }
    
    @discardableResult func persist(sender: User? = nil, receiver: User? = nil) -> Message?{
        
        let _sender: User
        if let sender = sender{_sender = sender}
        else {
            if let sender = User.getObjectWith(uniqueID: senderID){_sender = sender}
            else {return nil}
        }
        
        let _receiver: User
        if let receiver = receiver{_receiver = receiver}
        else {
            if let receiver = User.getObjectWith(uniqueID: receiverID){_receiver = receiver}
            else {return nil}
        }
        
        
        return Message.createNew(text: text, dateSent: dateSent, uniqueID: uniqueID, sender: _sender, receiver: _receiver)
    }
    
}

