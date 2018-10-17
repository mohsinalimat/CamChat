//
//  File.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


extension TempMessageDownloadData: Codable {
    
    
    private static var textNum: Int{return 0}
    private static var photoNum: Int{return 1}
    private static var videoNum: Int{return 2}
    
    enum CodingKeys: CodingKey{
        case text
        case num
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        let text = try container.decode(String.self, forKey: .text)
        
        switch num{
        case TempMessageDownloadData.textNum: self = .text(text)
        case TempMessageDownloadData.photoNum: self = .photo(messageID: text)
        case TempMessageDownloadData.videoNum: self = .video(messageID: text)
        default: throw HKError.unknownError
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(TempMessageDownloadData.textNum, forKey: .num)
            try container.encode(text, forKey: .text)
        case .photo(messageID: let text):
            try container.encode(TempMessageDownloadData.photoNum, forKey: .num)
            try container.encode(text, forKey: .text)
        case .video(messageID: let text):
            try container.encode(TempMessageDownloadData.videoNum, forKey: .num)
            try container.encode(text, forKey: .text)
        }
    }
    
}

extension TempMessageUploadData: Codable {
    
    private static var textNum: Int{return 0}
    private static var photoNum: Int{return 1}
    private static var videoNum: Int{return 2}
    
    enum CodingKeys: CodingKey{
        case text
        case photoVideoData
        case num
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        let text = try? container.decode(String.self, forKey: .text)
        let data = try? container.decode(PhotoVideoData.self, forKey: .photoVideoData)
        switch num{
        case TempMessageUploadData.textNum: self = .text(text!)
        case TempMessageUploadData.photoNum: self = .photo(data!)
        case TempMessageUploadData.videoNum: self = .video(data!)
        default: throw HKError.unknownError
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self{
        case .text(let text):
            try container.encode(TempMessageUploadData.textNum, forKey: .num)
            try container.encode(text, forKey: .text)
        case .photo(let data):
            try container.encode(TempMessageUploadData.photoNum, forKey: .num)
            try container.encode(data, forKey: .photoVideoData)
        case .video(let data):
            try container.encode(TempMessageUploadData.videoNum, forKey: .num)
            try container.encode(data, forKey: .photoVideoData)
        }
    }
    
}

extension TempMessageData: Codable {
    
    private static var uploadNum: Int{return 0}
    private static var downloadNum: Int{return 1}
    
    enum CodingKeys: CodingKey{
        case uploadData
        case downloadData
        case num
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        let uploadData = try? container.decode(TempMessageUploadData.self, forKey: .uploadData)
        let downloadData = try? container.decode(TempMessageDownloadData.self, forKey: .downloadData)
        switch num{
        case TempMessageData.uploadNum: self = .forUpload(uploadData!)
        case TempMessageData.downloadNum: self = .forDownload(downloadData!)
        default: throw HKError.unknownError
        }
        
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self{
        case .forDownload(let data):
            try container.encode(TempMessageData.downloadNum, forKey: .num)
            try container.encode(data, forKey: .downloadData)
        case .forUpload(let data):
            try container.encode(TempMessageData.uploadNum, forKey: .num)
            try container.encode(data, forKey: .uploadData)
        }
    }
}


extension TempMessage{
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TempMessage else {return false}
        
        return object.data == data &&
        object.dateSent == dateSent &&
        object.isOnServer == isOnServer &&
        object.receiverID == receiverID &&
        object.senderID == senderID &&
        object.wasSeenByReceiver == wasSeenByReceiver &&
        object.uniqueID == uniqueID

        
    }
}
