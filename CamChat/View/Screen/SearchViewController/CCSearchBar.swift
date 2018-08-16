//
//  AppSearchView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit




class CCSearchBar: UIView{
    
    
    init(){
        super.init(frame: CGRect.zero)
        setUpViews()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToTap)))
        
    }
    
    
    private func setUpViews(){
        
        addSubview(searchIcon)
        addSubview(secondaryLabel)
        addSubview(searchTextLabel)
        
        
        searchIcon.pin(anchors: [.left: leftAnchor, .centerY: centerYAnchor], constants: [.width: CCSearchConstants.searchIconSize.width, .height: CCSearchConstants.searchIconSize.height, .left: CCSearchConstants.searchIconLeftPadding])
        
        
        searchTextLabel.pin(anchors: [.left: searchIcon.rightAnchor, .centerY: centerYAnchor], constants: [.width: 200, .left: CCSearchConstants.searchIconRightPadding])
        
        secondaryLabel.pin(anchors: [.left: searchTextLabel.leftAnchor, .centerY: searchTextLabel.centerYAnchor], constants: [.width: 100])
        
        fingerHitArea.pin(addTo: self, anchors: [.left: searchIcon.leftAnchor, .right: secondaryLabel.rightAnchor, .top: searchIcon.topAnchor, .bottom: searchIcon.bottomAnchor], constants: [.top: -20, .bottom: -20, .left: -20, .right: -20])
    }
    
    
    
    
    var searchTappedAction = {}
    
    @objc private func respondToTap(){
        searchTappedAction()
    }
    
    private let searchLabelAlphaEquation = CGQuadEquation(xy(0.5, 0), xy(0, 1), xy(-0.5, 0), min: 0, max: 1)!
    private let secondaryLabelAlphaEquation = CGQuadEquation(xy(-1, 1), xy(-0.5, 0), xy(0.5, 0), min: 0, max: 1)!
   
    func changeGradientTo(gradient: CGFloat, direction: ScrollingDirection){
        
        searchTextLabel.alpha = searchLabelAlphaEquation.solve(for: gradient)
        secondaryLabel.alpha = secondaryLabelAlphaEquation.solve(for: gradient)
        
        if gradient < 0{
            secondaryLabel.text = leftText
        } else if gradient > 0{
            switch direction{
            case .horizontal:secondaryLabel.text = rightText
            case .vertical: secondaryLabel.text = bottomText
                
            }
        }
    }
    
    
    private let leftText = "Friends"
    private let centerText = "Search"
    private let rightText = "Memories"
    private let bottomText = "Settings"
    
    
 
    
    private lazy var secondaryLabel: UILabel = {
        let x = UILabel()
        x.text = "THIS IS THE BEST APP EVER"
        x.textColor = .white
        x.font = SCFonts.getFont(type: .demiBold, size: 20)
        x.alpha = 0
        return x
    }()
    
    private lazy var searchTextLabel: UILabel = {
        let x = UILabel()
        x.text = centerText
        x.textColor = CCSearchConstants.searchTintColor
        x.font = CCSearchConstants.searchLabelFont
        return x
    }()
    
    private lazy var searchIcon: UIImageView = {
        let x = UIImageView(image: AssetImages.magnifyingGlass)
        x.tintColor = CCSearchConstants.searchTintColor
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    private lazy var fingerHitArea: UIView = UIView()
    
   
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let newPoint = fingerHitArea.convert(point, from: self)
        return fingerHitArea.hitTest(newPoint, with: event)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
