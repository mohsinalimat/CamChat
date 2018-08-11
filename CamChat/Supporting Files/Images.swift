//
//  Images.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



struct AssetImages{
    
    private static func get(_ name: String) -> UIImage{
        guard let image = UIImage(named: name) else {
            print("The image named \(name) could not be found!")
            fatalError()
        }
        return image
    }
    
    static var chatBubble = get("chatBubble").templateImage
    static var me = get("me")
    static var photoIcon = get("photoIcon").templateImage
    static var snapchatGhost = get("snapchatGhost")
    static var settingsIcon = get("settingsIcon").templateImage
    static var flashOnIcon = get("flashOn").templateImage
    static var flashOffIcon = get("flashOff").templateImage
    static var cameraFlipIcon = get("cameraFlipIcon").templateImage
    static var magnifyingGlass = get("magnifyingGlass").templateImage
    static var selectItemsIcon = get("selectItemsIcon").templateImage
    static var newChatIcon = get("newChatIcon").templateImage
    static var arrowChevron = get("backArrow").templateImage
    static var threeLineMenuIcon = get("threeLineMenuIcon").templateImage
    static var xIcon = get("xButton").templateImage
    static var cancelButton = get("cancelButton").templateImage
    static var sendIcon = get("sendIcon").templateImage
}




