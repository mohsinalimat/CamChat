//
//  ViewController.swift
//  CamChat
//
//  Created by Patrick Hanna on 6/27/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class SCCollectionView: SCScrollView, UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
    
    
    override var scrollView: UIScrollView{
        return collectionView
    }
    
    var collectionViewLayout: UICollectionViewLayout{
        return UICollectionViewLayout()
    }
    
    lazy var collectionView: UICollectionView = {
        let x = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        x.showsVerticalScrollIndicator = false
        x.backgroundColor = .clear
        x.delegate = self
        x.dataSource = self
        return x
    }()
    
    
    
}



class SCTableView: SCScrollView, UITableViewDataSource, UITableViewDelegate{
    
    
    override var scrollView: UIScrollView{
        return tableView
    }
    
    lazy var tableView: UITableView = {
        let x = UITableView()
        x.showsVerticalScrollIndicator = false
        x.backgroundColor = .clear
        x.delegate = self
        x.dataSource = self
        return x
    }()
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    
}

protocol SCScrollViewDelegate: class {
    func SCScrollViewDidScroll(scrollView: SCScrollView, topContentOffset: CGFloat)
}


class SCScrollView: UIViewController, UIScrollViewDelegate {
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    weak var delegate: SCScrollViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        registerCells()
        scrollView.contentInsetAdjustmentBehavior = .never
        // I'm doing the below because sometimes my photoLibrary collectionView controller is be freaking itself out..... and appears to be scrolled up a bit when it's first loaded.
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: false)
        scrollView.layoutIfNeeded()
        
    }
    
    
    

    
    private func setUpViews(){
        view.addSubview(backgroundView)
 
        backgroundView.pin(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor])
        backgroundViewTopAnchor = backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -self.scrollView.contentOffset.y - backgroundViewTopInset)
        backgroundViewTopAnchor.isActive = true

        view.addSubview(scrollView)
        scrollView.pinAllSides(pinTo: view)

    }
    
    /// Override this method in subclasses so that tableView and collectionView cells will be registered at the appropriate times to avoid crashing. NEVER CALL THIS FUNCTION DIRECTLY.
    func registerCells(){
        
    }
    
    
    /// Please use this function to set the top content inset of the scrollView
   
    
    override var additionalSafeAreaInsets: UIEdgeInsets{
        get{ return super.additionalSafeAreaInsets }
        set{
            super.additionalSafeAreaInsets = newValue
            scrollView.contentInset.top = newValue.top + backgroundViewTopInset + APP_INSETS.top
            scrollView.contentInset.bottom = newValue.bottom + APP_INSETS.bottom
        }
    }
    
   
    var topLabelText: String{
        return "Not Specified"
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    
    
    
    var scrollView: UIScrollView{
        return _scrollView
    }

    private lazy var _scrollView: UIScrollView = {
        let x = UIScrollView()
        x.showsVerticalScrollIndicator = false
        x.backgroundColor = .clear
        x.delegate = self
        return x
    }()
    
    lazy var backgroundView: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        x.layer.masksToBounds = true
        x.layer.cornerRadius = 10
        x.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        x.addLayoutGuide(topLabelLayoutGuide)
        
        
        topLabelLayoutGuide.pin(anchors: [.left: x.leftAnchor, .right: x.rightAnchor, .top: x.topAnchor], constants: [.height: backgroundViewTopInset])

        x.addSubview(topLabel)
        
        topLabel.pin(anchors: [.left: topLabelLayoutGuide.leftAnchor, .centerY: topLabelLayoutGuide.centerYAnchor], constants: [.left: 10])
        
        return x
    }()
    
    private lazy var topLabelLayoutGuide = UILayoutGuide()
        
    
    var topLabelTextColor: UIColor{
        return .black
    }
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        x.text = self.topLabelText
        x.textColor = topLabelTextColor
        x.font = CCFonts.getFont(type: .bold, size: 17)
        return x
    }()
    
    private var backgroundViewTopAnchor: NSLayoutConstraint!
    
    private let backgroundViewTopInset: CGFloat = 35
    
    
    
    var currentStatusBarUpset: CGFloat = 0
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        backgroundViewTopAnchor.constant = max((-scrollView.contentOffset.y ),-(backgroundView.layer.cornerRadius / 2) - 10)  - backgroundViewTopInset
        backgroundView.layoutIfNeeded()
        
        delegate?.SCScrollViewDidScroll(scrollView: self, topContentOffset: topContentOffset)
        
        
    }
    
    var topContentOffset: CGFloat{
        return (scrollView.contentOffset.y * -1) - backgroundViewTopInset
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}
