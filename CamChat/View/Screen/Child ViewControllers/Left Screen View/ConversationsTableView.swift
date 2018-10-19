//
//  ChatTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ConversationsTableVC: SCTableView{
    private weak var screen: Screen?
    init(screen: Screen){
        self.screen = screen
        super.init()
    }
  
    private var viewModel: CoreDataListViewVM<ConversationsTableVC>!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        
        emptyBackgroundView.pin(addTo: tableView, anchors: [.left: tableView.contentLayoutGuide.leftAnchor, .top: tableView.contentLayoutGuide.topAnchor], constants: [.top: 40])
    
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
    
    func respondToNewMessageButtonTapped(){
        let vc = MemorySenderVC(presenter: self, memories: []) { (sender) in
            sender.dismiss()
        }
        self.present(vc)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ConversationCell
        let object = cell.user ?? viewModel.objects[indexPath.row]
        let vc = ChatViewController(presenter: self, tappedCellProvider: self, user: object)

        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private lazy var emptyBackgroundView: CCListViewBackgroundView = {
        
        let x = CCListViewBackgroundView(labelText: "CamChat is for friends! \nFind friends by searching for them.", buttonColor: BLUECOLOR, buttonText: "Search For Friends", buttonAction: { [weak self] in
            guard let self = self else {return}
            self.screen?.searchBarTapped()
        })
        x.alpha = viewModel.objects.isEmpty ? 1 : 0
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}

extension ConversationsTableVC: ChatViewControllerTappedCellProvider{
    func cellFor(user: User) -> UITableViewCell? {
        for cell in tableView.visibleCells as! [ConversationCell]{
            if cell.user === user{return cell}
        }
        return nil
    }
}

extension ConversationsTableVC: CoreDataListViewVMDelegate{
   
    
    var fetchRequest: NSFetchRequest<User>{
        let x = User.typedFetchRequest()
        x.predicate = NSPredicate(format: "\(#keyPath(User.uniqueID)) != %@ AND \(#keyPath(User.mostRecentMessage)) != nil", DataCoordinator.currentUserUniqueID!)
        x.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.mostRecentMessage.dateSent), ascending: false)]
        return x
    }
    
    func configureCell(_ cell: ConversationCell, at indexPath: IndexPath, for object: User) {
        cell.setWith(user: object)
    }
    
    var listView: UITableView{
        return tableView
    }
    
    func contentDidChange() {
        emptyBackgroundView.alpha = viewModel.objects.isEmpty ? 1 : 0
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
