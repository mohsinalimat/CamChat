//
//  Message_MessageData.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit





enum MessageData: Codable, Hashable{
    
    case text(String)
    case photoVideo(PhotoVideoData)
    
}

extension MessageData {
    
    private static var textNum: Int { return 0 }
    private static var photoVideoNum: Int { return 1 }
    
    enum CodingKeys: CodingKey{
        case num
        case text
        case memoryData
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        
        if num == MessageData.textNum {
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        } else if num == MessageData.photoVideoNum {
            let data = try container.decode(PhotoVideoData.self, forKey: .memoryData)
            self = .photoVideo(data)
        } else {
            throw HKError(description: "Could not decode a message data object from the provided decoder")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self{
        case let .text(text):
            try container.encode(MessageData.textNum, forKey: .num)
            try container.encode(text, forKey: .text)
        case let .photoVideo(data):
            try container.encode(MessageData.photoVideoNum, forKey: .num)
            try container.encode(data, forKey: .memoryData)
        }
        
        
    }
}








