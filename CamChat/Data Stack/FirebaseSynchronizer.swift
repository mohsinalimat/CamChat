//
//  FirebaseSynchronizer.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/18/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class FirebaseSynchronizer{
    
    func beginSynchronization(){
        MessageWasSeenNotification.listen(sender: self) { (message, wasSeenLocally) in
            if wasSeenLocally{
                Firebase.markMessageAsSeen(message: message)
            }
        }
        MessageWasSentNotification.listen(sender: self) { (message) in
            Firebase.send(message: message)
        }
    }
    
    
    deinit {
        MessageWasSeenNotification.removeListener(sender: self)
        MessageWasSentNotification.removeListener(sender: self)
    }
    
    
}
