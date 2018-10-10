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
    case photo(PhotoVideoData?)
    case video(PhotoVideoData?)
    
    
    
    
    var hasData: Bool{
        switch self{
        case .text: return true
        case .photo(let data): return data.isNotNil
        case .video(let data): return data.isNotNil
        }
    }
    
    var photoVideodata: PhotoVideoData?{
        switch self{
        case .text: return nil
        case .photo(let data): return data
        case .video(let data): return data
        }
    }
    
}

extension MessageData {
    
    private static var textNum: Int { return 0 }
    private static var photoNum: Int { return 1 }
    private static var videoNum: Int { return 3 }
    
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
        } else if num == MessageData.photoNum {
            let data = try? container.decode(PhotoVideoData.self, forKey: .memoryData)
            self = .photo(data)
        } else if num == MessageData.videoNum{
            let data = try? container.decode(PhotoVideoData.self, forKey: .memoryData)
            self = .video(data)
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
        case let .photo(data):
            try container.encode(MessageData.photoNum, forKey: .num)
            try container.encode(data, forKey: .memoryData)
        case let .video(data):
            try container.encode(MessageData.videoNum, forKey: .num)
            try container.encode(data, forKey: .memoryData)
        }
        
        
    }
}








