//
//  ChatMessagesCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


private struct CellConstants{
    
    static let topAndBottomSpacing: CGFloat = 5
    static let topLabelBottomSpacing: CGFloat = 2
    static let leftInset: CGFloat = 15
    static let maxSlidingTransform: CGFloat = 58
    static let rightLineSpacing: CGFloat = 10
    static let rightLabelInset: CGFloat = 15
    static let stackViewSpacing: CGFloat = 5
    static let lineWidth: CGFloat = 5.5
    
    static let messageLabelFont = SCFonts.getFont(type: .medium, size: 16)
    static let titleLabelFont = SCFonts.getFont(type: .demiBold, size: 12.5)
    static var labelWidth: CGFloat {
        return UIScreen.main.bounds.width - leftInset - lineWidth - rightLineSpacing - rightLabelInset
    }
    
    static var desiredTopAndBottomInsets: CGFloat{
        return leftInset - topAndBottomSpacing
    }
    
    static var timeStampRightInsetFromStackView: CGFloat{
        return leftInset + lineWidth + rightLineSpacing
    }
    
    static func estimatedHeightFor(messageBlock: ChatMessageBlock) -> CGFloat{
        let titleHeight = messageBlock.title.height(withFixedWidthOf: 1000, font: titleLabelFont)
        let stackViewHeight = messageBlock.messages.reduce(0, {$0 + $1.text.height(withFixedWidthOf: labelWidth, font: messageLabelFont)}) + (CGFloat(messageBlock.messages.count - 1) * stackViewSpacing)
        
        return topAndBottomSpacing.doubled + titleHeight + topLabelBottomSpacing + stackViewHeight
    }
}




class ChatMessagesTableViewCell: UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        selectionStyle = .none
        self.panGesture = DirectionAwarePanGesture(target: self, action: #selector(respondTo(gesture:)))
        
        
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        backgroundView = nil
        ChatMessagesTableViewCell.instances.insert(WeakWrapper(self))
        
       
    }
    
 
    
    private static var instances = Set<WeakWrapper<ChatMessagesTableViewCell>>()
    private static var currentAnimator: UIViewPropertyAnimator?
    private static var previousMaxTranslation: CGFloat?
    
    private var panGesture: UIPanGestureRecognizer!
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    

    
    
    @objc private func respondTo(gesture: DirectionAwarePanGesture){
       
        if gesture.swipingDirection != .towardRight{return}
        
        var translation = gesture.translation(in: self).x

        let action = {
            for wrapper in ChatMessagesTableViewCell.instances{
                if let cell = wrapper.value{
                    cell.fingerTranslated(by: translation)
                }
            }
        }
        if gesture.state == .ended{
            ChatMessagesTableViewCell.previousMaxTranslation = getActualViewTranslationFrom(gestureTranslation: translation)
            translation = 0
            
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: action)
            ChatMessagesTableViewCell.currentAnimator = animator
            animator.addCompletion { (position) in
                if position == .end {
                    ChatMessagesTableViewCell.previousMaxTranslation = nil
                    ChatMessagesTableViewCell.currentAnimator = nil
                }
            }
            animator.startAnimation()
            
            
        } else { action() }
        
    }
    
    private func getActualViewTranslationFrom(gestureTranslation: CGFloat) -> CGFloat{
        return min(max(gestureTranslation, 0), CellConstants.maxSlidingTransform)
    }
    
    private func fingerTranslated(by val: CGFloat){
        let translation = getActualViewTranslationFrom(gestureTranslation: val)
        for subview in subviews{
            subview.transform = CGAffineTransform(translationX: translation, y: 0)
        }
    }
    
    
    
    static func estimatedHeightFor(messageBlock: ChatMessageBlock) -> CGFloat{
        return CellConstants.estimatedHeightFor(messageBlock: messageBlock)
    }
    
    static var desiredTopAndBottomInsets: CGFloat{
        return CellConstants.desiredTopAndBottomInsets
    }
    
    
    private func setUpViews(){
        addSubview(titleLabel)
        addSubview(line)
        addSubview(stackView)
        
        titleLabel.pin(anchors: [.left: leftAnchor, .top: topAnchor, .right: rightAnchor], constants: [.left: CellConstants.leftInset - 1, .top: CellConstants.topAndBottomSpacing])
        stackView.pin(anchors: [.left: line.rightAnchor, .top: titleLabel.bottomAnchor, .right: rightAnchor], constants: [.left: CellConstants.rightLineSpacing, .top: CellConstants.topLabelBottomSpacing, .right: CellConstants.rightLabelInset])
        line.pin(anchors: [.left: leftAnchor, .top: stackView.topAnchor, .bottom: stackView.bottomAnchor], constants: [.left: CellConstants.leftInset, .top: CellConstants.topLabelBottomSpacing, .width: CellConstants.lineWidth])
        
        let heightConstraint = heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: CellConstants.topAndBottomSpacing.doubled + CellConstants.topLabelBottomSpacing + titleLabel.intrinsicContentSize.height)
        
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        self.layoutIfNeeded()
        
        
    }
    

    

    
    
    private var currentBlock: ChatMessageBlock?
    
    
    
    func setWithBlock(block: ChatMessageBlock){
        self.currentBlock = block
        stackView.setWith(messageBlock: block)
        titleLabel.text = block.title
        let color = block.senderIsCurrentUser ? BLUECOLOR : REDCOLOR
        titleLabel.textColor = color
        line.backgroundColor = color
        self.layoutIfNeeded()
        
        if let animator = ChatMessagesTableViewCell.currentAnimator,
            let translation = ChatMessagesTableViewCell.previousMaxTranslation {
            animator.pauseAnimation()

            let percentageComplete = animator.fractionComplete
            self.fingerTranslated(by: translation * (1 - percentageComplete))

            animator.addAnimations { self.fingerTranslated(by: 0) }
            animator.startAnimation()
        }
    }
    

    
    
    private lazy var titleLabel: UILabel = {
        let x = UILabel(text: "PATRICK JAMES HANNA", font: CellConstants.titleLabelFont)
        
        return x
    }()
    
    private lazy var line: UIView = {
        let x = UIView()
        x.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        x.setCornerRadius(to: 4)
        return x
    }()
    
    private lazy var stackView: ChatMessagesStackView = {
        let x = ChatMessagesStackView()
        return x
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}



private class ChatMessagesStackView: UIStackView{
    
    
    init(){
        super.init(frame: CGRect.zero)
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = CellConstants.stackViewSpacing
        
        
    }
    
    private var observers = Set<HKManagedObjectObserver>()

    func setWith(messageBlock: ChatMessageBlock){
        removeAllArangedSubviews()
        removeAllSubviews()
        observers.removeAll()
        for message in messageBlock.messages{
            
            let messageLabel = getNewLabel(text: message.text)
            addArrangedSubview(messageLabel)

            setDimmingIfNeededOn(label: messageLabel, message: message)
            
            let timeLabel = getNewTimeStampLabel(date: message.dateSent)
            
            timeLabel.pin(addTo: self, anchors: [.right: self.leftAnchor, .centerY: messageLabel.centerYAnchor], constants: [.right: CellConstants.timeStampRightInsetFromStackView])
            
            
            observers.insert(message.observe(usingObjectChangeHandler: {[weak self] (change) in
                guard let self = self else {return}
                if change == .update{self.setDimmingIfNeededOn(label: messageLabel, message: message)}
            })!)
        }
       
    }
    
    private func setDimmingIfNeededOn(label: UILabel, message: Message){
        if message.isOnServer{label.alpha = 1} else { label.alpha = 0.3 }
    }
    
    private func getNewLabel(text: String) -> UILabel{
        let x = UILabel(text: text, font: CellConstants.messageLabelFont)
        x.numberOfLines = 0
        return x
    }
    
    private func getNewTimeStampLabel(date: Date) -> UILabel{
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let dateText = formatter.string(from: date)
        let label = UILabel(text: dateText, font: SCFonts.getFont(type: .demiBold, size: 11))
        label.textColor = .lightGray
        return label
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
