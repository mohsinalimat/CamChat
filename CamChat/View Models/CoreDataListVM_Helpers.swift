//
//  CoreDataListVM_Helpers.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//


import HelpKit





protocol CelledListView: class {
    

    associatedtype CellBaseType: UIView
    
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func insertCell(at index: IndexPath)
    func deleteCell(at index: IndexPath)
    func moveCell(from index: IndexPath, to newIndex: IndexPath)
    func reloadCell(at index: IndexPath)
    func reloadData()
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
    func cellForItem(at index: IndexPath) -> CellBaseType?
    
}

extension UITableView: CelledListView{
    
    typealias CellBaseType = UITableViewCell
    
    func cellForItem(at index: IndexPath) -> UITableViewCell? {
        return cellForRow(at: index)
    }
    
    func insertCell(at index: IndexPath) {
        insertRows(at: [index], with: .fade)
    }
    
    func deleteCell(at index: IndexPath) {
        deleteRows(at: [index], with: .fade)
    }
    
    func moveCell(from index: IndexPath, to newIndex: IndexPath) {
        moveRow(at: index, to: newIndex)
    }
    
    func reloadCell(at index: IndexPath) {
        reloadRows(at: [index], with: .fade)
    }
    
    
}

extension UICollectionView: CelledListView{
    
    
    
    
    typealias CellBaseType = UICollectionViewCell
    
    
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func insertCell(at index: IndexPath) {
        insertItems(at: [index])
    }
    func deleteCell(at index: IndexPath) {
        deleteItems(at: [index])
    }
    
    func moveCell(from index: IndexPath, to newIndex: IndexPath) {
        moveItem(at: index, to: newIndex)
    }
    
    func reloadCell(at index: IndexPath) {
        reloadItems(at: [index])
    }
    
}



