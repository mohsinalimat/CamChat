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


enum SearchTableViewSection{
    case friends([TempUser])
    case strangers([TempUser])
    
    var sectionTitle: String{
        switch self {
        case .friends: return "Friends"
        case .strangers: return "Add a Friend"
        }
    }
    var users: [TempUser]{
        
        switch self {
        case let .friends(objects): return objects
        case let .strangers(objects): return objects
        }
    }
    var isFriends: Bool{
        switch self {
        case .friends: return true
        case .strangers: return false
        }
    }
}


class SearchControllerVM<DelegateType: SearchControllerVMDelegate>:NSObject, UITableViewDataSource {
    
    private let cellID = "cellID"
    private unowned let delegate: DelegateType
    private unowned let tableView: UITableView
    
    
    private var allUsers: (local: [TempUser], remote: [TempUser]) = ([], [])
    private(set) var currentSections = [SearchTableViewSection]()
    private var currentSearchText: String?
    
    
    private var searchTextIsValid: Bool{
        if let text = currentSearchText{
            return text.withTrimmedWhiteSpaces().isEmpty.isFalse
        } else { return false }
    }
    
    func changeSearchTextTo(_ newText: String?){
        currentSearchText = newText?.withTrimmedWhiteSpaces()
        refreshSearchResults()
    }

    init(tableView: UITableView, delegate: DelegateType){
        
        self.delegate = delegate
        self.tableView  = tableView
        super.init()
        tableView.dataSource = self
        tableView.register(DelegateType.CellType.self, forCellReuseIdentifier: cellID)
        
        CoreData.backgroundContext.perform {
            
            self.allUsers.local = SearchControllerVM.getAllLocalUsers()
            DispatchQueue.main.async {
                if self.allUsers.local.isEmpty.isFalse{
                    self.currentSections = [.friends(self.allUsers.local)]
                    tableView.insertSections([0], with: .fade)
                }
                self.setRemoteUsers()
            }
        }
    }
    
    private static func getAllLocalUsers() -> [TempUser]{
        return User.helper(.background).fetchObjects { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(User.uniqueID)) != %@ AND \(#keyPath(User.mostRecentMessage)) != nil", DataCoordinator.currentUserUniqueID!)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.mostRecentMessage.dateSent), ascending: false)]
            }.map{$0.tempUser}
    }
    
    
    
    private func setRemoteUsers(){
        Firebase.getAllUsers { [weak self] (callback) in
            guard let self = self else {return}
            switch callback{
            case .success(let users):
                let filteredUsers = users.filter({self.allUsers.local.contains($0).isFalse})
                self.allUsers.remote = filteredUsers
               self.refreshSearchResults()
            case .failure(let error): print(error)
            }
        }
    }
    
    
    private func refreshSearchResults(){
        defer { tableView.reloadData() }
        guard searchTextIsValid else {
            let friends = [SearchTableViewSection.friends(allUsers.local.firstItems(10))]
            if friends[0].users.isEmpty{self.currentSections = []}
            else { self.currentSections = friends }
            return
        }
        let filterer: (TempUser) -> Bool = {
            $0.fullName.localizedCaseInsensitiveContains(self.currentSearchText!) ||
            $0.username.localizedCaseInsensitiveContains(self.currentSearchText!)
        }
        let friendsResults = SearchTableViewSection.friends(allUsers.local.filter(filterer))
        let strangersResults = SearchTableViewSection.strangers(allUsers.remote.filter(filterer))
        
        var sectionsToReturn = [SearchTableViewSection]()
        
        for result in [friendsResults, strangersResults]{
            if result.users.isEmpty.isFalse{sectionsToReturn.append(result)}
        }
        currentSections = sectionsToReturn
    }
    
    
  
    

    

    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentSections[section].sectionTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSections[section].users.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DelegateType.CellType
        delegate.configureCell(cell, for: indexPath, with: currentSections[indexPath.section].users[indexPath.row])
        return cell
    }
}
