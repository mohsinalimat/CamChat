//
//  MemorySenderUserCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class MemorySenderUserCell: UITableViewCell{
    
    static var cellHeight: CGFloat = 54

    
    private let unselectedTextFont = CCFonts.getFont(type: .medium, size: 17)
    private let selectedTextFont = CCFonts.getFont(type: .demiBold, size: 17)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        
        selectionStyle = .none
        
        self.heightAnchor.constraint(equalToConstant: MemorySenderUserCell.cellHeight).isActive = true
        profileImageView.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: profileImageView.heightAnchor], constants: [.left: 5, .top: 5, .bottom: 5])
        nameLabel.pin(addTo: self, anchors: [.left: profileImageView.rightAnchor, .centerY: profileImageView.centerYAnchor], constants: [.left: 10])
        bottomLine.pin(addTo: self, anchors: [.left: leftAnchor, .right: rightAnchor, .bottom: bottomAnchor])
        checkCircle.pin(addTo: self, anchors: [.centerX: profileImageView.rightAnchor, .centerY: profileImageView.topAnchor], constants: [.centerY: 8, .centerX: -10])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.setCornerRadius(to: profileImageView.frame.height.half)
    }
    
    
    private(set) var currentUser: User?
    
    func setWith(user: User){
        self.currentUser = user
        nameLabel.text = user.firstName
        profileImageView.image = user.profilePicture
    }
    
    
    func setShowsBottomLine(to bool: Bool){
        bottomLine.alpha = bool ? 1 : 0
    }
    
    
    
    func setSelectedTo(_ bool: Bool, animated: Bool){
        
        nameLabel.textColor = bool ? BLUECOLOR : .black
        nameLabel.font = bool ? selectedTextFont : unselectedTextFont
        let action = {
            self.checkCircle.transform = bool ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        }
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: action)

    }
    
    private lazy var checkCircle: UIView = {
        let x = UIView()
        
        let circle = HKCircleView()
        circle.backgroundColor = .white
        circle.pinAllSides(addTo: x, pinTo: x)
        
        let checkImage = UIImageView(image: AssetImages.checkMarkCircle, contentMode: .scaleAspectFit)
        checkImage.tintColor = BLUECOLOR
        checkImage.pinAllSides(addTo: x, pinTo: x, insets: UIEdgeInsets(allInsets: 1.5))
        
        x.pin(constants: [.height: 20, .width: 20])
        x.transform = CGAffineTransform(scaleX: 0.0000001, y: 0.0000001)
        return x
    }()
    
    private lazy var profileImageView: UIImageView = {
        let x = UIImageView(contentMode: .scaleAspectFill)
        x.clipsToBounds = true
        return x
    }()
    
    private lazy var nameLabel: UILabel = {
        let x = UILabel(font: unselectedTextFont, textColor: .black)
        
        return x
    }()
    
    private lazy var bottomLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.gray(percentage: 0.8)
        x.pin(constants: [.height: 0.7])
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}

