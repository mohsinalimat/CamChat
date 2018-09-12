//
//  ConversationCellVM.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/9/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


struct ConversationCellVM{
    
    func getSubtitleInfoFor(user: User) -> (topText: String, bottomText: String, icon: UIImage){
        
        let topText = user.fullName
        var bottomText: String
        let icon: UIImage
        
        if user.mostRecentMessage!.currentUserIsReceiver{
            bottomText = "Received"
            icon = AssetImages.tinyMessageIcon
        } else if user.mostRecentMessage!.currentUserIsSender{
            bottomText = "Sent"
            icon = AssetImages.tinySentIcon
        } else { fatalError() }
        
        bottomText = bottomText + " · " + getTimeStringFor(date: user.mostRecentMessage!.dateSent)
        return (topText, bottomText, icon)
        
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









