//
//  SCPagerView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import Foundation
import HelpKit

class SCPagerViewController: UIViewController, SCPagerDataSource, SCPagerDelegate{
   
    
    
    
    
    func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int {
        return 10 
    }
    
    func pagerView(_ pagerView: SCPagerView, viewForItemAt index: Int, cachedView: UIView?) -> UIView {
        let newView = UIView()
        newView.backgroundColor = UIColor.random
        return newView
    }
    
    func interactionGradientDidChange(to gradient: CGFloat) {
        
    }
    
    var pagerView: SCPagerView!
    
    override func loadView() {
        let newView = SCPagerView(dataSource: self)
        newView.delegate = self
        self.pagerView = newView
        newView.frame = UIScreen.main.bounds
        self.view = newView
    }
}


protocol SCPagerDataSource: class {
    func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int
    func pagerView(_ pagerView: SCPagerView, viewForItemAt index: Int, cachedView: UIView?) -> UIView
}

protocol SCPagerDelegate: class{
    /// gradient is given in terms of -1 to 0 to 1
    func interactionGradientDidChange(to gradient: CGFloat)
}



class SCPagerView: UIView, PageScrollingInteractorDelegate{
    
    private weak var dataSource: SCPagerDataSource?
    
    private var cachedViews = [UIView]()
    
    
    private func getView(for index: Int) -> UIView{
        let cachedView = cachedViews.first
        let cell = dataSource!.pagerView(self, viewForItemAt: index, cachedView: nil)
        if cell === cachedView{cachedViews.remove(at: 0)}
        return cell
    }
    
    weak var delegate: SCPagerDelegate?
    
    init(dataSource: SCPagerDataSource){
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        view.backgroundColor = .black
        view.clipsToBounds = true
        setUpViews()
        
        //I'm just doing this because the interactor is being lazily loaded. The interactor is activated by default.
        interactor.activate()
        interactor.onlyAcceptInteractionInSpecifiedDirection = false
        
        if numberOfItems >= 1{
            centerView.setContainedView(to: getView(for: 0))
            if numberOfItems >= 2{
                rightView.setContainedView(to: getView(for: 1))
            }
        } else {fatalError("You must have at least one item to display in an SCPagerView")}
    }
    
    
    
 
    
    
    
    private func setUpViews(){
        [leftView, centerView, rightView].forEach{$0.layer.masksToBounds = true}
        addSubview(longView)
        longView.addSubview(leftSegmentView)
        longView.addSubview(rightSegmentView)
        longView.addSubview(centerSegmentView)
        leftSegmentView.addSubview(leftView)
        centerSegmentView.addSubview(centerView)
        rightSegmentView.addSubview(rightView)
        
        
        
        longView.pin(anchors: [.top: topAnchor, .bottom: bottomAnchor, .width: widthAnchor], multipliers: [.width: 3])
        longViewCenterXConstraint = longView.centerXAnchor.constraint(equalTo: centerXAnchor)
        longViewCenterXConstraint.isActive = true
        
        
        [leftSegmentView, centerSegmentView, rightSegmentView].forEach {
            $0.pin(anchors: [.top: longView.topAnchor, .bottom: longView.bottomAnchor, .width: widthAnchor])
        }
        leftSegmentView.pin(anchors: [.left: longView.leftAnchor])
        centerSegmentView.pin(anchors: [.left: leftSegmentView.rightAnchor])
        rightSegmentView.pin(anchors: [.left: centerSegmentView.rightAnchor])
        
        
        rightView.pinAllSides(pinTo: rightSegmentView)
        centerView.pinAllSides(pinTo: centerSegmentView)
        leftView.pinAllSides(pinTo: leftSegmentView)
    }
    
    
    
    
    func setIndex(to newIndex: Int){
        if newIndex > numberOfItems - 1 || newIndex < 0 {fatalError("index out of bounds")}
        currentItemIndex = newIndex
        
        let cache = [leftView.removeContainedView(), rightView.removeContainedView(), centerView.removeContainedView()].filter({$0 != nil}) as! [UIView]
        
        cachedViews.append(contentsOf: cache)
        
        centerView.setContainedView(to: getView(for: newIndex))
        if numberOfItems <= 1{return}
        if newIndex > 0 {
            leftView.setContainedView(to: getView(for: newIndex - 1))
        }
        if newIndex < numberOfItems - 1{
            rightView.setContainedView(to: getView(for: newIndex + 1))
        }
    }
    
   
    

    lazy var interactor: PageScrollingInteractor = {
        let x = PageScrollingInteractor(delegate: self, direction: .horizontal)
        x.multiplier = 1
        return x
    }()
    

    
    private var numberOfItems: Int{
        return dataSource!.pagerView(numberOfItemsIn: self)
    }
    
    private(set) var currentItemIndex = 0
    
    func gradientDidSnap(fromScreen: PageScrollingInteractor.ScreenType, toScreen: PageScrollingInteractor.ScreenType, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
        
        if toScreen == .center{return}
        
        interactor.snapGradientTo(screen: .center, animated: false)
        
        switch toScreen{
        case .first:
            currentItemIndex -= 1
            
            if let view = rightView.removeContainedView(){cachedViews.append(view)}
            
            rightView.setContainedView(to: centerView.removeContainedView()!)
            centerView.setContainedView(to: leftView.removeContainedView()!)
            if currentItemIndex > 0{
                leftView.setContainedView(to: getView(for: currentItemIndex - 1))
            }
        case .last:
            currentItemIndex += 1
            
            if let view = leftView.removeContainedView(){cachedViews.append(view)}
            
            leftView.setContainedView(to: centerView.removeContainedView()!)
            centerView.setContainedView(to: rightView.removeContainedView()!)
            if currentItemIndex < numberOfItems - 1{
                rightView.setContainedView(to: getView(for: currentItemIndex + 1))
            }
        default: break
        }
    }
    
    
    
    var view: UIView!{
        return self
    }
    
    private let minimumViewTransform: CGFloat = 0.5

    private lazy var centerViewTransformEquation = CGAbsEquation(xy(-1, minimumViewTransform), xy(0, 1), xy(1, minimumViewTransform), min: minimumViewTransform, max: 1)!
    private lazy var centerViewAlphaEquation = CGAbsEquation(xy(-1, 0), xy(0, 1), xy(1, 0), min: 0, max: 1)!
    private lazy var sideViewsTransformEquation = CGAbsEquation(xy(-1, 1), xy(0, minimumViewTransform), xy(1, 1), min: minimumViewTransform, max: 1)!
    private lazy var sideViewsAlphaEquation = CGAbsEquation(xy(-1, 1), xy(0, 0), xy(1, 1), min: 0, max: 1)!
    
    
    
    func gradientDidChange(to gradient: CGFloat, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
       
        if (currentItemIndex == 0 && gradient < 0) ||
            (currentItemIndex == numberOfItems - 1 && gradient > 0){
            interactor.snapGradientTo(screen: .center, animated: false)
            return
        }
        
        delegate?.interactionGradientDidChange(to: gradient)
        
        let centerVal = centerViewTransformEquation.solve(for: gradient)
        let sideVals = sideViewsTransformEquation.solve(for: gradient)
        
        let centerAlpha = centerViewAlphaEquation.solve(for: gradient)
        let sideAlphas = sideViewsAlphaEquation.solve(for: gradient)
        
        centerView.transform = CGAffineTransform(scaleX: centerVal, y: centerVal)
        leftView.transform = CGAffineTransform(scaleX: sideVals, y: sideVals)
        rightView.transform = CGAffineTransform(scaleX: sideVals, y: sideVals)
        
        centerView.alpha = centerAlpha
        leftView.alpha = sideAlphas
        rightView.alpha = sideAlphas
        
        longViewOffset = -interactor.currentGradientPointValue
    }
    
    
    private var longViewCenterXConstraint: NSLayoutConstraint!
    
    private var longViewOffset: CGFloat{
        get { return longViewCenterXConstraint.constant }
        set { longViewCenterXConstraint.constant = newValue; view.layoutIfNeeded() }
    }
    
    private lazy var longView: UIView = {
        let x = UIView()
        x.backgroundColor = .black
        return x
    }()
    
    /// Use this method to add decorative views or buttons or whatever you wanna add to the holder views. Holder view transforms are not changed at all when swiping. They only hold the views whose transforms are changed. Their dimensions remain constant always.
    func configureHolderViews(using action: (UIView) -> Void){
        [leftSegmentView, centerSegmentView, rightSegmentView].forEach(action)
    }
    
    private lazy var leftSegmentView = self.segmentViews[0]
    private lazy var centerSegmentView = self.segmentViews[1]
    private lazy var rightSegmentView = self.segmentViews[2]
    
    private lazy var leftView = self.innerViews[0]
    private lazy var centerView = self.innerViews[1]
    private lazy var rightView = self.innerViews[2]
    
    private lazy var innerViews: [SCPagerContainerView] = {
        var views = [SCPagerContainerView]()
        for x in 1...3{
            let x = SCPagerContainerView()
            x.backgroundColor = .orange
            views.append(x)
        }
        return views
    }()
    
    private lazy var segmentViews: [UIView] = {
        var views = [UIView]()
        for i in 1...3{
            let x = UIView()
            x.backgroundColor = .black
            views.append(x)
        }
        return views
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}



fileprivate class SCPagerContainerView: UIView {
    
    private var containedView: UIView?
    
    func removeContainedView() -> UIView?{
        containedView?.removeFromSuperview()
        let x = containedView
        containedView = nil
        return x
    }
    
    func setContainedView(to view: UIView){
        subviews.forEach{$0.removeFromSuperview()}
        self.layoutIfNeeded()
        self.containedView = view
        view.frame = self.bounds
        addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let containedView = containedView{
            containedView.frame = self.bounds
        }
    }
}
