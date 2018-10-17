//
//  URLManager.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/13/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class URLManager {
    
    private static let memoryDirectoryString = "CamChat-Memories"
    private static let messageMediaDirectoryString = "CamChat-MessageMedia"
    
    enum URLExtension: String {
        case jpeg = "jpeg"
        case mp4 = "mp4"
    }
    
    enum URLType{
        case memory
        case messageMedia
    }
    
    static func getNewURLFor(urlType: URLType, extension: URLExtension) -> URL? {
        let uniqueString = NSUUID().uuidString
        switch urlType {
        case .memory:
            guard let currentUserID = DataCoordinator.currentUserUniqueID else {return nil}
            let directory = memoryDirectoryForUserWith(userID: currentUserID)
            return directory.appendingPathComponent("\(uniqueString).\(`extension`.rawValue)")
        case .messageMedia:
            return rootMessageMediaDirectoryURL.appendingPathComponent("\(uniqueString).\(`extension`)")
        }
    }
    
 
    
    static func getUpToDateURLForPersisted(URL: URL) -> URL?{
        let currentDocumentsURL = FileManager.default.documentsDirectoryUrl
        let components = URL.pathComponents
        guard let i = components.lastIndex(of: "Documents") else {return nil}
        let diff = components.lastItemIndex! - i
        guard diff > 0 else { return nil }
        let severedURL = components.lastItems(diff).joined(separator: "/")
        return currentDocumentsURL.appendingPathComponent(severedURL)
    }
    
    static func getSizeOfMessageMediaDirectory() -> Int{
        return getSizeOfItemAt(url: rootMessageMediaDirectoryURL)
    }
    
    static func getSizeOfMemoryDirectory() -> Int{
        return getSizeOfItemAt(url: rootMemoryDirectoryURL)
    }
    
    static func getSizeOfCurrentUserMemoryDirectory() -> Int{
        guard let currentUserID = DataCoordinator.currentUserUniqueID else {return 0}
        return getSizeOfItemAt(url: memoryDirectoryForUserWith(userID: currentUserID))
    }
    
    private static func getSizeOfItemAt(url: URL) -> Int{
        var x = 0
        if directoryExistsAt(url: url) {
            for item in try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []){
            
                x += getSizeOfItemAt(url: item)
            }
        }
        
        if let nsnum = try? FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? NSNumber{
            x += Int(truncating: nsnum!)
        }
        return x
    }

    
    private static var rootMessageMediaDirectoryURL: URL {
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent(self.messageMediaDirectoryString)
        createDirectoryIfNeededAt(url: url)
        return url
    }
    
    private static func memoryDirectoryForUserWith(userID: String) -> URL{
        let url = rootMemoryDirectoryURL.appendingPathComponent(userID)
        createDirectoryIfNeededAt(url: url)
        return url
    }
    
    
    private static var rootMemoryDirectoryURL: URL{
        let url = FileManager.default.documentsDirectoryUrl.appendingPathComponent(self.memoryDirectoryString)
        createDirectoryIfNeededAt(url: url)
        return url
    }
    
    private static func createDirectoryIfNeededAt(url: URL){
        if directoryExistsAt(url: url).isFalse{
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    
    private static func directoryExistsAt(url: URL) -> Bool{
        var isDirectory: ObjCBool = false
        
        let result = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return result.isTrue && isDirectory.boolValue.isTrue
    }
}
