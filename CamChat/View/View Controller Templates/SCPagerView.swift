//
//  SCPagerView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//


import HelpKit

class SCPagerViewController: UIViewController, SCPagerDataSource, SCPagerDelegate{
    private let desiredBeginningIndex: Int
    init(desiredCurrentIndex: Int){
        self.desiredBeginningIndex = desiredCurrentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int {
        return 10 
    }
    
    func pagerView(_ pagerView: SCPagerView, cellForItemAt index: Int, cachedView: UIView?) -> SCPagerViewCell {
        let newView = SCPagerViewCell()
        newView.backgroundColor = UIColor.random
        return newView
    }
    
    func interactionGradientDidChange(to gradient: CGFloat) {
        
    }
    
    var pagerView: SCPagerView!
    
    override func loadView() {
        let newView = SCPagerView(dataSource: self, desiredCurrentIndex: desiredBeginningIndex)
        newView.delegate = self
        self.pagerView = newView
        newView.frame = UIScreen.main.bounds
        self.view = newView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


protocol SCPagerDataSource: class {
    func pagerView(numberOfItemsIn pagerView: SCPagerView) -> Int
    func pagerView(_ pagerView: SCPagerView, cellForItemAt index: Int, cachedView: UIView?) -> SCPagerViewCell
}

protocol SCPagerDelegate: class{
    /// gradient is given in terms of -1 to 0 to 1
    func interactionGradientDidChange(to gradient: CGFloat)
}



class SCPagerView: UIView, PageScrollingInteractorDelegate{
    
    private weak var dataSource: SCPagerDataSource?
    
    private var cachedCells = [SCPagerViewCell]()
    
    
    private func getCell(for index: Int) -> SCPagerViewCell{
        let cachedView = cachedCells.first
        let cell = dataSource!.pagerView(self, cellForItemAt: index, cachedView: nil)
        if cell === cachedView{cachedCells.remove(at: 0)}
        return cell
    }
    
    weak var delegate: SCPagerDelegate?
    private(set) var currentItemIndex: Int

    init(dataSource: SCPagerDataSource, desiredCurrentIndex: Int){
        self.currentItemIndex = desiredCurrentIndex
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        
        let validIndexRange = (0...dataSource.pagerView(numberOfItemsIn: self) - 1)
        precondition(validIndexRange.contains(desiredCurrentIndex), "the desired current Index provided to SCPagerView is not valid.")
        precondition(dataSource.pagerView(numberOfItemsIn: self) > 0, "You must have at least one item to display in an SCPagerView")
        
        view.backgroundColor = .black
        view.clipsToBounds = true
        setUpViews()
        
        //I'm just doing this because the interactor is being lazily loaded. The interactor is activated by default.
        interactor.startAcceptingTouches()
        interactor.onlyAcceptInteractionInSpecifiedDirection = false
        
        let centerCell = getCell(for: desiredCurrentIndex)
        centerView.setContainedView(to: centerCell)
        centerCell.didEnterPagerView(); centerCell.willAppear(); centerCell.didAppear()
        
        if validIndexRange.contains(desiredCurrentIndex + 1){
            let rightCell = getCell(for: desiredCurrentIndex + 1)
            rightView.setContainedView(to: rightCell)
            rightCell.didEnterPagerView()
        }
        
        if validIndexRange.contains(desiredCurrentIndex - 1){
            let leftCell = getCell(for: desiredCurrentIndex - 1)
            leftView.setContainedView(to: leftCell)
            leftCell.didEnterPagerView()
        }
        
    }
    
    
    var currentCenterCell: SCPagerViewCell{
        return centerView.containedView!
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
        
        let cache = [leftView.removeContainedView(), rightView.removeContainedView(), centerView.removeContainedView()].filterOutNils()
        cache.forEach{$0.willDisappear(); $0.didDisappear(); $0.didLeavePagerView()}
        cachedCells.append(contentsOf: cache)
        
        
        let centerCell = getCell(for: newIndex)
        centerView.setContainedView(to: centerCell)
        centerCell.didEnterPagerView(); centerCell.willAppear(); centerCell.didAppear()

        
        if numberOfItems <= 1{return}
        if newIndex > 0 {
            let leftCell = getCell(for: newIndex - 1)
            leftView.setContainedView(to: leftCell)
            leftCell.didEnterPagerView()
        }
        if newIndex < numberOfItems - 1{
            let rightCell = getCell(for: newIndex + 1)
            rightView.setContainedView(to: rightCell)
            rightCell.didEnterPagerView()
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
    
    
    
    private var shouldRespondToGradientDidSnap = true
    
    func gradientDidSnap(fromScreen: PageScrollingInteractor.ScreenType, toScreen: PageScrollingInteractor.ScreenType, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
        
        if shouldRespondToGradientDidSnap.isFalse{return}
        
        if toScreen == .center{
            
            centerView.containedView?.didAppear()
            leftView.containedView?.didDisappear()
            rightView.containedView?.didDisappear()
            
            return
        }
        
        shouldRespondToGradientDidSnap = false
        interactor.snapGradientTo(screen: .center, animated: false)
        shouldRespondToGradientDidSnap = true
        
        switch toScreen{
        case .first:
            currentItemIndex -= 1
            
            if let view = rightView.removeContainedView(){
                view.didDisappear(); view.didLeavePagerView()
                cachedCells.append(view)
            }
            
            let newRightCell = centerView.removeContainedView()!
            rightView.setContainedView(to: newRightCell)
            newRightCell.didDisappear()
            
            let newCenterCell = leftView.removeContainedView()!
            centerView.setContainedView(to: newCenterCell)
            newCenterCell.didAppear()
            
            if currentItemIndex > 0{
                let newLeftCell = getCell(for: currentItemIndex - 1)
                leftView.setContainedView(to: newLeftCell)
                newLeftCell.didEnterPagerView()
            }
        case .last:
            currentItemIndex += 1
            
            if let view = leftView.removeContainedView(){
                view.didDisappear(); view.didLeavePagerView()
                cachedCells.append(view)
            }
            
            let newLeftCell = centerView.removeContainedView()!
            leftView.setContainedView(to: newLeftCell)
            newLeftCell.didDisappear()
            
            let newCenterCell = rightView.removeContainedView()!
            centerView.setContainedView(to: newCenterCell)
            newCenterCell.didAppear()
            
            if currentItemIndex < numberOfItems - 1{
                let newRightCell = getCell(for: currentItemIndex + 1)
                rightView.setContainedView(to: newRightCell)
                newRightCell.didEnterPagerView()
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
    
    func gradientWillBeginChanging(interactor: PageScrollingInteractor, direction: ScrollingDirection) {
        if shouldRespondToGradientDidSnap.isFalse{return}
        
        centerView.containedView?.willDisappear()
        leftView.containedView?.willAppear()
        rightView.containedView?.willAppear()
        
        
    }
    
    
    func gradientDidChange(to gradient: CGFloat, direction: ScrollingDirection, interactor: PageScrollingInteractor) {
       
        if (currentItemIndex == 0 && gradient < 0) ||
            (currentItemIndex == numberOfItems - 1 && gradient > 0){
            shouldRespondToGradientDidSnap = false
            interactor.snapGradientTo(screen: .center, animated: false)
            shouldRespondToGradientDidSnap = true
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
            x.backgroundColor = .black
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
    
    private(set) var containedView: SCPagerViewCell?
    
    func removeContainedView() -> SCPagerViewCell?{
        containedView?.removeFromSuperview()
        let x = containedView
        containedView = nil
        return x
    }
    
    func setContainedView(to view: SCPagerViewCell){
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



class SCPagerViewCell: UIView{
    
    required init(){ super.init(frame: CGRect.zero) }

    
    
    func willAppear(){ }
    
    func didAppear(){ }
    
    func willDisappear(){ }
    
    func didDisappear(){ }
    
    
    func didEnterPagerView(){ }
    
    func didLeavePagerView(){ }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
