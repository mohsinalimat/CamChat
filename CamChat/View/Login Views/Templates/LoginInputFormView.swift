//
//  LoginForm.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit

protocol LoginInputFormViewDelegate: class{
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
    
    
    @objc private func textFieldDidChange_field1(){
        
        delegate?.textFieldTextDidChange(textField: topTextField, text: topTextField.textField.text)
    }
    
    @objc private func textFieldDidChange_field2(){
        delegate?.textFieldTextDidChange(textField: bottomTextField, text: topTextField.textField.text)
    }
    
    weak var delegate: LoginInputFormViewDelegate?
    
    enum LoginFormType{
        case twoTextFields, oneTextField
        
    }
    
    
    private lazy var objectTopInsets: [UIView: CGFloat] = [
        self.titleLabel: 0,
        self.topDescriptionLabel: 5,
        self.topTextField: 20,
        self.bottomTextField: 10,
        self.bottomDescriptionLabel: 10
    ]
    
 
    
    private func getObjectsFor(formType: LoginFormType) -> [UIView]{
        switch formType{
        case .twoTextFields: return [titleLabel, topTextField, bottomTextField, bottomDescriptionLabel]
        case .oneTextField: return [titleLabel, topDescriptionLabel, topTextField, bottomDescriptionLabel]
        }
    }
    
    
    
    
    
    private func setUpViews(formType: LoginFormType){
        
        
        var previousItem: UIView?
        for item in getObjectsFor(formType: formType){
            addSubview(item)
            
            let anchorToPinTopTo = (previousItem == nil) ? topAnchor : previousItem!.bottomAnchor
            let topInset = self.objectTopInsets[item]!
            
            item.pin(anchors: [.centerX: centerXAnchor, .top: anchorToPinTopTo], constants: [.top: topInset, .width: preferredWidth])
            
            
            previousItem = item
        }
    }
    
    
    
    
    
    private var preferredWidth: CGFloat{
        return topTextField.intrinsicContentSize.width
    }
    
    private var preferredHeight: CGFloat{
        let objects = getObjectsFor(formType: formType)
        return objects.map{$0.intrinsicContentSize.height + objectTopInsets[$0]!}.reduce(0, +)
        
    }
    
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: preferredWidth, height: preferredHeight)
    }
    
    
    
    var titleLabel: UILabel = {
        let x = UILabel()
        x.font = SCFonts.getFont(type: .medium, size: 22)
        x.textAlignment = .center
        return x
    }()
    
    var topDescriptionLabel: UILabel = {
        let x = UILabel()
        x.textColor = UIColor.gray
        x.numberOfLines = 0
        x.textAlignment = .center
        x.font = SCFonts.getFont(type: .medium, size: 14)
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
        x.font = SCFonts.getFont(type: .medium, size: 11)
        x.numberOfLines = 0
        x.textColor = UIColor.black
        return x
    }()
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
