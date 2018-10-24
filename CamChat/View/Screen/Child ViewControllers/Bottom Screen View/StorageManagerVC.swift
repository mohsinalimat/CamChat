//
//  StorageManagerVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class StorageManagerVC: SettingsNavigationVC{

    private lazy var _viewController = _StorageManagerVC(style: .grouped)
    override var rootViewController: UIViewController{return _viewController}
    
}

private func getBytesStringFrom(bytes: Int) -> String{
    if       bytes < 1000 { return "0 kb" }
    else if bytes < 1000000 { return "\(bytes / 1000) kb" }
    else if bytes < 1000000000 { return "\(bytes / 1000000) mb" }
    else { return "\(bytes / 1000000000) gb" }
}

private class _StorageManagerVC: SettingsScreenVC{
    
    private lazy var allMemoriesCell = StorageManagerCell(mainText: "Delete All Memories"){ getBytesStringFrom(bytes: URLManager.getSizeOfMemoryDirectory()) }

    
    private lazy var allMyMemoriesCell = StorageManagerCell(mainText: "Delete All My Memories")
    { getBytesStringFrom(bytes: URLManager.getSizeOfCurrentUserMemoryDirectory()) }

    
    private lazy var allOtherUsersCells = StorageManagerCell(mainText: "Delete Other Users' Memories")
    { getBytesStringFrom(bytes: URLManager.getSizeOfMemoryDirectory() - URLManager.getSizeOfCurrentUserMemoryDirectory()) }
    
    
    private var cells: [StorageManagerCell]{
        return [allMemoriesCell, allMyMemoriesCell, allOtherUsersCells]
    }
    
    override var screenTitle: String{
        return "Storage Settings"
    }


    
    @objc private func respondToDismissButton(){
        self.dismiss()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = cells[indexPath.row]
        let deleteText = "Deleted Memories CANNOT be recovered."
        
        switch selectedCell{
        case allMemoriesCell:
            self.presentAreYouSureAlert(description: "You are about to delete all the memories stored in this app, including those beloging to other users. \(deleteText)", confirmationText: "Delete", confirmationCompletion: { [weak self] in
                self?.deleteMemories(predicate: nil, cell: selectedCell)
            })
        case allMyMemoriesCell:
            self.presentAreYouSureAlert(description: "You are about to delete all the memories stored on your phone that are associated with your account. \(deleteText)", confirmationText: "Delete", confirmationCompletion: { [weak self] in
                self?.deleteMemories(predicate: NSPredicate(format: "\(#keyPath(Memory.authorID)) == %@", DataCoordinator.currentUserUniqueID!), cell: selectedCell)
            })
        case allOtherUsersCells:
            self.presentAreYouSureAlert(description: "You are about to delete all the memories of all other persons who have previously logged into this app. \(deleteText)", confirmationText: "Delete", confirmationCompletion: { [weak self] in
                self?.deleteMemories(predicate: NSPredicate(format: "\(#keyPath(Memory.authorID)) != %@", DataCoordinator.currentUserUniqueID!), cell: selectedCell)
            })
        default: break
        }
    }
    
    private func deleteMemories(predicate: NSPredicate?, cell: StorageManagerCell){
        
        let fetchRequest = Memory.typedFetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        CoreData.backgroundContext.perform {
            handleErrorWithPrintStatement {
                let objects = try CoreData.backgroundContext.fetch(fetchRequest)
                objects.forEach{ $0.info.deleteAllCorrespondingData() }
                objects.forEach{ CoreData.backgroundContext.delete($0) }
                CoreData.backgroundContext.saveChanges()
                DispatchQueue.main.async {
                    self.cells.forEach{$0.refreshMemoryText()}
                }
                
            }
        }
        
    }
    
    
    
    
    
}


private class CellConstants{
    static let topAndBottomInsets: CGFloat = 10
    static let leftAndRightInsets: CGFloat = 10
}



private class StorageManagerCell: UITableViewCell{
    
    private var memoryGetterAction: () -> String
    init(mainText: String, memoryGetterAction: @escaping () -> String){
        self.memoryGetterAction = memoryGetterAction
        super.init(style: .default, reuseIdentifier: "Patrick Hanna is by far, the best programmer in the universe... jus saying 🤷🏽‍♂️")
        
        
        
        memorySizeLabel.pin(addTo: self, anchors: [.right: contentView.rightAnchor, .centerY: centerYAnchor], constants: [.right: 5])
        
        mainLabel.pin(addTo: self, anchors: [.left: leftAnchor, .centerY: centerYAnchor, .right: memorySizeLabel.leftAnchor], constants: [.left: CellConstants.leftAndRightInsets])
        

        mainLabel.text = mainText
        memorySizeLabel.text = memoryGetterAction()
        
        accessoryType = .disclosureIndicator
        
    }
    
    func refreshMemoryText(){
        self.memorySizeLabel.text = memoryGetterAction()
    }
    

    
    private lazy var mainLabel: UILabel = {
        let x = UILabel(font: CCFonts.getFont(type: .medium, size: 16), textColor: .black)
        return x
    }()
    
    private lazy var memorySizeLabel: UILabel = {
        let x = UILabel(text: "32 mb", font: CCFonts.getFont(type: .medium, size: 15), textColor: UIColor.gray(percentage: 0.4))
        x.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return x
    }()
    

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
