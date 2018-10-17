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
    
    
    static func getFor(image: UIImage, for urlType: URLManager.URLType) -> PhotoVideoData? {
        
        guard let mainURL = writeToAndProduceURLFor(image: image, shouldCompress: false, urlType: urlType),
            let thumbnailURL = writeToAndProduceURLFor(image: image, shouldCompress: true, urlType: urlType) else {return nil}
        
        return .photo(mainURL, thumbnailURL)
    }
    
    static func getFor(videoAt url: URL, for urlType: URLManager.URLType) -> PhotoVideoData? {
        let image = Memory.getFirstFrameImageForVideoAt(url: url)
        guard let thumbnailURL = writeToAndProduceURLFor(image: image, shouldCompress: true, urlType: urlType) else {return nil}
        return .video(url, thumbnailURL)
    }
    
    
    private static func writeToAndProduceURLFor(image: UIImage, shouldCompress: Bool, urlType: URLManager.URLType) -> URL?{
    
        let imageData = image.jpegData(compressionQuality: shouldCompress ? 0.05 : 1)!
        let thumbnailURL = URLManager.getNewURLFor(urlType: urlType, extension: .jpeg)!

        do { try imageData.write(to: thumbnailURL) }
        catch { print(error); return nil }
        return thumbnailURL
    }
    
    /// Duplicates all files at both urls and returns an object containing the new urls.
    
    func getCopy(for urlType: URLManager.URLType) -> PhotoVideoData?{
        
        guard let mainData = try? Data(contentsOf: urls.main), let thumbnailData = try? Data(contentsOf: urls.thumbnail) else {return nil}
        guard let newThumbnailURL = URLManager.getNewURLFor(urlType: urlType, extension: .jpeg) else {return nil}
        
        let newMainURL: URL
        
        switch self {
        case .photo:
            guard let x = URLManager.getNewURLFor(urlType: urlType, extension: .jpeg) else { return nil }
            newMainURL = x
        case .video:
            guard let x = URLManager.getNewURLFor(urlType: urlType, extension: .mp4) else { return nil }
            newMainURL = x
        }
        
        do{
            try mainData.write(to: newMainURL)
            try thumbnailData.write(to: newThumbnailURL)
            
            if isVideo{return .video(newMainURL, newThumbnailURL)}
            else {return .photo(newMainURL, newThumbnailURL)}
            
        } catch {return nil}
        
    }
    
    func getTempMessageUploadData() -> TempMessageUploadData{
        switch self {
        case .photo: return .photo(self)
        case .video: return .video(self)
        }
    }
    
    func deleteAllCorrespondingData() {
        try? FileManager.default.removeItem(at: urls.main)
        try? FileManager.default.removeItem(at: urls.thumbnail)
    }
    
    
    var urls: (main: URL, thumbnail: URL){
        switch self{
        case let .photo(main, thumbnail): return (main, thumbnail)
        case let .video(main, thumbnail): return (main, thumbnail)
        }
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
        let oldThumbnailURL = try container.decode(URL.self, forKey: .thumbnailURL)
        
        let oldMainResourceURL = try container.decode(URL.self, forKey: .mainURL)
        
        let thumbnailURL = URLManager.getUpToDateURLForPersisted(URL: oldThumbnailURL)!
        let mainResourceURL = URLManager.getUpToDateURLForPersisted(URL: oldMainResourceURL)!
    
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
