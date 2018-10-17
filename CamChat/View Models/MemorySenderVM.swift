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
    var messageCell: MemorySenderMessageCell { get }
    // called whenever the objects to be displayed in the table view changes
    func contentDidChange()
}


class MemorySenderVM: NSObject{
    
    private static let messageCellID = "MESSAGE"
    
    
    private let searchSectionTitle = "SEARCH RESULTS"
    private let recentsSectionTitle = "RECENTS"
    private let allFriendsSectionTitle = "ALL FRIENDS"
    
    private var messageCellID: String{ return MemorySenderVM.messageCellID }
    
    private let userCellID = "userCell"
    
    typealias MemorySenderSection = (objects: [User], title: String)
    
    private var users = (recents: [User](), all: [User]())
    
    var hasUsers: Bool {
        return users.all.isEmpty.isFalse && users.recents.isEmpty.isFalse
    }
    
    private(set) var objects: [MemorySenderSection] = [([], MemorySenderVM.messageCellID)]{
        didSet { delegate?.contentDidChange() }
    }
    
    private var fetchRequestResultCompletionCount = 0 {
        didSet {
            if fetchRequestResultCompletionCount >= 2 {
                if hasUsers.isFalse {
                    objects.removeAll()
                    tableView?.reloadData()
                    return
                }
                tableView?.insertSections([1, 2], with: .bottom)
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
                self.objects.insert((users, self.recentsSectionTitle), at: 1)
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
        if hasUsers.isFalse{return}
        objects.removeAll()
        if text.isNil || text?.withTrimmedWhiteSpaces().isEmpty ?? true{
            objects = [([], messageCellID), (users.recents, recentsSectionTitle), (users.all, allFriendsSectionTitle)]
            tableView?.reloadData()
            return
        }
    
        let filteredUsers = users.all.filter {
            return $0.fullName.localizedCaseInsensitiveContains(text!)
        }
        
        self.objects = filteredUsers.isEmpty ? [] : [(filteredUsers, searchSectionTitle)]
        tableView?.reloadData()
    }
    
    
    
    
}





extension MemorySenderVM: UITableViewDataSource{
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = objects.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if objects[section].title == messageCellID{return 1}
        
        let count = objects[section].objects.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if objects[indexPath.section].title == messageCellID{
            return delegate!.messageCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellID, for: indexPath) as! MemorySenderUserCell
        delegate?.configure(cell: cell, using: objects[indexPath.section].objects[indexPath.row], for: indexPath)
        return cell
    }
    
    
    
    
}
