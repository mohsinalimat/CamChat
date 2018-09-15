//
//  ChatMessagesCollectionView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import CoreData



class ChatMessagesTableView: UITableView {
    
    private var viewModel: ChatTableViewVM?
    private let user: User
    init(user: User) {
        self.user = user

        super.init(frame: CGRect.zero, style: .plain)
        
        estimatedRowHeight = 100
        rowHeight = UITableView.automaticDimension
        alwaysBounceVertical = true
        backgroundColor = .white
        keyboardDismissMode = .interactive
        setCornerRadius(to: 10)
        
        
        
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contentInsetAdjustmentBehavior = .never
        separatorStyle = .none
        contentInset.top = ChatMessagesTableViewCell.leftInset
        self.viewModel = ChatTableViewVM(tableView: self, user: user)
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}





