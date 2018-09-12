//
//  ChatMessagesCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class ChatMessagesCollectionViewCell: UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    private func setUpViews(){
        addSubview(titleLabel)
        addSubview(line)
        addSubview(stackView)
        titleLabel.pin(anchors: [.left: contentView.leftAnchor, .top: contentView.topAnchor], constants: [.left: ChatMessagesCollectionViewCell.leftInset - 1])
        line.pin(anchors: [.left: contentView.leftAnchor, .top: titleLabel.bottomAnchor, .height: stackView.heightAnchor], constants: [.left: ChatMessagesCollectionViewCell.leftInset, .top: topLabelBottomSpacing, .width: lineWidth])
        stackView.pin(anchors: [.left: line.rightAnchor, .top: line.topAnchor], constants: [.left: rightLineSpacing, .width: labelWidth])
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.bottomAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
        self.contentView.pinAllSides(pinTo: self)
        
    }
    

    
    
    
    
    private let topLabelBottomSpacing: CGFloat = 2
    
    static let leftInset: CGFloat = 15
    private let rightLineSpacing: CGFloat = 10
    private let rightLabelInset: CGFloat = 15
    private let stackViewSpacing: CGFloat = 5
    private let lineWidth: CGFloat = 5.5
    
    private var labelWidth: CGFloat {
        return UIScreen.main.bounds.width - ChatMessagesCollectionViewCell.leftInset - lineWidth - rightLineSpacing - rightLabelInset
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
    
    func setWithBlock(newBlock: ChatMessageBlock, insertingNewMessage message: Message, atIndex index: Int){
        self.currentBlock = newBlock
        UIView.animate(withDuration: 0.2) {
            let label = self.getNewLabel(text: message.text)
            self.stackView.insertArrangedSubview(label, at: index)
        }
    }
    
    
    private lazy var titleLabel: UILabel = {
        let x = UILabel(font: SCFonts.getFont(type: .demiBold, size: 12.5))
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
        x.alignment = .fill
        x.distribution = .fill
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
