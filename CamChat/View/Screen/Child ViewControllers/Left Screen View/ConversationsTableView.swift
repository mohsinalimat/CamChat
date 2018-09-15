//
//  ChatTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData


class ConversationsTableVC: SCTableView{
    
   
  
    private var viewModel: CoreDataListViewVM<ConversationsTableVC>!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    
    }
    
    override func registerCells() {
        viewModel = CoreDataListViewVM(delegate: self, context: CoreData.mainContext)
    }
    

    override var topLabelText: String{
        return "Chats"
    }
    
    override var topLabelTextColor: UIColor{
        return BLUECOLOR
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = ChatViewController(presenter: self, tappedCellProvider: self, user: viewModel.objects[indexPath.row])

        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
}

extension ConversationsTableVC: ChatViewControllerTappedCellProvider{
    func cellFor(user: User) -> UITableViewCell? {
        if let index = viewModel.objects.firstIndex(of: user), let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)){
            return cell
        } else {return nil}
    }
    
    
}

extension ConversationsTableVC: CoreDataListViewVMDelegate{
   
    
    var fetchRequest: NSFetchRequest<User>{
        let x = User.typedFetchRequest()
        x.predicate = NSPredicate(format: "\(#keyPath(User.uniqueID)) != %@ AND \(#keyPath(User.mostRecentMessage)) != nil", DataCoordinator.currentUser!.uniqueID)
        x.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.mostRecentMessage.dateSent), ascending: false)]
        return x
    }
    
    func configureCell(_ cell: ConversationCell, at indexPath: IndexPath, for object: User) {
        cell.setWith(user: object)
    }
    
    var listView: UITableView{
        return tableView
    }
    
}





extension ConversationsTableVC: ChatControllerTransitionAnimationParticipator{
    
    
    
    var topBarView: UIView {
        return (parent! as! Screen).topBar_typed
    }
    
    
    
    var viewToDim: UIView{
        return backgroundView
    }
}
