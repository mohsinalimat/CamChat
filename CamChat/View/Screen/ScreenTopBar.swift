//
//  ScreenTopBar.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/29/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit




class ScreenTopBar: HKView{
    
    
    

    
    typealias DelegateType = CCSearchBarDelegate & ScreenButtonsTopBarDelegate
    private weak var delegate: DelegateType?
    
    init(delegate: DelegateType){
        self.delegate = delegate
        super.init()
        
        
    }
    
    override func setUpView() {
        topSearchBar.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: centerXAnchor])
        buttonTopBar.pin(addTo: self, anchors: [.left: topSearchBar.rightAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: rightAnchor])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isUserInteractionEnabled.isFalse || isHidden || alpha == 0{return nil}
        for subview in [topSearchBar, buttonTopBar] {
            let newPoint = subview.convert(point, from: self)
            if let view = subview.hitTest(newPoint, with: event){return view}
        }
        
        return nil
    }
    
    lazy var topSearchBar: CCSearchBar = {
        let x = CCSearchBar(delegate: delegate!)
        x.applyShadow(width: 0.5)
        return x
    }()
    
    lazy var buttonTopBar: ScreenButtonsTopBar = {
        let x = ScreenButtonsTopBar(delegate: delegate!)
        return x
    }()
    
    
    private let searchBarShadowAlphaEquation = AbsoluteValueEquation<Float>(xy(-1, 0), xy(0, 1), xy(1, 0), min: 0, max: 1)!
    
    
    func adaptTo(gradient: CGFloat, direction: ScrollingDirection){
        topSearchBar.changeGradientTo(gradient: gradient, direction: direction)
        buttonTopBar.changeIconPositionsAccordingTo(gradient: gradient, direction: direction)
        
        topSearchBar.layer.shadowOpacity = searchBarShadowAlphaEquation.solve(for: Float(gradient))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
}
