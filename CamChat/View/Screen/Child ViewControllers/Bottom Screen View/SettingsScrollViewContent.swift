//
//  SettingsScrollViewContent.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/24/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import MessageUI


class SettingsScrollContentView: UIView{
    
    private unowned let vcOwner: UIViewController
    
    init(vcOwner: UIViewController){
        self.vcOwner = vcOwner
        super.init(frame: CGRect.zero)
        setUpViews()
    }
    

    private func setUpViews(){
        snapCode.pin(addTo: self, anchors: [.top: topAnchor, .centerX: centerXAnchor], constants: [.top: 17])
        topLabel.pin(addTo: self, anchors: [.top: snapCode.bottomAnchor, .centerX: centerXAnchor], constants: [.top: 18])
        bottomLabel.pin(addTo: self, anchors: [.top: topLabel.bottomAnchor, .centerX: centerXAnchor])
        settingsblocksStackView.pin(addTo: self, anchors: [.left: leftAnchor, .right: rightAnchor, .top: bottomLabel.bottomAnchor], constants: [.top: 20, .left: 15, .right: 15])
        
        logOutButton.pin(addTo: self, anchors: [.top: settingsblocksStackView.bottomAnchor, .centerX: centerXAnchor], constants: [.top: 20])
        
        
        self.pin(anchors: [.bottom: logOutButton.bottomAnchor])
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logOutButton.setCornerRadius(to: logOutButton.bounds.height.half)
    }
    
    

    lazy var snapCode: UIImageView = {
        let x = UIImageView(image: DataCoordinator.currentUser!.profilePicture, contentMode: .scaleAspectFill)
        x.setCornerRadius(to: 32)
        x.pin(constants: [.height: 150, .width: 150])
        return x
    }()

    lazy var topLabel: UILabel = {
        let x = UILabel(text: DataCoordinator.currentUser!.fullName, font: CCFonts.getFont(type: .demiBold, size: 24))
        CurrentUsersNameWasChangedNotification.listen(sender: self, action: {[weak x] (args) in
            x?.text = args.newFullName
        })
        x.textColor = .white
        return x
    }()
    
    lazy var bottomLabel: UILabel = {
        let x = UILabel(text: DataCoordinator.currentUser!.email, font: CCFonts.getFont(type: .medium, size: 16))
        x.textColor = UIColor.gray(percentage: 0.6).withAlphaComponent(0.7)
        return x
    }()
    
    private lazy var logOutButtonInfo = SettingsBlockInfo(text: "Log Out", image: AssetImages.logOut, action: { [unowned vcOwner] in
        
        
        let alert = vcOwner.presentCCAlert(title: "Are you sure you want to log out?", primaryButtonText: "Log Out", secondaryButtonText: "Cancel")
        
        
        alert.addPrimaryButtonAction({ [unowned alert] in
            do { try DataCoordinator.logOut() }
            catch {
                alert.dismiss(animated: true, completion: {
                    vcOwner.presentOopsAlert(description: error.localizedDescription)
                })
            }
        })
        alert.addSecondaryButtonAction({[unowned alert] in alert.dismiss(animated: true)})
    })
    
    private lazy var settingsblocksInfoObjects = [
        SettingsBlockInfo(text: "Share Account", image: AssetImages.shareIcon, action:{
            [weak self] in self?.respondToShareAccountButtonPressed()
        }),
        SettingsBlockInfo(text: "Edit Name", image: AssetImages.accountUser, action: {
            [weak self] in self?.vcOwner.present(NameChangerVC())
        }),
        SettingsBlockInfo(text: "Manage Storage", image: AssetImages.storage, action: {
            [weak self] in self?.vcOwner.present(StorageManagerVC())
        }),
        SettingsBlockInfo(text: "Provide Feedback", image: AssetImages.feedbackIcon, action: {
            [weak self] in  self?.respondToFeedbackButton()
        })
    ]

    
    
    private func respondToFeedbackButton(){
        
        
        if MFMailComposeViewController.canSendMail(){
            let newController = MFMailComposeViewController()
            newController.setSubject("CamChat Feedback")
            newController.setToRecipients(["patrickjh1998@hotmail.com"])
            newController.setMessageBody("Hey Patrick, your app is awesome!", isHTML: false)
            newController.mailComposeDelegate = self
            vcOwner.present(newController, animated: true, completion: nil)
        } else {
            vcOwner.presentOopsAlert(description: "For some reason, iOS is not allowing this app to send emails. Check your email settings.")
        }
    }
    
    
    

    
    
    
    private func respondToShareAccountButtonPressed(){
        let string = "Hey, add me on CamChat! My CamChat name is \(DataCoordinator.currentUser!.fullName)"
        let activityVC = UIActivityViewController(activityItems: [string], applicationActivities: nil)
        
        vcOwner.present(activityVC)
    }

    lazy var settingsblocksStackView: UIStackView = {
        let x = UIStackView()
        x.axis = .vertical
        x.alignment = .fill
        x.distribution = .fill
        x.spacing = 10
        for i in settingsblocksInfoObjects{
            let newBlock = SettingsBlockButton(info: i)
            newBlock.pin(constants: [.height: 60])
            x.addArrangedSubview(newBlock)
        }
        return x
    }()
    
    
    lazy var logOutButton: UIView = {
        let x = LogOutSettingsButton(info: logOutButtonInfo)
        x.pin(constants: [.height: 40, .width: 200])
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension SettingsScrollContentView: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        controller.dismiss(animated: true){
            if let error = error{
                self.vcOwner.presentOopsAlert(description: error.localizedDescription)
            }
            
        }
    }
    
    
}





private struct SettingsBlockInfo{
    var text: String
    var image: UIImage
    var action: (() -> Void)?
}

private class SettingsButton: SimpleInteractiveButton {
    
    private let info: SettingsBlockInfo
    
    init(info: SettingsBlockInfo){
        self.info = info
        super.init()
        setCornerRadius(to: 10)
        backgroundColor = UIColor.gray(percentage: 0.4).withAlphaComponent(0.6)
        if let action = info.action { addAction(action) }
        setUpViews()
    }
    
    
    
    
    
    fileprivate func setUpViews(){
        
    }
    
    
    fileprivate lazy var imageView: UIImageView = {
        let x = UIImageView(image: info.image, contentMode: .scaleAspectFit)
        x.tintColor = .white
        x.pin(constants: [.height: 27, .width: 27])
        return x
    }()
    
    fileprivate lazy var label: UILabel = {
        let x = UILabel(text: info.text, font: CCFonts.getFont(type: .medium, size: 18))
        x.textColor = .white
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}









private class SettingsBlockButton: SettingsButton {

    private let imageInset: CGFloat = 10

    fileprivate override func setUpViews(){
        imageViewLayoutGuide.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .width: imageViewLayoutGuide.heightAnchor])
        imageView.pin(addTo: self, anchors: [.centerX: imageViewLayoutGuide.centerXAnchor, .centerY: imageViewLayoutGuide.centerYAnchor])
        
        label.pin(addTo: self, anchors: [.left: imageViewLayoutGuide.rightAnchor, .centerY: centerYAnchor])
    }
    
    private let imageViewLayoutGuide = UILayoutGuide()
    
}









private class LogOutSettingsButton: SettingsButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCornerRadius(to: bounds.height.half)

    }
    
    
    override fileprivate func setUpViews(){
        addSubview(holderView)
        holderView.addSubview(label)
        holderView.addSubview(imageView)
    
        holderView.pin(anchors: [.left: imageView.leftAnchor, .right: label.rightAnchor, .height: heightAnchor, .centerY: centerYAnchor, .centerX: centerXAnchor])
        imageView.pin(anchors: [.left: holderView.leftAnchor, .centerY: holderView.centerYAnchor])
        label.pin(anchors: [.left: imageView.rightAnchor, .centerY: holderView.centerYAnchor], constants: [.left: 7])
    }
    
    private lazy var holderView = UIView()
}




