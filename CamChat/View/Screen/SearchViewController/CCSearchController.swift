//
//  CCSearchController.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class CCSearchController: UIViewController, UITextFieldDelegate{
    private let searchBarHeight: CGFloat
    
    init(searchBarHeight: CGFloat){
        self.searchBarHeight = searchBarHeight
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = fadeTransitionDelegate
    
        setUpViews()
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextFieldTextDidChange), name: UITextField.textDidChangeNotification, object: searchTextField)
    }
    
    

    private lazy var fadeTransitionDelegate = CCSearchVCTransition(searchController: self)
    
    override func loadView(){
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.frame = UIScreen.main.bounds
        self.view = view
        
    }
    /// The content view of the main view (because the main view is a UIVisualEffectView)
    private var contentView: UIView{
        return (self.view as! UIVisualEffectView).contentView
    }
    
    private let tableViewPadding: CGFloat = 15
    
    private func setUpViews(){
        
        topBarLayoutGuide.pin(addTo: contentView, anchors: [.left: view.leftAnchor, .top: view.safeAreaLayoutGuide.topAnchor, .right: view.rightAnchor], constants: [.height: self.searchBarHeight])
        
        tableViewHolderView.pin(addTo: contentView, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .top: view.topAnchor], constants: [.left: tableViewPadding, .right: tableViewPadding])
        
        searchIcon.pin(addTo: contentView, anchors: [.left: topBarLayoutGuide.leftAnchor, .centerY: topBarLayoutGuide.centerYAnchor],constants: [.left: CCSearchConstants.searchIconLeftPadding])
        
        dissmiss_cancelButton.pin(addTo: contentView, anchors: [.right: topBarLayoutGuide.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor], constants: [.right: CCSearchConstants.searchIconLeftPadding])
        
        searchTextField.pin(addTo: contentView, anchors: [.left: searchIcon.rightAnchor, .centerY: topBarLayoutGuide.centerYAnchor, .right: dissmiss_cancelButton.leftAnchor], constants: [.right: 15, .left: CCSearchConstants.searchIconRightPadding])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewGradient.frame = tableViewHolderView.bounds
        let middleEndPoint = NSNumber(value: Float((APP_INSETS.top + searchBarHeight - 10) / tableViewHolderView.bounds.height))
        let lastEndpoint = NSNumber(value: Float((APP_INSETS.top + searchBarHeight + 10) / tableViewHolderView.bounds.height))
        tableViewGradient.gradientLayer.locations = [0, middleEndPoint, lastEndpoint]
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
    
    @objc private func respondToTextFieldTextDidChange(){
        if let text = searchTextField.text{
            if text.withTrimmedWhiteSpaces().isEmpty {
                dissmiss_cancelButton.showDismissButton()
            } else {
                dissmiss_cancelButton.showCancelButton()
            }
        } else {
            dissmiss_cancelButton.showDismissButton()
        }
    }

    
    
    
    private lazy var topBarLayoutGuide = UILayoutGuide()
    
    private lazy var searchIcon: CCBouncySearchIcon = {
        let x = CCBouncySearchIcon()
        x.pin(constants: [.height: CCSearchConstants.searchIconSize.height, .width: CCSearchConstants.searchIconSize.width])
        return x
    }()
    
    private lazy var searchTextField: UITextField = {
        let x = UITextField()
        x.keyboardAppearance = .dark
        x.tintColor = CCSearchConstants.searchTintColor
        x.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.font: CCSearchConstants.searchLabelFont, .foregroundColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)])
        x.font = CCSearchConstants.searchLabelFont
        x.delegate = self
        x.textColor = CCSearchConstants.searchTintColor
        return x
    }()
    
    private lazy var dissmiss_cancelButton: SearchVCXDeleteButton = {
        let x = SearchVCXDeleteButton()
        x.dismissButton.addAction({[weak self] in self?.dismiss(animated: true)})
        x.cancelButton.addAction({[weak self] in self?.searchTextField.text = nil; self?.respondToTextFieldTextDidChange()})
        x.pin(constants: [.height: 25, .width: 25])
        return x
    }()
    
    private lazy var tableViewHolderView: UIView = {
        let x = UIView()
        tableView.pinAllSides(addTo: x, pinTo: x)
        x.mask = tableViewGradient
        return x
    }()
    
    private lazy var tableView: CCSearchTableView = {
        let x = CCSearchTableView(owner: self)
        x.contentInset.bottom = self.tableViewPadding
        x.contentInset.top = searchBarHeight - 5
        x.keyboardDismissMode = .onDrag
        return x
    }()
    
    private lazy var tableViewGradient: HKGradientView = {
        let x = HKGradientView(colors: [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.3), .black])
        return x
    }()
    

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
