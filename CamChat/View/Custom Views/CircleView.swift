//
//  CircleView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class CircleView: HKView {
    
    override func setUpView() {
        self.backgroundColor = .clear
        layer.addSublayer(circleLayer)
    }
    
   
    
    override var backgroundColor: UIColor?{
        get{
            if let fillColor = circleLayer.fillColor{
                return UIColor(cgColor: fillColor)
            } else {return nil}
        } set {
           circleLayer.fillColor = newValue?.cgColor
        }
    }
    
    let circleLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(arcCenter: centerInBounds, radius: bounds.width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circleLayer.path = path.cgPath
    }
    
    
  
}
