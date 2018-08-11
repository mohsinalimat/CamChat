//
//  ChatCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



class ChatCell: UITableViewCell{
    
    private let padding: CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(customImageView)
        addSubview(labelStackView)
        self.selectionStyle = .none
        backgroundColor = .clear
        
        customImageView.pin(anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: customImageView.heightAnchor], constants: [.top: padding, .left: padding, .bottom: padding])

        labelStackView.pin(anchors: [.left: customImageView.rightAnchor, .right: rightAnchor, .centerY: centerYAnchor], constants: [.left: padding, .right: padding])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layer.cornerRadius = customImageView.frame.width / 2
    }
    
    
    private lazy var customImageView: UIImageView = {
        let x = UIImageView(image: AssetImages.me)
        x.contentMode = .scaleAspectFill
        x.clipsToBounds = true
        return x
    }()
    
    private lazy var labelStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        x.axis = .vertical
        return x
    }()
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        x.text = "Patrick"
        return x
    }()

    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.textColor = UIColor.lightGray
        x.font = UIFont.systemFont(ofSize: 13)
        x.text = "Received ∙ 2d"
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
