//
//  LoginForm.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

protocol LoginInputFormViewDelegate: class {
    func textFieldTextDidChange(textField: LoginTextFieldView, text: String?)
    func textFieldDidReturn(textField: LoginTextFieldView)
}


class LoginInputFormView: UIView, UITextFieldDelegate{
    
    let formType: LoginFormType
    
    init(formType: LoginFormType){
        self.formType = formType
        super.init(frame: CGRect.zero)
        setUpViews(formType: formType)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange_field1), name: UITextField.textDidChangeNotification, object: self.topTextField.textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange_field2), name: UITextField.textDidChangeNotification, object: self.bottomTextField.textField)
    }
    
    func dismissKeyboard(){
        topTextField.textField.resignFirstResponder()
        bottomTextField.textField.resignFirstResponder()
    }
    func presentKeyboard(){
        topTextField.textField.resignFirstResponder()
    }
    
    
    @objc private func textFieldDidChange_field1(){
        delegate?.textFieldTextDidChange(textField: topTextField, text: topTextField.textField.text)
        
    }
    
    @objc private func textFieldDidChange_field2() {
        delegate?.textFieldTextDidChange(textField: bottomTextField, text: topTextField.textField.text)
    }
    
    weak var delegate: LoginInputFormViewDelegate?
    
    enum LoginFormType{
        case twoTextFields, oneTextField, profileImageChooser
    }
    
    
    private lazy var objectTopInsets: [UIView: CGFloat] = [
        self.titleLabel: 0,
        self.topDescriptionLabel: 5,
        self.topTextField: 20,
        self.bottomTextField: 10,
        self.bottomDescriptionLabel: 10,
        self.imageViewHolder: 40,
        self.imageBrowseButton: 40
    ]
    
    private let imageViewHeight: CGFloat = 175
    private let imageBrowseButtonHeight: CGFloat = 35

    
    private func getHeight(of view: UIView) -> CGFloat{
        let array = [titleLabel, topDescriptionLabel, topTextField, bottomTextField, bottomDescriptionLabel]
        
        if array.contains (view) { return view.intrinsicContentSize.height }
        
        if view === self.imageBrowseButton{return imageBrowseButtonHeight}
        else if view === self.imageViewHolder{return imageViewHeight}
        
        fatalError()
    }
    
 
    
    private func getObjectsFor(formType: LoginFormType) -> [UIView]{
        switch formType{
        case .twoTextFields: return [titleLabel, topTextField, bottomTextField, bottomDescriptionLabel]
        case .oneTextField: return [titleLabel, topDescriptionLabel, topTextField, bottomDescriptionLabel]
        case .profileImageChooser: return [titleLabel, imageViewHolder, imageBrowseButton]
        }
    }
    
    
    
    
    
    private func setUpViews(formType: LoginFormType){
        
        if formType == .profileImageChooser{
            titleLabel.pin(addTo: self, anchors: [.top: topAnchor, .centerX: centerXAnchor, .width: widthAnchor])
            
            imageViewHolder.pin(addTo: self, anchors: [.centerX: centerXAnchor, .top: titleLabel.bottomAnchor, .width: imageViewHolder.heightAnchor], constants: [.height: imageViewHeight, .top: self.objectTopInsets[imageViewHolder]!])

            
            imageBrowseButton.pin(addTo: self, anchors: [.top: imageViewHolder.bottomAnchor, .centerX: centerXAnchor], constants: [.top: objectTopInsets[imageBrowseButton]!, .height: imageBrowseButtonHeight, .width: imageBrowseButton.label.intrinsicContentSize.width + 70])
            
            
        } else {
            var previousItem: UIView?
            for item in getObjectsFor(formType: formType){
                addSubview(item)
                
                let anchorToPinTopTo = (previousItem == nil) ? topAnchor : previousItem!.bottomAnchor
                let topInset = self.objectTopInsets[item]!
                
                item.pin(anchors: [.centerX: centerXAnchor, .top: anchorToPinTopTo], constants: [.top: topInset, .width: preferredWidth])
                
                
                previousItem = item
            }
        }
        
    }
    
    
    
    
    
    private var preferredWidth: CGFloat{
        return 260
    }
    
    private var preferredHeight: CGFloat{
        let objects = getObjectsFor(formType: formType)
        return objects.map{self.getHeight(of: $0) + self.objectTopInsets[$0]!}.reduce(0, +)
        
    }
    
    
    override var intrinsicContentSize: CGSize{
        let size = CGSize(width: preferredWidth, height: preferredHeight)
        
        return size
    }
    
    
    
    var titleLabel: UILabel = {
        let x = UILabel()
        x.font = CCFonts.getFont(type: .medium, size: 22)
        x.textAlignment = .center
        return x
    }()
    
    var topDescriptionLabel: UILabel = {
        let x = UILabel()
        x.textColor = UIColor.gray
        x.numberOfLines = 0
        x.textAlignment = .center
        x.font = CCFonts.getFont(type: .medium, size: 14)
        return x
    }()
    
    lazy var topTextField: LoginTextFieldView = {
        let x = LoginTextFieldView()
        x.textField.delegate = self
        return x
    }()
    
    lazy var bottomTextField: LoginTextFieldView = {
        let x = LoginTextFieldView()
        x.textField.delegate = self
        return x
    }()
    
    
    private lazy var imageViewHolder: UIView = {
        let x = UIView()
        x.backgroundColor = .clear
        
        let placeHolder = UIImageView(image: AssetImages.profilePicturePlaceholder)
        placeHolder.tintColor = .black
        placeHolder.contentMode = .scaleAspectFit
        
        placeHolder.pinAllSides(addTo: x, pinTo: x, insets: UIEdgeInsets(allInsets: 25))
        imageView.pinAllSides(addTo: x, pinTo: x)
        return x
    }()
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.backgroundColor = .clear
        x.setCornerRadius(to: 30)
        return x
    }()
    
    
    lazy var imageBrowseButton: SimpleLabelledButton = {
        let x = SimpleLabelledButton()
        x.backgroundColor = BLUECOLOR
        x.label.attributedText = NSAttributedString(string: "Browse", attributes: [.font: CCFonts.getFont(type: .demiBold, size: 15), .foregroundColor: UIColor.white])
        
        return x
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageBrowseButton.setCornerRadius(to: imageBrowseButton.frame.height.half)
        imageViewHolder.setCornerRadius(to: imageViewHolder.frame.height.half)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === topTextField.textField{
            delegate?.textFieldDidReturn(textField: topTextField)
        } else if textField === bottomTextField.textField{
            delegate?.textFieldDidReturn(textField: bottomTextField)
        }
        return true
    }
    
    
    var bottomDescriptionLabel: UILabel = {
        let x = UILabel()
        x.font = CCFonts.getFont(type: .medium, size: 11)
        x.numberOfLines = 0
        x.textColor = UIColor.black
        return x
    }()
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
