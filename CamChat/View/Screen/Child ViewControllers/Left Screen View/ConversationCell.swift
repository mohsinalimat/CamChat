//
//  ChatCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class ConversationCell: UITableViewCell{
    
    private let padding: CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(customImageView)
        addSubview(labelStackView)
        self.selectionStyle = .none
        backgroundColor = .clear
        
        customImageView.pin(anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: customImageView.heightAnchor], constants: [.top: padding, .left: padding, .bottom: padding])

        labelStackView.pin(anchors: [.left: customImageView.rightAnchor, .right: rightAnchor, .centerY: centerYAnchor], constants: [.left: padding, .right: padding])
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {[weak self] (timer) in
            guard let self = self else {timer.invalidate(); return}
            if let user = self.user{
                let bottomText = ConversationCellVM().getSubtitleInfoFor(user: user).bottomText
                self.bottomLabel.text = bottomText
            }
        }
    }
    
    private var user: User?
    
    
    
    func setWith(user: User){
        self.user = user
        customImageView.image = user.profilePicture
        
        let subtitleInfo = ConversationCellVM().getSubtitleInfoFor(user: user)
        
        topLabel.text = subtitleInfo.topText
        bottomLabel.text = subtitleInfo.bottomText
        self.bottomIconView.image = subtitleInfo.icon
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layer.cornerRadius = customImageView.frame.width / 2
    }
    
    
    private lazy var customImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.clipsToBounds = true
        return x
    }()
    
    private lazy var labelStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topLabel, bottomRowHolder])
        x.axis = .vertical
        x.spacing = 3
        return x
    }()
    
    private lazy var bottomRowHolder: UIView = {
        let x = UIView()
        bottomIconView.pin(addTo: x, anchors: [.left: x.leftAnchor, .centerY: x.centerYAnchor])
        bottomLabel.pin(addTo: x, anchors: [.left: bottomIconView.rightAnchor, .centerY: bottomIconView.centerYAnchor], constants: [.left: 6])
        x.pin(anchors: [.height: bottomIconView.heightAnchor, .right: bottomLabel.rightAnchor])
        return x
    }()
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        
        return x
    }()
    
    private lazy var bottomIconView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFit)
        x.tintColor = BLUECOLOR
        x.pin(constants: [.height: 15, .width: 15])
        return x
    }()

    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.textColor = UIColor.lightGray
        x.font = UIFont.systemFont(ofSize: 13)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}




extension ConversationCell: CoreDataListViewUpdateAwareCell{
    
    func updateCellInfo() {
        if let user = self.user{
            self.setWith(user: user)
        }
        
    }
    
}
