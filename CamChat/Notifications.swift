//
//  Notifications.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



let UserLoggedInNotification = HKNotification<User>()
let UserLoggedOutNotification = HKNotification<Void>()


/// The wasSeenLocally parameter is false if the seen originated from an update from the network, and true, if the message was locally seen and has yet to be synced with the network.
let MessageWasSeenNotification = HKNotification<(message: TempMessage, wasSeenLocally: Bool)>()
let MessageWasSentNotification = HKNotification<TempMessage>()




