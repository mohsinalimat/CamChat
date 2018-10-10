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




@objc(Memory)
public class Memory: NSManagedObject, ManagedObjectProtocol {
    static var entityName: String{
        return "Memory"
    }
    
    static func createNew(uniqueID: String, authorID: String, type: PhotoVideoData, dateTaken: Date, context: CoreDataContextType, completion: ((Memory) -> Void)?){
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
    
    private var _info: PhotoVideoData?
    
    var info: PhotoVideoData {
        if _info.isNil {
            _info = try! JSONDecoder().decode(PhotoVideoData.self, from: data)
        }
        return _info!
    }
    
    /// Please use this function to delete a memory so that the actual videos and photos in the file system will be deleted as well. Note that this function does not save chnages.
    func delete(completion: (() -> Void)? = nil){
        handleErrorWithPrintStatement {
            try FileManager.default.removeItem(at: info.urls.main)
            try FileManager.default.removeItem(at: info.urls.thumbnail)
        }
        context.perform {
            self.context.delete(self)
            completion?()
        }
        
    }
    
    
}







