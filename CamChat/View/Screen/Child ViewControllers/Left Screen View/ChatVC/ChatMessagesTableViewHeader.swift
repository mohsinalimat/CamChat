//
//  ChatMessagesTableViewHeader.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatMessagesSectionHeaderView: UITableViewHeaderFooterView{
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label.pin(addTo: self, anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor])
        backgroundView = UIView()
    }
    
    func setWith(section: ChatMessageSection){
        label.text = section.dateText.uppercased()
    }
    
  
    
    
    private lazy var label: UILabel = {
        let x = UILabel(font: SCFonts.getFont(type: .demiBold, size: 11))
        x.textColor = .lightGray
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
