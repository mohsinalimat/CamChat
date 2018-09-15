//
//  SearchControllerV.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import Firebase

protocol SearchControllerVMDelegate: class {
    associatedtype CellType: UITableViewCell
    func configureCell(_ cell: CellType, for indexPath: IndexPath, with object: TempUser)
}

class SearchControllerVM<DelegateType: SearchControllerVMDelegate>:NSObject, UITableViewDataSource{
    
    private unowned let delegate: DelegateType
    private unowned let tableView: UITableView
    
    var objects = [TempUser]()
    
    private let cellID = "cellID"
    
    init(tableView: UITableView, delegate: DelegateType){
        self.delegate = delegate
        self.tableView  = tableView
        super.init()
        tableView.dataSource = self
        tableView.register(DelegateType.CellType.self, forCellReuseIdentifier: cellID)
        getAllUsers()
    }
    
    
    
    
    private func getAllUsers(){
        Firebase.getAllUsers { [weak self] (callback) in
            guard let self = self else {return}
            switch callback{
            case .success(let users):
                
                self.tableView.performBatchUpdates({
                    self.objects = users
                    let indexPaths = users.indices.map({IndexPath(row: $0, section: 0)})
                    self.tableView.insertRows(at: indexPaths, with: .fade)
                }, completion: nil)
            
            case .failure(let error): print(error)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Strangers"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DelegateType.CellType
        delegate.configureCell(cell, for: indexPath, with: objects[indexPath.row])
        return cell
    }
}
