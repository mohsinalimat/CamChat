//
//  ChatCollectionViewVM.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


struct ChatMessageSection{
    
    static func getFrom(messageBlocks: [ChatMessageBlock]) -> [ChatMessageSection]{
        return messageBlocks.splitUp{$0.startOfDaySent == $1.startOfDaySent}
            .map{self.init(messageBlocks: $0)}
    }
    
    private init(messageBlocks: [ChatMessageBlock]){
        precondition(messageBlocks.isEmpty.isFalse)
        self.messageBlocks = messageBlocks
        self.dateText = ChatMessageSection.getStringFor(date: messageBlocks.first!.startOfDaySent)
    }
    
    var dateText: String
    var messageBlocks: [ChatMessageBlock]
    
    
    static private func getStringFor(date: Date) -> String{
        
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: date)
        let daysElapsed = calendar.dateComponents([.day], from: startOfTimeStamp, to: today).day
        
        if calendar.isDateInToday(date){
            return "Today"
        } else if calendar.isDateInYesterday(date){
            return "Yesterday"
        } else if daysElapsed! < 7{
            let mydateFormatter = DateFormatter()
            mydateFormatter.dateFormat = "EEEE"
            return mydateFormatter.string(from: date)
        } else {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "E, MMM d"
            return myDateFormatter.string(from: date)
        }
    }
    
}


struct ChatMessageBlock: Equatable{
    
    
    static func getFrom(messages: [Message]) -> [ChatMessageBlock]{
        
        return messages.splitUp{
            $0.sender == $1.sender && Calendar.current.isDate($0.dateSent, inSameDayAs: $1.dateSent)
            }.map({self.init(messages: $0)})
    }
    
    
    fileprivate var startOfDaySent: Date{
        return Calendar.current.startOfDay(for: messages.last!.dateSent)
    }
    
    var title: String
    let messages: [Message]
    fileprivate let sender: User
    
    var senderIsCurrentUser: Bool{
        return sender.isCurrentUser
    }
    
    
    
    private init(messages: [Message]){
        precondition(messages.isEmpty.isFalse)
        self.sender = messages.first!.sender
        self.messages = messages
        self.title = sender.isCurrentUser ? "ME" : sender.firstName.uppercased()
    }
    
    
}



private enum TableViewChangeType{
    case cellInsert(IndexPath)
    case cellReload(IndexPath)
    case cellRemoval(IndexPath)
    
    case sectionInsert(Int)
    case sectionRemoval(Int)
    case sectionHeaderReload(Int)
}




/** Note: This function does not notice changes in the individual attributes on objects. It only notices if a new message has been added and sends insertion information accordingly. It is the responsibility of each cell to observe the context for changes in it's message objects.
 
 ... And yes, I acknowledge that this function is absolutely terrible ☹️
 
 **/

private func getTableViewChangeInfoFor(oldMessageSections: [ChatMessageSection], newMessageSections: [ChatMessageSection]) -> [TableViewChangeType]{
    
    var changes = [TableViewChangeType]()
    
    for (sectionNum, section) in newMessageSections.enumerated(){
        if oldMessageSections.item(at: sectionNum).isNil {
            changes.append(.sectionInsert(sectionNum))
            continue
        }
        
        if section.dateText != oldMessageSections[sectionNum].dateText{
            changes.append(.sectionHeaderReload(sectionNum))
        }
        
        for (rowNum, block) in section.messageBlocks.enumerated(){
            
            let indexPath = IndexPath(row: rowNum, section: sectionNum)
            
            if oldMessageSections[sectionNum].messageBlocks.item(at: rowNum).isNil{
                changes.append(.cellInsert(indexPath))
                continue
            }
            if block != oldMessageSections[sectionNum].messageBlocks[rowNum]{
                changes.append(.cellReload(indexPath))
            }
        }
        
        if section.messageBlocks.count < oldMessageSections[sectionNum].messageBlocks.count{
            let removalInfo = (section.messageBlocks.endIndex...oldMessageSections[sectionNum].messageBlocks.lastItemIndex!)
                .map{IndexPath(row: $0, section: sectionNum)}
                .map{TableViewChangeType.cellRemoval($0)}
            changes.append(contentsOf: removalInfo)
        }
    }
    
    if newMessageSections.count < oldMessageSections.count{
        let removalInfo = (newMessageSections.endIndex...oldMessageSections.lastItemIndex!)
            .map{TableViewChangeType.sectionRemoval($0)}
        changes.append(contentsOf: removalInfo)
    }
    return changes
}








class ChatTableViewVM: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource{
    
    
    private weak var tableView: UITableView!
    private var controller: NSFetchedResultsController<Message>!
    
    
    private let cellID = "CellID"
    private let headerID = "HeaderID"
    
    
    init(tableView: UITableView, user: User){
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.register(ChatMessagesTableViewCell.self, forCellReuseIdentifier: cellID)
        let fetch = Message.typedFetchRequest()
        
        fetch.predicate = NSPredicate(format: "(\(#keyPath(Message.sender.uniqueID)) == %@) OR \(#keyPath(Message.receiver.uniqueID)) == %@", user.uniqueID, user.uniqueID)
        fetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateSent), ascending: true)]
        self.controller = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreData.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        handleErrorWithPrintStatement(action: {try self.controller.performFetch()})
        setMessageSections()
        tableView.reloadData()
        controller.delegate = self
    }
    
    
    
    private var messages: [Message]{
        return controller.fetchedObjects!
    }
    
    private(set) var messageSections = [ChatMessageSection]()
    
    
    private func setMessageSections(){
        
        let blocks = ChatMessageBlock.getFrom(messages: messages)
        self.messageSections = ChatMessageSection.getFrom(messageBlocks: blocks)
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changes.removeAll()
    }
    
    private var changes = [NSFetchedResultsChangeType]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        changes.append(type)
    }
    
    private var timer: Timer?
    
    private var snapshot: UIView?
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        defer{ self.changes.removeAll() }
        
        if changes.contains(where: {$0 == .insert || $0 == .delete || $0 == .move}).isFalse{return}
        
        
        if snapshot.isNil{
            let snapshot = tableView.superview!.snapshotView(afterScreenUpdates: false)!
            tableView.superview!.addSubview(snapshot)
            tableView.isUserInteractionEnabled = false
            self.snapshot = snapshot
        }
        
        
        
        tableView.beginUpdates()
        let oldMessageBlocks = messageSections
        setMessageSections()
        let insertions = getTableViewChangeInfoFor(oldMessageSections: oldMessageBlocks, newMessageSections: messageSections)
        
        
        for insertion in insertions{
            switch insertion{
            case let .cellInsert(indexPath):
                tableView.insertRows(at: [indexPath], with: .none)
            case let .cellReload(indexPath):
                tableView.reloadRows(at: [indexPath], with: .none)
            case let .cellRemoval(indexPath):
                tableView.deleteRows(at: [indexPath], with: .none)
            case let .sectionInsert(index):
                tableView.insertSections([index], with: .none)
            case let .sectionRemoval(index):
                tableView.deleteSections([index], with: .none)
            case let .sectionHeaderReload(index):
                if let header = tableView.headerView(forSection: index) as? ChatMessagesSectionHeaderView{
                    header.setWith(section: messageSections[index])
                }
            }
        }
        tableView.endUpdates()
        
        
        timer?.invalidate()
        
        timer = Timer(timeInterval: 0.3, repeats: false, block: { (timer) in
            
            self.snapshot?.removeFromSuperview()
            self.snapshot = nil
            self.tableView.isUserInteractionEnabled = true
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToBottom()
        })
        
        RunLoop.current.add(timer!, forMode: .common)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatMessagesTableViewCell
        cell.setWithBlock(block: messageSections[indexPath.section].messageBlocks[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSections[section].messageBlocks.count
    }
    
    
    
    
}






