//
//  CCAlertController.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


extension UIViewController{
    @discardableResult func presentCCAlert(title: String, description: String? = nil, primaryButtonText: String, secondaryButtonText: String? = nil) -> CCAlertController{
        let alert = CCAlertController(presenter: self, title: title, description: description, primaryButtonText: primaryButtonText, secondaryButtonText: secondaryButtonText)
        present(alert, animated: true, completion: nil)
        return alert
    }
}


class CCAlertController: UIViewController{
    
    private var alertView: CCAlertControllerView{
        return view as! CCAlertControllerView
    }
    
    
    
    func addPrimaryButtonAction(_ action: @escaping () -> Void){
        alertView.primaryButon.addAction(action)
    }
    
    func addSecondaryButtonAction(_ action: @escaping () -> Void){
        alertView.secondaryButton.addTarget(self, action: #selector(respondToSecondaryButtonPressed), for: .touchUpInside)
        secondaryButtonActions.append(action)
    }
    
    private var secondaryButtonActions = [() -> Void]()
    @objc private func respondToSecondaryButtonPressed(){
        secondaryButtonActions.forEach{$0()}
    }
    

    private let textInfo: (alertTitle: String, alertDescription: String?, primaryButtonText: String, secondaryButtonText: String?)
    
    
    override func loadView() {
        let view = CCAlertControllerView(title: textInfo.alertTitle, description: textInfo.alertDescription, primaryButtonText: textInfo.primaryButtonText, secondaryButtonText: textInfo.secondaryButtonText)
        self.view = view
    }
    
    
    private let presenter: HKVCTransParticipator
    
    
    override var prefersStatusBarHidden: Bool{
        return presenter.viewController.prefersStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return presenter.viewController.preferredStatusBarStyle
    }
    
    fileprivate init(presenter: HKVCTransParticipator, title: String, description: String? = nil, primaryButtonText: String, secondaryButtonText: String? = nil){
        self.presenter = presenter
        
        
        textInfo = (title, description, primaryButtonText, secondaryButtonText)
        super.init(nibName: nil, bundle: nil)
        customTransitioningDelegate = CCAlertControllerTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = customTransitioningDelegate
        
    }
    
    private var customTransitioningDelegate: CCAlertControllerTransitioningDelegate!
    

    
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
        alertTitleLabel.pin(addTo: self, anchors: [.top: topAnchor, .centerX: centerXAnchor], constants: [.top: titleLabelInsets])
        desiredViewHeight += (alertTitleLabel.intrinsicContentSize.height + titleLabelInsets)
        
        var previousBottomAnchor = alertTitleLabel.bottomAnchor
        var previousBottomInset = titleLabelInsets
        
        if alertDescription != nil{
            
            line.pin(addTo: self, anchors: [.left: alertTitleLabel.leftAnchor, .right: alertTitleLabel.rightAnchor, .top: alertTitleLabel.bottomAnchor], constants: [.top: lineTopAndBottomInsets, .left: -10, .right: -10])
            desiredViewHeight += lineHeight + lineTopAndBottomInsets
            
            alertDescriptionLabel.pin(addTo: self, anchors: [.top: line.bottomAnchor, .centerX: centerXAnchor], constants: [.top: lineTopAndBottomInsets])
            desiredViewHeight += alertDescriptionLabel.intrinsicContentSize.height + lineTopAndBottomInsets
            
            previousBottomAnchor = alertDescriptionLabel.bottomAnchor
            previousBottomInset = topPrimaryButtonInset
        }
        
        
        primaryButon.pin(addTo: self, anchors: [.top: previousBottomAnchor, .centerX: centerXAnchor], constants: [.top: previousBottomInset, .height: primaryButtonHeight, .width: 180])
        desiredViewHeight += previousBottomInset + primaryButtonHeight
        previousBottomInset = bottomPrimaryButtonInset
        
        if secondaryButtonText != nil{
            secondaryButton.pin(addTo: self, anchors: [.centerX: centerXAnchor, .top: primaryButon.bottomAnchor], constants: [.top: secondaryButtonTopAndBottomInsets])
            desiredViewHeight += secondaryButtonTopAndBottomInsets + secondaryButton.intrinsicContentSize.height
            previousBottomInset = secondaryButtonTopAndBottomInsets
        }
        
        desiredViewHeight += previousBottomInset
        invalidateIntrinsicContentSize()

    }
    
    
    
    private let desiredViewWidth: CGFloat = Variations.currentDevice(is: [.iPhone4, .iPhoneSE]) ? 250 : 290
    private var desiredViewHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: desiredViewWidth, height: desiredViewHeight)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        primaryButon.setCornerRadius(to: primaryButon.bounds.height / 2)
    }
    
    
    
    
    private let titleLabelInsets: CGFloat = 20
    private let primaryButtonHeight: CGFloat = 45
    private let topPrimaryButtonInset: CGFloat = 20
    private let bottomPrimaryButtonInset: CGFloat = 20
    
    private var labelWidths: CGFloat{
        return desiredViewWidth - (titleLabelInsets * 2)
    }
    
    private let lineTopAndBottomInsets: CGFloat = 5
    private let lineHeight: CGFloat = 1
    
    private let secondaryButtonTopAndBottomInsets: CGFloat = 7
    
    
    
    lazy var alertTitleLabel: UILabel = {
        let x = UILabel()
        x.numberOfLines = 0
        x.preferredMaxLayoutWidth = labelWidths
        x.text = self.alertTitle
        x.textAlignment = .center
        x.font = SCFonts.getFont(type: (alertDescription == nil) ? .medium : .demiBold, size: 19.5)
        return x
    }()
    
    lazy var line: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.gray(percentage: 0.9)
        x.pin(constants: [.height: lineHeight])
        return x
    }()
    
    lazy var alertDescriptionLabel: UILabel = {
        let x = UILabel()
        x.text = self.alertDescription
        x.numberOfLines = 0
        x.textAlignment = .center
        x.preferredMaxLayoutWidth = labelWidths
        x.font = SCFonts.getFont(type: .medium, size: 14.5)
        return x
    }()
    
    lazy var primaryButon: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.backgroundColor = REDCOLOR
        x.label.text = primaryButtonText
        x.label.font = x.label.font.withSize(17)
        return x
    }()
    
    lazy var secondaryButton: UIButton = {
        let x = UIButton(type: .system)
        x.setAttributedTitle(NSAttributedString(string: secondaryButtonText?.uppercased() ?? "", attributes: [.font: SCFonts.getFont(type: .demiBold, size: 13), .foregroundColor: REDCOLOR]), for: .normal)
        return x
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
