//
//  ChatMessagesCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatMessagesTableViewCell: UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        selectionStyle = .none
        
    }
    
    
    
    private func setUpViews(){
        addSubview(titleLabel)
        addSubview(line)
        addSubview(stackView)
        titleLabel.pin(anchors: [.left: contentView.leftAnchor, .top: contentView.topAnchor], constants: [.left: ChatMessagesTableViewCell.leftInset - 1])
        stackView.pin(anchors: [.left: contentView.leftAnchor, .top: titleLabel.bottomAnchor], constants: [.left: ChatMessagesTableViewCell.leftInset + lineWidth + rightLineSpacing, .width: labelWidth, .top: topLabelBottomSpacing])
        line.pin(anchors: [.left: contentView.leftAnchor, .top: stackView.topAnchor, .bottom: stackView.bottomAnchor], constants: [.left: ChatMessagesTableViewCell.leftInset, .top: topLabelBottomSpacing, .width: lineWidth])
        
        contentView.heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: titleLabel.intrinsicContentSize.height + topLabelBottomSpacing).isActive = true
        
        
        clipsToBounds = true
        
    }
    
   
    
    
    
    private let topLabelBottomSpacing: CGFloat = 2
    
    static let leftInset: CGFloat = 15
    private let rightLineSpacing: CGFloat = 10
    private let rightLabelInset: CGFloat = 15
    private let stackViewSpacing: CGFloat = 5
    private let lineWidth: CGFloat = 5.5
    
    private var labelWidth: CGFloat {
        return UIScreen.main.bounds.width - ChatMessagesTableViewCell.leftInset - lineWidth - rightLineSpacing - rightLabelInset
    }
    
    
    private var currentBlock: ChatMessageBlock?
    
    
    
    func setWithBlock(block: ChatMessageBlock){
        self.currentBlock = block
        stackView.removeAllArangedSubviews()
        stackView.removeAllSubviews()
        
        block.messages.forEach{stackView.addArrangedSubview(getNewLabel(text: $0.text))}
        titleLabel.text = block.title
        let color = block.senderIsCurrentUser ? BLUECOLOR : REDCOLOR
        titleLabel.textColor = color
        line.backgroundColor = color
        
    }
    

    
    
    private lazy var titleLabel: UILabel = {
        let x = UILabel(text: "PATRICK JAMES HANNA", font: SCFonts.getFont(type: .demiBold, size: 12.5))
        
        return x
    }()
    
    private lazy var line: UIView = {
        let x = UIView()
        x.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        x.setCornerRadius(to: 4)
        return x
    }()
    
    private lazy var stackView: UIStackView = {
        let x = UIStackView()
        x.addArrangedSubview(getNewLabel(text: "yourmother"))
        x.spacing = stackViewSpacing
        x.axis = .vertical
        return x
    }()
    
    
    private func getNewLabel(text: String) -> UILabel{
        let x = UILabel(text: text, font: SCFonts.getFont(type: .medium, size: 16))
        x.numberOfLines = 0
        x.preferredMaxLayoutWidth = labelWidth
        return x
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}
