//
//  MemoryData.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


enum PhotoVideoData: Hashable{
    
   
    
    case photo(_ image: URL, _ thumbnail: UIImage)
    case video(_ video: URL, _ thumbnail: UIImage)
    
    
    static func getFor(image: UIImage) -> PhotoVideoData? {
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent("\(NSUUID().uuidString).jpeg")
        guard let data = image.jpegData(compressionQuality: 1) else {return nil}
        do { try data.write(to: url) } catch {return nil}
        let thumbnailImage = UIImage(data: image.jpegData(compressionQuality: 0.3)!)!
        return .photo(url, thumbnailImage)
    }
    
    static func getFor(videoAt url: URL) -> PhotoVideoData? {
        guard let thumbnailData = Memory.getImageForVideoAt(url: url).jpegData(compressionQuality: 0.3), let thumbnailImage = UIImage(data: thumbnailData) else {return nil}
        return .video(url, thumbnailImage)
    }
    
    var url: URL{
        switch self{
        case let .photo(url, _): return url
        case let .video(url, _): return url
        }
    }
    
    var thumbnail: UIImage {
        switch self{
        case let .photo(_ , thumbnail): return thumbnail
        case let .video(_ , thumbnail): return thumbnail
        }
    }
    
    
    var image: UIImage{
        
        switch self {
        case let .photo(url, _): return UIImage(data: try! Data(contentsOf: url))!
        case let .video(url, _): return Memory.getImageForVideoAt(url: url)
        }
    }
    
}


extension PhotoVideoData: Codable{
    
    
    enum CodingKeys: CodingKey{
        case num
        case url
        case thumbnail
    }
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        let thumbnailData = try container.decode(Data.self, forKey: .thumbnail)
        
        let documentTitle = try container.decode(URL.self, forKey: .url).pathComponents.last!
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent(documentTitle)
        let thumbnail = UIImage(data: thumbnailData)!
        
        if num == 0 { self = .photo(url, thumbnail) }
        else if num == 1 { self = .video(url, thumbnail) }
        else {throw HKError(description: "could not decode from decoder")}
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self{
        case let .photo(url, _):
            try container.encode(0, forKey: .num)
            try container.encode(url, forKey: .url)
            
        case let .video(url, _):
            try container.encode(1, forKey: .num)
            try container.encode(url, forKey: .url)
        }
        let thumbnailData = thumbnail.jpegData(compressionQuality: 1)
        try container.encode(thumbnailData, forKey: .thumbnail)
    }
    
    
}
