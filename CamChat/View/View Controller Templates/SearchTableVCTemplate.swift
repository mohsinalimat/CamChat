//
//  SearchTableVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class SearchTableVC: UIViewController{
    
    init(){
        super.init(nibName: nil, bundle: nil)
        configure(tableView: tableView)
        setUpViews()
        view.layoutIfNeeded()
    }
    
    var desiredTopBarHeight: CGFloat{
        return 45
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewGradient.frame = tableViewHolderView.bounds
        let middleEndPoint = NSNumber(value: Float((APP_INSETS.top + desiredTopBarHeight - 10) / tableViewHolderView.bounds.height))
        let lastEndpoint = NSNumber(value: Float((APP_INSETS.top + desiredTopBarHeight + 10) / tableViewHolderView.bounds.height))
        tableViewGradient.gradientLayer.locations = [0, middleEndPoint, lastEndpoint]
    }
    
    static let tableViewPadding: CGFloat = 15
    
    private func setUpViews(){
        
        topBarLayoutGuide.pin(addTo: view, anchors: [.left: view.leftAnchor, .top: view.safeAreaLayoutGuide.topAnchor, .right: view.rightAnchor], constants: [.height: desiredTopBarHeight])
        
        tableViewHolderView.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .top: view.topAnchor], constants: [.left: SearchTableVC.tableViewPadding, .right: SearchTableVC.tableViewPadding])
    }
    
    private func configure(tableView: UITableView){
        tableView.contentInset.bottom = SearchTableVC.tableViewPadding
        tableView.contentInset.top = desiredTopBarHeight - 5
        tableView.keyboardDismissMode = .onDrag
    }
    
    private(set) var topBarLayoutGuide = UILayoutGuide()

    private lazy var tableViewHolderView: UIView = {
        let x = UIView()
        tableView.pinAllSides(addTo: x, pinTo: x)
        x.mask = tableViewGradient
        return x
    }()
    
    private var _tableView = UITableView()
    
    var tableView: UITableView{
        return _tableView
    }
    
    private lazy var tableViewGradient: HKGradientView = {
        let x = HKGradientView(colors: [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.3), .black])
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
