//
//  CCAlertController.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class CCAlertController: UIViewController{
    
    
    

    private let textInfo: (alertTitle: String, alertDescription: String?, primaryButtonText: String, secondaryButtonText: String?)
    
    
//    override func loadView() {
//        let view = CCAlertControllerView(title: textInfo.alertTitle, description: textInfo.alertDescription, primaryButtonText: textInfo.primaryButtonText, secondaryButtonText: textInfo.secondaryButtonText)
//        self.view = view
//    }
    
    
    init(title: String, description: String? = nil, primaryButtonText: String, secondaryButtonText: String? = nil){
        
        
        textInfo = (title, description, primaryButtonText, secondaryButtonText)
        super.init(nibName: nil, bundle: nil)
        setUpViews()
        
    }
    
    
    private func setUpViews(){
        let alertView = CCAlertControllerView(title: textInfo.alertTitle, description: textInfo.alertDescription, primaryButtonText: textInfo.primaryButtonText, secondaryButtonText: textInfo.secondaryButtonText)
        
        alertView.pin(addTo: self.view, anchors: [.centerX: view.centerXAnchor, .centerY: view.centerYAnchor])
        
        
        
    }
    
    
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}





private class CCAlertControllerView: UIView {
    
    
    private let alertTitle: String
    private let alertDescription: String?
    private let primaryButtonText: String
    private let secondaryButtonText: String?
    
    
    init(title: String, description: String? = nil, primaryButtonText: String, secondaryButtonText: String? = nil){
        self.alertTitle = title
        self.alertDescription = description
        self.primaryButtonText = primaryButtonText
        self.secondaryButtonText = secondaryButtonText
        super.init(frame: CGRect.zero)
        setCornerRadius(to: 17)
        backgroundColor = .white
        setUpViews()
    }
    
    private func setUpViews(){
        alertTitleLabel.pin(addTo: self, anchors: [.top: topAnchor, .centerX: centerXAnchor], constants: [.top: titleLabelInsets, .width: titleLabelWidth])
        
        primaryButon.pin(addTo: self, anchors: [.top: alertTitleLabel.bottomAnchor, .centerX: centerXAnchor], constants: [.top: titleLabelInsets, .height: primaryButtonHeight, .width: 180])
    }
    
    override var intrinsicContentSize: CGSize{
        let height = alertTitleLabel.intrinsicContentSize.height + (titleLabelInsets * 2) + primaryButtonHeight + bottomPrimaryButtonInset
        return CGSize(width: desiredViewWidth, height: height)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        primaryButon.setCornerRadius(to: primaryButon.bounds.height / 2)
    }
    
    private let desiredViewWidth: CGFloat = Variations.currentDevice(is: [.iPhone4, .iPhoneSE]) ? 260 : 300
    private let titleLabelInsets: CGFloat = 20
    private let primaryButtonHeight: CGFloat = 45
    private let bottomPrimaryButtonInset: CGFloat = 20
    
    private var titleLabelWidth: CGFloat{
        return desiredViewWidth - (titleLabelInsets * 2)
    }
    
    private lazy var alertTitleLabel: UILabel = {
        let x = UILabel()
        x.numberOfLines = 0
        x.preferredMaxLayoutWidth = titleLabelWidth
        x.text = self.alertTitle
        x.textAlignment = .center
        x.font = SCFonts.getFont(type: .medium, size: 19.5)
        return x
    }()
    
    private lazy var alertDescriptionLabel: UILabel = {
        let x = UILabel()
        x.text = self.alertTitle
        x.font = SCFonts.getFont(type: .regular, size: 17)
        return x
    }()
    
    private lazy var primaryButon: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.backgroundColor = REDCOLOR
        x.label.text = primaryButtonText
        x.label.font = x.label.font.withSize(17)
        return x
    }()
    
    private lazy var secondaryButton: UIButton = {
        let x = UIButton()
        x.setTitle(secondaryButtonText, for: .normal)
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}












