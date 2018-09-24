//
//  ConversationCellVM.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ConversationCellVM {
    
    enum BottomInfoType{
        case `default`(image: UIImage, text: String)
        case sending
        case failed
    }
    
    
    private var user: User?
    
    func setWith(user: User){
        self.user = user
    }
    
    func getSubtitleInfo() -> (topText: String, bottomInfo: BottomInfoType)?{
        guard let user = user, let recentMessage = user.mostRecentMessage else {return nil}
        
        let topText = user.fullName
        
        if let dateSent = DataCoordinator.localDateSentForUnsyncedMessageWith(messageID: recentMessage.uniqueID){
            if -dateSent.timeIntervalSinceNow < 20 {return (topText, .sending)}
            else { return (topText, .failed) }
        } else if recentMessage.isOnServer.isFalse {
            return (topText, .failed)
        } else  {
            let info = getInfoForDefaultCase()
            
            return (topText, .default(image: info.image, text: info.text))
        }
    }
    
    private func getInfoForDefaultCase() -> (image: UIImage, text: String){
        guard let recentMessage = user?.mostRecentMessage else {fatalError()}
        
        
        var text: String
        let icon: UIImage
        
        
        if recentMessage.currentUserIsReceiver{
            
            if recentMessage.wasSeenByReceiver{
                text = "Received"
                icon = AssetImages.emptyTinyMessageIcon
            } else {
                text = "New Chat"
                icon = AssetImages.fullTinyMessageIcon
            }
        }  else if recentMessage.currentUserIsSender{
            
            if recentMessage.wasSeenByReceiver{
                text = "Opened"
                icon = AssetImages.emptyTinySendButton
            } else {
                text = "Sent"
                icon = AssetImages.fullTinySentIcon
            }
        } else { fatalError() }
        
        text = text + " · " + getTimeStringFor(date: recentMessage.dateSent)
        
        return (icon, text)
    }
    
  
    
    private func getTimeStringFor(date: Date) -> String{
        let seconds = -date.timeIntervalSinceNow
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days / 7
        let years = days / 365
        
        if seconds < 60 {return "just now"}
        else if minutes < 60{return "\(Int(minutes.rounded()))m"}
        else if hours < 24 {return "\(Int(hours.rounded()))h"}
        else if days < 7 {return "\(Int(days.rounded()))d"}
        else if days < 365{return "\(Int(weeks.rounded()))w"}
        else {return "\(Int(years.rounded()))y"}
    }
    
    
}









