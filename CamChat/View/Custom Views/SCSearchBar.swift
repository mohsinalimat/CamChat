//
//  AppSearchView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit




class SCSearchBar: UIView{
    
    
    init(){
        super.init(frame: CGRect.zero)
        setUpViews()
        
        
    }
    
    private let searchLabelAlphaEquation = CGQuadEquation(xy(0.5, 0), xy(0, 1), c3: xy(-0.5, 0), min: 0, max: 1)
    private let secondaryLabelAlphaEquation = CGQuadEquation(xy(-1, 1), xy(-0.5, 0), c3: xy(0.5, 0), min: 0, max: 1)
   
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
    
    
    private func setUpViews(){
        
        addSubview(searchIcon)
        addSubview(secondaryLabel)
        addSubview(searchTextLabel)
        
        
        
        
        searchIcon.pin(anchors: [.left: leftAnchor, .centerY: centerYAnchor, .height: searchTextLabel.heightAnchor], constants: [.width: 20, .height: 2, .left: 15])
    
        
        searchTextLabel.pin(anchors: [.left: searchIcon.rightAnchor, .centerY: centerYAnchor], constants: [.width: 200, .left: 10])
        
        secondaryLabel.pin(anchors: [.left: searchTextLabel.leftAnchor, .centerY: searchTextLabel.centerYAnchor], constants: [.width: 200])
    }
    
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
        x.textColor = .white
        x.font = SCFonts.getFont(type: .demiBold, size: 20)
        return x
    }()
    
    private lazy var searchIcon: UIImageView = {
        let x = UIImageView(image: AssetImages.magnifyingGlass)
        x.tintColor = .white

        x.contentMode = .scaleAspectFill
        return x
    }()
    
   
    
  
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
