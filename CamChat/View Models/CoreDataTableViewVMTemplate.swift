//
//  CoreDataVMTemplate.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import HelpKit
import CoreData


protocol CoreDataListViewVMDelegate: class {
    associatedtype CellType: UIView
    associatedtype ListViewType: CelledListView
    associatedtype ObjectType: NSManagedObject

    var listView: ListViewType {get}
    var fetchRequest: NSFetchRequest<ObjectType> { get }
    func configureCell(_ cell: CellType, at indexPath: IndexPath, for object:  ObjectType)
    func coreDataUpdatesOcurred(updates: [NSFetchedResultsChangeType])
}


extension CoreDataListViewVMDelegate{
    func coreDataUpdatesOcurred(updates: [NSFetchedResultsChangeType]){}
}

/// Neither UITableView nor UICollectionView updates the cell content when the cells are being moved. Cells that conform to this Protocol will be notified manually when updates are needed.
protocol CoreDataListViewUpdateAwareCell{
    func updateCellInfo()
}

class CoreDataListViewVM<Delegate: CoreDataListViewVMDelegate>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource, UICollectionViewDataSource {
    
    private let cellID = "CellID"
    
    private weak var delegate: Delegate?
    private var listView: Delegate.ListViewType?{
        return delegate?.listView
    }
    
    private var controller: NSFetchedResultsController<Delegate.ObjectType>!
    var objects: [Delegate.ObjectType]{
        return controller.fetchedObjects!
    }
    
    init(delegate: Delegate){
        
        // I'm doing this like this because when I try doing it with generic constraints, Swift acts up.
        if (Delegate.CellType.isSubclass(of: Delegate.ListViewType.CellBaseType.self)).isFalse{
            fatalError("If you are using a UITableView with CoreDataListViewVM, you must use a UITableViewCell as the CellType of your delegate or a subclass thereof. The same is true for UICollectionView and UICollectionViewCell.")
        }
        
        
        self.delegate = delegate
        
        super.init()
        
        if let listView = listView as? UICollectionView{
            listView.dataSource = self
        } else if let listView = listView as? UITableView{
            listView.dataSource = self
        }
        
        listView?.register(Delegate.CellType.self, forCellReuseIdentifier: cellID)
        setUpController()
    }
    
    
    private func setUpController(){
        
        self.controller = NSFetchedResultsController<Delegate.ObjectType>(fetchRequest: delegate!.fetchRequest, managedObjectContext: CoreData.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        handleErrorWithPrintStatement { try controller.performFetch() }
        listView?.reloadData()
        controller.delegate = self
    }
    
    
    
    
    
    
    
    
    
    private var listViewUpdates = [(NSFetchedResultsChangeType, (() -> Void))]()
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listViewUpdates = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        
        let action = {
            let listView = self.listView
            
            switch type{
            case .delete:
                listView?.deleteCell(at: indexPath!)
            case .insert:
                listView?.insertCell(at: newIndexPath!)
            case .move:
                if let cell = listView?.cellForItem(at: indexPath!) as? CoreDataListViewUpdateAwareCell{
                    cell.updateCellInfo()
                }
                listView?.moveCell(from: indexPath!, to: newIndexPath!)
            case .update:
                listView?.reloadCell(at: indexPath!)
                
            }
            
        }
        
        listViewUpdates.append((type, action))
        
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let updates = self.listViewUpdates
        listView?.performBatchUpdates({
            updates.forEach{$0.1()}
        }, completion: {(success) in
            self.delegate?.coreDataUpdatesOcurred(updates: updates.map{$0.0})
        })

        self.listViewUpdates = []
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! Delegate.CellType
        delegate?.configureCell(cell, at: indexPath, for: objects[indexPath.row])
        return cell as! UITableViewCell
    }
    
    
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! Delegate.CellType
        delegate?.configureCell(cell, at: indexPath, for: objects[indexPath.row])
        return cell as! UICollectionViewCell
    }
    
}



