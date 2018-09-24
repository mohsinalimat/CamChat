//
//  ChatCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/2/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import NVActivityIndicatorView

class ConversationCell: UITableViewCell{
    
    private let padding: CGFloat = 10
    
    private var viewModel = ConversationCellVM()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(customImageView)
        addSubview(labelStackView)
        self.selectionStyle = .none
        backgroundColor = .clear
        
        customImageView.pin(anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: customImageView.heightAnchor], constants: [.top: padding, .left: padding, .bottom: padding])

        labelStackView.pin(anchors: [.left: customImageView.rightAnchor, .right: rightAnchor, .centerY: centerYAnchor], constants: [.left: padding, .right: padding])
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {[weak self] (timer) in
            guard let self = self else {timer.invalidate(); return}
            self.resetSubtitleInfo()
        }
    }
    
    private var user: User?
    private var observer: HKManagedObjectObserver?
    
    
    
    func setWith(user: User){
        self.user = user
        viewModel.setWith(user: user)
       
        self.observer = user.mostRecentMessage!.observe(usingObjectChangeHandler: {[weak self](change) in
            guard let self = self else {return}
            if change == .update{self.resetSubtitleInfo()}
        })
        
        customImageView.image = user.profilePicture
        resetSubtitleInfo()
        
    }
    
    
    private func resetSubtitleInfo(){
        guard user.isNotNil else {return}
        let subtitleInfo = self.viewModel.getSubtitleInfo()!
        
        topLabel.text = subtitleInfo.topText
        
        
        sendingIndicator.stopAnimating()
        bottomIconView.tintColor = BLUECOLOR
        bottomIconView.image = nil
        bottomLabel.textColor = .lightGray
        
        
        switch subtitleInfo.bottomInfo{
        case .default(image: let image, text: let text):
            bottomIconView.image = image
            bottomLabel.text = text
        case .sending:
            sendingIndicator.startAnimating()
            bottomLabel.text = "Sending..."
        case .failed:
            bottomIconView.image = AssetImages.errorIcon
            bottomIconView.tintColor = .red
            bottomLabel.textColor = .red
            bottomLabel.text = "The message could not be sent."
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layer.cornerRadius = customImageView.frame.width / 2
    }
    
    
    private lazy var customImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.clipsToBounds = true
        x.backgroundColor = .clear
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
        sendingIndicator.pin(addTo: x, anchors: [.centerX: bottomIconView.centerXAnchor, .centerY: bottomIconView.centerYAnchor], constants: [.width: sendingIndicatorSize.width, .height: sendingIndicatorSize.height])
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
    
    private let sendingIndicatorSize = CGSize(width: 12, height: 12)
    
    private lazy var sendingIndicator: NVActivityIndicatorView = {
        let x = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: sendingIndicatorSize.width, height: sendingIndicatorSize.height), type: .circleStrokeSpin, color: BLUECOLOR, padding: nil)
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
