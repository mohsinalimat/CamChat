//
//  CCMangedObject.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


protocol ManagedObjectProtocol {
    static var entityName: String { get }
    var uniqueID:String {get}
}


class StaticManagedObjectHelper<ObjectType: ManagedObjectProtocol & NSManagedObject>{
    
    
    
    private let context: NSManagedObjectContext

    func fetchObjects(configurations: (NSFetchRequest<ObjectType>) -> Void) -> [ObjectType]{
        let request = ObjectType.typedFetchRequest()
        configurations(request)
        var objects = [ObjectType]()
        
        handleErrorWithPrintStatement {
            objects = try context.fetch(request)
        }
        return objects
    }
    
    init(context: CoreDataContextType){
        self.context = context.context
    }
    
    
    func hasStoredObjectWith(uniqueID: String) -> Bool{
        let request = ObjectType.typedFetchRequest()
        request.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        request.fetchLimit = 1
        var count = 0
        handleErrorWithPrintStatement {
            count = try context.count(for: request)
        }
        return count > 0
    }
    
    func getObjectWith(uniqueID: String) -> ObjectType?{
        if hasStoredObjectWith(uniqueID: uniqueID).isFalse{return nil}
        
        
        let object = fetchObjects { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
            fetchRequest.fetchLimit = 1
            fetchRequest.returnsObjectsAsFaults = false
        }.first!
        
        
        return object
    }
    
    
    
    func deleteAllObjects(){
        handleErrorWithPrintStatement {
            let request = NSBatchDeleteRequest(fetchRequest: ObjectType.fetchRequest())
            try context.execute(request)
        }
    }
    
    func fetchAll(sortedUsing sortDescriptors: [NSSortDescriptor]? = nil) -> [ObjectType]{
        var array = [ObjectType]()
        handleErrorWithPrintStatement {
            let request = ObjectType.typedFetchRequest()
            request.sortDescriptors = sortDescriptors
            array = try context.fetch(request)
        }
        return array
    }
    
}

class ManagedObjectInstanceHelper{
    
    typealias ObjectType = NSManagedObject & ManagedObjectProtocol
    
    private let context: NSManagedObjectContext
    private let object: ObjectType
    
    init(context: CoreDataContextType, managedObject: ObjectType){
        self.context = context.context
        self.object = managedObject
    }
    
    func delete(){
        context.delete(object)
        
    }
    
}




extension ManagedObjectProtocol where Self: NSManagedObject{
    
    
    
    static func ==(lhs: Self, rhs: Self) -> Bool{
        return lhs.uniqueID == rhs.uniqueID
    }
    

    static func typedFetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: entityName)
    }
    
    func helper(_ context: CoreDataContextType) -> ManagedObjectInstanceHelper{
        return ManagedObjectInstanceHelper(context: context, managedObject: self)
    }
    
    static func helper(_ context: CoreDataContextType) -> StaticManagedObjectHelper<Self>{
        return StaticManagedObjectHelper(context: context)
    }
    
    
    var context: NSManagedObjectContext!{
        return managedObjectContext
    }
    
    
}





enum CoreDataContextType{
    case main, background
    
    var context: NSManagedObjectContext{
        switch self{
        case .main: return CoreData.mainContext
        case .background: return CoreData.backgroundContext
        }
    }
}

extension NSManagedObjectContext{
    /// Calls save() if needed, and crashes app if an error is thrown.
    func saveChanges(){
        if hasChanges {
            perform {
                do {
                    try self.save()
                } catch {
                    let nserror = error as NSError
                    print(nserror.userInfo)
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            }
        }
    }
}



class CoreData{
    
    
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CamChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSOverwriteMergePolicy
        return container
    }()
    
    static var mainContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    static var backgroundContext: NSManagedObjectContext{
        return _backgroundContext
    }
    
    private static var _backgroundContext: NSManagedObjectContext = {
        let x = persistentContainer.newBackgroundContext(thatSyncsWith: mainContext)
        x.mergePolicy = NSOverwriteMergePolicy
        return x
    }()
    
    static func performAndSaveChanges(context: CoreDataContextType, action: @escaping () -> Void){
        context.context.perform {
            action()
            saveChangesOn(context: context)
        }
    }
    
    
    static func saveChangesOn(context: CoreDataContextType) {
       context.context.saveChanges()
    }
}

