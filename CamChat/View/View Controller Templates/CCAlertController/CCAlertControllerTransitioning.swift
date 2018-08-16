//
//  CCAlertControllerTransitioning.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CCAlertControllerTransitioningBrain: HKVCTransBrain{
    var presenter: HKVCTransParticipator{ return _presenter }
    var presented: HKVCTransParticipator{ return _presented }
    
    
    
    private lazy var dimmerView: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        x.alpha = 0
        return x
    }()
    
    
    override func prepareForPresentation(using context: UIViewControllerContextTransitioning) {
        super.prepareForPresentation(using: context)
        container.addSubview(dimmerView)
        dimmerView.frame = container.bounds
        
        
    }
    
    
}
