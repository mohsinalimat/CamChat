//
//  ChatMessagesCollectionView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatMessagesTableView: UITableView , UITableViewDelegate, UIGestureRecognizerDelegate{
    
    private var viewModel: ChatTableViewVM?
    private let user: User
    private let headerID = "HeaderID"
    private weak var vcOwner: UIViewController?
    
    init(user: User, vcOwner: UIViewController) {
        self.user = user
        self.vcOwner = vcOwner
        super.init(frame: CGRect.zero, style: .grouped)
        
        
        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = 20
        sectionFooterHeight = 0.000001
        alwaysBounceVertical = true
        backgroundColor = .white
        keyboardDismissMode = .interactive
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        setCornerRadius(to: 10)
        
        canCancelContentTouches = false

        contentInsetAdjustmentBehavior = .never
        separatorStyle = .none
        
        contentInset.top = -30
        register(ChatMessagesSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: headerID)
        self.viewModel = ChatTableViewVM(tableView: self, user: user, delegate: self)
        delegate = self
        panGestureRecognizer.delegate = self
        // because when you're dealing with a grouped table view, for some reason, when you start off with no cells, there is no additional inset on the top
        if viewModel!.messageSections.isEmpty{ contentInset.top = 5 }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let vcOwner = vcOwner else {return}
        if vcOwner.isBeingPresented{
            scrollToBottom(animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatMessagesTableViewCell.estimatedHeightFor(messageBlock: viewModel!.messageSections[indexPath.section].messageBlocks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = dequeueReusableHeaderFooterView(withIdentifier: headerID) as! ChatMessagesSectionHeaderView
        
        header.setWith(section: viewModel!.messageSections[section])
        return header
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}


extension ChatMessagesTableView: ChatTableViewVMDelegate{
    func configure(cell: ChatMessagesTableViewCell, for object: ChatMessageBlock, at indexPath: IndexPath) {
        cell.setWithBlock(block: object)
        cell.vcOwner = vcOwner
    }
}
