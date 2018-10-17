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
        
        
        noResultsLabel.pin(addTo: tableView, anchors: [.top: tableView.contentLayoutGuide.topAnchor, .left: tableView.contentLayoutGuide.leftAnchor], constants: [.left: UIScreen.main.bounds.width.half - SearchTableVC.tableViewPadding - noResultsLabel.intrinsicContentSize.width.half, .top: 40])
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
    

    private func respondToSearchTextDidChange(newText: String?){
        
        _tableView.searchTextChanged(to: newText)
        
        if searchTextField.hasValidText{
            dissmiss_cancelButton.showCancelButton()
            if _tableView.hasSearchResults{
                noResultsLabel.alpha = 0
            } else { noResultsLabel.alpha = 1 }
        } else {
            dissmiss_cancelButton.showDismissButton()
            noResultsLabel.alpha = 0
        }
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
            self?.respondToSearchTextDidChange(newText: newText)
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
    
    private lazy var noResultsLabel: UILabel = {
        let x = UILabel(text: "No Results 🙄", font: CCFonts.getFont(type: .medium, size: 15), textColor: .white)
        x.alpha = 0
        return x
    }()
    

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
