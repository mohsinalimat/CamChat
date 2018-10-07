//
//  CCSearchController.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class CCSearchController: SearchTableVC, UITextFieldDelegate{
    
    
    private let searchBarHeight: CGFloat
    
    override var desiredTopBarHeight: CGFloat{
        return searchBarHeight
    }
    
    
    init(searchBarHeight: CGFloat){
        self.searchBarHeight = searchBarHeight
        super.init()
        transitioningDelegate = fadeTransitionDelegate
    
        setUpViews()
        view.layoutIfNeeded()
        
        
    }
    
    

    private lazy var fadeTransitionDelegate = CCSearchVCTransition(searchController: self)
    

    private func setUpViews(){
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.pinAllSides(addTo: view, pinTo: view)
        view.sendSubviewToBack(blurView)
        
        searchIcon.pin(addTo: view, anchors: [.left: topBarLayoutGuide.leftAnchor, .centerY: topBarLayoutGuide.centerYAnchor],constants: [.left: CCSearchConstants.searchIconLeftPadding])
        
        dissmiss_cancelButton.pin(addTo: view, anchors: [.right: topBarLayoutGuide.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.right: CCSearchConstants.searchIconLeftPadding])
        
        searchTextField.pin(addTo: view, anchors: [.left: searchIcon.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor, .right: dissmiss_cancelButton.leftAnchor], constants: [.right: 15, .left: CCSearchConstants.searchIconRightPadding])
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if isBeingPresented{
            searchTextField.becomeFirstResponder()

            tableView.transform = CGAffineTransform(translationX: 0, y: 70)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.tableView.transform = CGAffineTransform.identity
            })
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if isBeingDismissed{
            searchTextField.resignFirstResponder()
            self.tableView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.transform = CGAffineTransform(translationX: 0, y: 70)
            }
        }
        super.viewWillAppear(animated)
    }
   
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchIcon.bounce()
    }
    


    
    
    
    
    private lazy var searchIcon: BouncySearchIcon = {
        let x = BouncySearchIcon()
        x.pin(constants: [.height: CCSearchConstants.searchIconSize.height, .width: CCSearchConstants.searchIconSize.width])
        return x
    }()
    
    private lazy var searchTextField: UITextField = {
        let x = UITextField()
        
        x.keyboardAppearance = .dark
        x.autocorrectionType = .no
        x.tintColor = CCSearchConstants.searchTintColor
        x.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.font: CCSearchConstants.searchLabelFont, .foregroundColor: UIColor.gray(percentage: 0.7)])
        x.font = CCSearchConstants.searchLabelFont
        x.delegate = self
        x.textColor = CCSearchConstants.searchTintColor
        
        x.addTextDidChangeListener({[weak self] (newText) in
            guard let self = self else {return}
            self._tableView.searchTextChanged(to: newText)
            if self.searchTextField.hasValidText{
                self.dissmiss_cancelButton.showCancelButton()
            } else { self.dissmiss_cancelButton.showDismissButton() }
        })
        return x
    }()
    
    private lazy var dissmiss_cancelButton: SearchVCXDeleteButton = {
        let x = SearchVCXDeleteButton()
        x.dismissButton.addAction({[weak self] in self?.dismiss(animated: true)})
        x.cancelButton.addAction({[weak self] in self?.searchTextField.setTextTo(newText: "")
        })
        x.pin(constants: [.height: 25, .width: 25])
        return x
    }()
    

    
    private lazy var _tableView: CCSearchTableView = {
        let x = CCSearchTableView(owner: self)
        return x
    }()
    
    override var tableView: UITableView{
        return _tableView
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
