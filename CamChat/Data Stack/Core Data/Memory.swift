//
//  Memory+CoreDataProperties.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
//

import HelpKit
import AVFoundation



enum MemoryType: Codable{
    
    enum CodingKeys: CodingKey{
        case num
        case url
    }
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(Int.self, forKey: .num)
        
        let documentTitle = try container.decode(URL.self, forKey: .url).pathComponents.last!
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent(documentTitle)
        if num == 0 { self = .photo(url) }
        else if num == 1 { self = .video(url) }
        else {throw HKError(description: "could not decode from decoder")}
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self{
        case .photo(let url):
            try container.encode(0, forKey: .num)
            try container.encode(url, forKey: .url)
        case .video(let url):
            try container.encode(1, forKey: .num)
            try container.encode(url, forKey: .url)
        }
    }
    
    case photo(URL)
    case video(URL)
    
    
    static func getFor(image: UIImage) -> MemoryType?{
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent("\(NSUUID().uuidString).jpeg")
        guard let data = image.jpegData(compressionQuality: 1) else {return nil}
        do{ try data.write(to: url) } catch {return nil}
        
        return .photo(url)
    }
    
    var url: URL{
        
        
        switch self{
        case let .photo(url): return url
        case let .video(url): return url
        }
    }
    
    
    var image: UIImage{
        
        switch self{
        case let .photo(url): return UIImage(data: try! Data(contentsOf: url))!
        case let .video(url): return Memory.getImageForVideoAt(url: url)
        }
        
      
    }
    
}



@objc(Memory)
public class Memory: NSManagedObject, ManagedObjectProtocol {
    static var entityName: String{
        return "Memory"
    }
    
    static func createNew(uniqueID: String, authorID: String, type: MemoryType, dateTaken: Date, context: CoreDataContextType, completion: ((Memory) -> Void)?){
        context.context.perform {
            if let memory = Memory.helper(context).getObjectWith(uniqueID: uniqueID){
                completion?(memory)
                return
            }
            
            let x = Memory(context: context.context)
            x.authorID = authorID
            x.dateTaken = dateTaken
            x.uniqueID = uniqueID
            x.data = try! JSONEncoder().encode(type)
            completion?(x)
        }
    }
    
    
    @NSManaged var uniqueID: String
    @NSManaged var authorID: String
    @NSManaged private var data: Data
    @NSManaged var dateTaken: Date
    
    
    var info: MemoryType {
        return try! JSONDecoder().decode(MemoryType.self, from: data)
    }
    
    /// Please use this function to delete a memory so that the actual videos and photos in the file system will be deleted as well. Note that this function does not save chnages.
    func delete(completion: (() -> Void)? = nil){
        handleErrorWithPrintStatement {
            try FileManager.default.removeItem(at: info.url)
        }
        context.perform {
            self.context.delete(self)
            completion?()
        }
        
    }
    
    
}







