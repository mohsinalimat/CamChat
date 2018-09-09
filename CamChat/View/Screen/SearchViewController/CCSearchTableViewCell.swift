//
//  CCSearchTableViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class CCSearchTableViewCell: UITableViewCell{
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layer.masksToBounds = true
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        selectedBackgroundView = backgroundView
        
        backgroundColor = CCSearchConstants.opaqueBackingColor
        bottomLine.pin(addTo: self, anchors: [.left: leftAnchor, .right: rightAnchor, .top: topAnchor])
        
        let imageViewPadding: CGFloat = 10
        
        placeHolderImageView.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: placeHolderImageView.heightAnchor], constants: [.left: imageViewPadding, .top: imageViewPadding, .bottom: imageViewPadding])
        
        customImageView.pinAllSides(addTo: self, pinTo: placeHolderImageView, insets: UIEdgeInsets(allInsets: -1))
        
        labelStackView.pin(addTo: self, anchors: [.left: customImageView.rightAnchor, .centerY: centerYAnchor], constants: [.left: imageViewPadding])
        
    }
    
    func showLine(){
        bottomLine.alpha = 1
    }
    func hideLine(){
        bottomLine.alpha = 0
    }
    
    private weak var currentUser: TempUser?
    
    func setWithUser(user: TempUser){
        self.customImageView.alpha = 0
        self.currentUser = user
        topLabel.text = user.fullName
        bottomLabel.text = user.email
        if let picture = user.profilePicture{
            self.customImageView.alpha = 1
            self.customImageView.image = picture
        }
        user.setProfileImage { (callback) in
            switch callback{
            case .success(let args):
                if user !== self.currentUser{return}
                self.customImageView.image = args.image
                UIView.animate(withDuration: args.wasDownloaded ? 0.3 : 0, animations: {
                    self.customImageView.alpha = 1
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    
    private lazy var bottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.darkGray
        x.pin(constants: [.height: 0.3])
        return x
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layer.cornerRadius = customImageView.frame.width / 2
    }
    
    private lazy var customImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.layer.masksToBounds = true
        x.alpha = 0
        return x
    }()
    
    private lazy var placeHolderImageView: UIImageView = {
        let x = UIImageView(image: AssetImages.profilePicturePlaceholder)
        x.backgroundColor = .clear
        x.tintColor = .white
        x.contentMode = .scaleAspectFill
        x.layer.masksToBounds = true
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
        x.font = SCFonts.getFont(type: .demiBold, size: 16)
        x.textColor = .white
        return x
    }()
    
    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.textColor = UIColor.lightGray
        x.font = SCFonts.getFont(type: .medium, size: 12)
        x.text = "25m ago in Nassau, New Providence"
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
