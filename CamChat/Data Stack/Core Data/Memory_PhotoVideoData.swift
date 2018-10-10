//
//  MemoryData.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


enum PhotoVideoData: Hashable{
    

    case photo(_ image: URL, _ thumbnail: URL)
    case video(_ video: URL, _ thumbnail: URL)
    
    
    static func getFor(image: UIImage) -> PhotoVideoData? {
        guard let mainURL = writeToAndProduceURLFor(image: image, shouldCompress: false), let thumbnailURL = writeToAndProduceURLFor(image: image, shouldCompress: true) else {return nil}
        
        return .photo(mainURL, thumbnailURL)
    }
    
    static func getFor(videoAt url: URL) -> PhotoVideoData? {
        let image = Memory.getFirstFrameImageForVideoAt(url: url)
        guard let thumbnailURL = writeToAndProduceURLFor(image: image, shouldCompress: true) else {return nil}
        return .video(url, thumbnailURL)
    }
    
    
    private static func writeToAndProduceURLFor(image: UIImage, shouldCompress: Bool) -> URL?{
        guard let imageData = image.jpegData(compressionQuality: shouldCompress ? 0.05 : 1) else { return nil }
        let thumbnailURL = getNewURL(extension: "jpeg")
        do { try imageData.write(to: thumbnailURL) }
        catch { return nil }
        return thumbnailURL
    }
    
    func getCopy() -> PhotoVideoData?{
        
        guard let mainData = try? Data(contentsOf: urls.main), let thumbnailData = try? Data(contentsOf: urls.thumbnail) else {return nil}
        
        do{
            
            let newMainURL = PhotoVideoData.getNewURL(extension: (isVideo) ? "mp4" : "jpeg")
            try mainData.write(to: newMainURL)

            let newThumbnailURL = PhotoVideoData.getNewURL(extension: "jpeg")
            try thumbnailData.write(to: newThumbnailURL)
            
            if isVideo{return .video(newMainURL, newThumbnailURL)}
            else {return .photo(newMainURL, newThumbnailURL)}
            
            
        } catch {return nil}
        
    }
    
    func deleteAllCorrespondingData() throws {
        try FileManager.default.removeItem(at: urls.main)
        try FileManager.default.removeItem(at: urls.thumbnail)
    }
    
    
    var urls: (main: URL, thumbnail: URL){
        switch self{
        case let .photo(main, thumbnail): return (main, thumbnail)
        case let .video(main, thumbnail): return (main, thumbnail)
        }
    }
    
    private static func getNewURL(extension: String) -> URL{
        return FileManager.default.documentsDirectoryUrl.appendingPathComponent("\(NSUUID().uuidString)." + `extension`)
    }
    
    var thumbnail: UIImage {
        return UIImage(data: try! Data.init(contentsOf: urls.thumbnail))!
    }
    
    
    var image: UIImage{
        switch self {
        case let .photo(url, _): return UIImage(data: try! Data(contentsOf: url))!
        case let .video(url, _): return Memory.getFirstFrameImageForVideoAt(url: url)
        }
    }
    
    var isVideo: Bool{
        switch self {
        case .photo: return false
        case .video: return true
        }
    }
    
    var isPhoto: Bool{
        return isVideo.isFalse
    }
    
}


extension PhotoVideoData: Codable{
    
    private static var photoNum: Int { return 0 }
    private static var videoNum: Int { return 1}
    
    enum CodingKeys: CodingKey{
        case num
        case mainURL
        case thumbnailURL
    }
    
    
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        let thumbnailFileTitle = try container.decode(URL.self, forKey: .thumbnailURL).pathComponents.last!
        
        let mainResourceFileTitle = try container.decode(URL.self, forKey: .mainURL).pathComponents.last!
        let documentsURL = FileManager.default.documentsDirectoryUrl
        
        let thumbnailURL = documentsURL.appendingPathComponent(thumbnailFileTitle)
        let mainResourceURL = documentsURL.appendingPathComponent(mainResourceFileTitle)
        
        
        if num == PhotoVideoData.photoNum { self = .photo(mainResourceURL, thumbnailURL) }
        else if num == PhotoVideoData.videoNum { self = .video(mainResourceURL, thumbnailURL) }
        else { throw HKError(description: "could not decode from decoder") }
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .photo: try container.encode(PhotoVideoData.photoNum, forKey: .num)
        case .video: try container.encode(PhotoVideoData.videoNum, forKey: .num)
        }
        try container.encode(urls.thumbnail, forKey: .thumbnailURL)
        try container.encode(urls.main, forKey: .mainURL)
    }
}
