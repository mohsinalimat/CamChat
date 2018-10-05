//
//  Images.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



struct AssetImages{
    
  
    
    private static func getPhoto(_ name: String) -> UIImage{
        guard let image = UIImage(named: name) else {
            print("The image named \(name) could not be found!")
            fatalError()
        }
        return image
    }
    
    private static func getIcon(_ name: String) -> UIImage{
        return getPhoto(name).templateImage
    }
    
    static var chatBubble = getIcon("chatBubble")
    static var me = getPhoto("me")
    static var photoIcon = getIcon("photoIcon")
    static var snapchatGhost = getPhoto("snapchatGhost")
    static var settingsIcon = getIcon("settingsIcon")
    static var flashOnIcon = getIcon("flashOn")
    static var flashOffIcon = getIcon("flashOff")
    static var cameraFlipIcon = getIcon("cameraFlipIcon")
    static var magnifyingGlass = getIcon("magnifyingGlass")
    static var selectItemsIcon = getIcon("selectItemsIcon")
    static var newChatIcon = getIcon("newChatIcon")
    static var arrowChevron = getIcon("backArrow")
    static var threeLineMenuIcon = getIcon("threeLineMenuIcon")
    static var xIcon = getIcon("xButton")
    static var cancelButton = getIcon("cancelButton")
    static var sendIcon = getIcon("sendIcon")
    static var shareIcon = getIcon("shareIcon")
    static var trashIcon = getIcon("trashIcon")
    static var threeDotMoreIcon = getIcon("moreIcon")
    static var snapCode = getPhoto("snapcode")
    
    static var emptyTinyMessageIcon = getIcon("emptyTinyMessageIcon")
    static var fullTinyMessageIcon = getIcon("tinyMessageIcon")
    
    static var emptyTinySendButton = getIcon("emptyTinySendButton")
    static var fullTinySentIcon = getIcon("tinySentIcon")
    
    static var errorIcon = getIcon("errorIcon")
    
    static var accountUser = getIcon("accountUser")
    static var notification = getIcon("notification")
    static var logOut = getIcon("logOut")
    static var storage = getIcon("storage")
    
    static var profilePicturePlaceholder = getIcon("profilePicturePlaceholder")
    static var downloadIcon = getIcon("downloadIcon")
    static var checkMarkCircle = getIcon("checkMarkCircle")
    
    static var examplePhotos = [
        getPhoto("iphoneImage0"),
        getPhoto("iphoneImage1"),
        getPhoto("iphoneImage2"),
        getPhoto("iphoneImage3"),
        getPhoto("iphoneImage4")
    ]
    
}




