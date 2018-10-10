//
//  MemorySenderVM.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

protocol MemorySenderVMDelegate: class{
    
    func configure(cell: MemorySenderUserCell, using object: User, for indexPath: IndexPath)
    
}


class MemorySenderVM: NSObject{
    
    private let searchSectionTitle = "SEARCH RESULTS"
    private let recentsSectionTitle = "RECENTS"
    private let allFriendsSectionTitle = "ALL FRIENDS"
    
    private let previewCellID = "previewCell"
    private let userCellID = "userCell"
    
    typealias MemorySenderSection = (objects: [User], title: String)
    
    private var users = (recents: [User](), all: [User]())
    
    private(set) var objects: [MemorySenderSection] = []
    
    private var fetchRequestResultCompletionCount = 0{
        didSet {
            if fetchRequestResultCompletionCount >= 2 {
                tableView?.insertSections([0, 1], with: .bottom)
            }
        }
    }
    
    private weak var tableView: MemorySenderTableView?
    private weak var delegate: MemorySenderVMDelegate?
    
    init(tableView: MemorySenderTableView, delegate: MemorySenderVMDelegate){
        self.tableView = tableView
        self.delegate = delegate
        super.init()

        tableView.dataSource = self

        tableView.register(MemorySenderUserCell.self, forCellReuseIdentifier: userCellID)
        beginFetching()
    }
    
    
    
    
    
    private var fetch1: NSAsynchronousFetchRequest<User>?
    private var fetch2: NSAsynchronousFetchRequest<User>?
    
    private func beginFetching() {
        let predicate = NSPredicate(format: "\(#keyPath(User.uniqueID)) != %@ AND \(#keyPath(User.mostRecentMessage)) != nil", DataCoordinator.currentUserUniqueID!)
        
        
        let recentsFetch = User.typedFetchRequest()
        recentsFetch.predicate = predicate
        recentsFetch.returnsObjectsAsFaults = false
        recentsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.mostRecentMessage.dateSent), ascending: false)]
        recentsFetch.fetchLimit = 5
        self.fetch1 = NSAsynchronousFetchRequest<User>(fetchRequest: recentsFetch) { (result) in
            DispatchQueue.main.async {
                let users = result.finalResult ?? []
                self.users.recents = users
                self.objects.insert((users, self.recentsSectionTitle), at: 0)
                self.fetchRequestResultCompletionCount += 1
            }
        }
        self.fetch1?.estimatedResultCount = 10
        
        
        
        let allFetch = User.typedFetchRequest()
        allFetch.predicate = predicate
        allFetch.returnsObjectsAsFaults = false
        allFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.firstName), ascending: true)]
        self.fetch2 = NSAsynchronousFetchRequest<User>(fetchRequest: allFetch) { (result) in
            DispatchQueue.main.async {
                let users = result.finalResult ?? []
                self.users.all = users
                self.objects.append((users, self.allFriendsSectionTitle))
                self.fetchRequestResultCompletionCount += 1
            }
        }
    
        try! CoreData.mainContext.execute(fetch1!)
        try! CoreData.mainContext.execute(fetch2!)
    }
    
    
    
    func searchTextChanged(to text: String?){
        
        objects.removeAll()
        if text.isNil || text?.withTrimmedWhiteSpaces().isEmpty ?? true{
            objects = [(users.recents, recentsSectionTitle), (users.all, allFriendsSectionTitle)]
            tableView?.reloadData()
            return
        }
    
        let filteredUsers = users.all.filter {
            return $0.fullName.localizedCaseInsensitiveContains(text!)
        }
        
        self.objects = [(filteredUsers, searchSectionTitle)]
        tableView?.reloadData()
    }
    
    
    
    
}





extension MemorySenderVM: UITableViewDataSource{
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = objects.count
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = objects[section].objects.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellID, for: indexPath) as! MemorySenderUserCell
        delegate?.configure(cell: cell, using: objects[indexPath.section].objects[indexPath.row], for: indexPath)
        return cell
    }
    
    
    
    
}
