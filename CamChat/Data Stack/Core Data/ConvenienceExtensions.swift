//
//  CCMangedObject.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData


protocol ManagedObjectProtocol {
    static var entityName: String { get }
    var uniqueID:String {get}
}

extension ManagedObjectProtocol where Self: NSManagedObject{
    
    static func deleteAllObjects(){
        handleErrorWithPrintStatement {
            let request = NSBatchDeleteRequest(fetchRequest: fetchRequest())
            try CoreData.context.execute(request)
            CoreData.saveChanges()
        }
    }

    static func typedFetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: entityName)
    }
    
    static func fetchAll(sortedUsing sortDescriptors: [NSSortDescriptor]? = nil) -> [Self]{
        var array = [Self]()
        handleErrorWithPrintStatement {
            let request = typedFetchRequest()
            request.sortDescriptors = sortDescriptors
            array = try CoreData.context.fetch(request)
        }
        return array
    }
    
    static func hasStoredObjectWith(uniqueID: String) -> Bool{
        let request = typedFetchRequest()
        request.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        var count = 0
        handleErrorWithPrintStatement {
            count = try CoreData.context.count(for: request)
        }
        return count > 0
    }
    
    static func getObjectWith(uniqueID: String) -> Self?{
        let fetchRequest = typedFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        var objectToReturn: Self?
        handleErrorWithPrintStatement {
            objectToReturn = try CoreData.context.fetch(fetchRequest).first
        }
        return objectToReturn
    }
    
    
}







class CoreData{
    
    
    
    static private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CamChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    
    static func saveChanges() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

