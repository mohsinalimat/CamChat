//
//  PhotoLibraryCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class PhotoLibraryCollectionViewCell: UICollectionViewCell {
    
    private static var cachedImages = HKCache<Memory, UIImage>(objectLimit: 100)
    
    weak var vcOwner: UIViewController?
    weak var screen: Screen?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        imageView.pinAllSides(addTo: self, pinTo: self)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToGesture(gesture:)))
        self.longPressGesture = gesture
        addGestureRecognizer(gesture)
        gesture.minimumPressDuration = 0.325
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.cancelsTouchesInView = true
        
        setCornerRadius(to: 7)
    }
    private var longPressGesture: UILongPressGestureRecognizer!
    
    private var currentMemory: Memory?
    
    func setWith(memory: Memory){
        self.currentMemory = memory
        if let image = PhotoLibraryCollectionViewCell.cachedImages[memory]{
            imageView.image = image
        } else {
            let image = memory.info.image
            PhotoLibraryCollectionViewCell.cachedImages[memory] = image
            imageView.image = image
        }
    }
    
    
    
    
    @objc private func respondToGesture(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began { return }
        vcOwner!.present(PhotoOptionsMiniVC(presenter: self, memory: currentMemory!, delegate: nil))
        screen!.horizontalScrollInteractor.snapGradientTo(screen: .last, animated: false)
        screen!.horizontalScrollInteractor.gesture.cancelCurrentTouch()
    }
  
    var isInSelectionMode = false{
        didSet {
            longPressGesture.isEnabled = isInSelectionMode.isFalse
        }
    }
    
    private var currentSelectionCoverView: UIView?
    
    func setAsSelected(animated: Bool){
        if currentSelectionCoverView.isNotNil{return}
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        let checkMark = UIImageView(image: AssetImages.checkMarkCircle, contentMode: .scaleAspectFit)
        checkMark.tintColor = REDCOLOR
        checkMark.pin(addTo: selectionView, anchors: [.centerX: selectionView.centerXAnchor, .centerY: selectionView.centerYAnchor], constants: [.height: 25, .width: 25])
        self.currentSelectionCoverView = selectionView
        selectionView.pinAllSides(addTo: self, pinTo: self)
    
        pushViewIn(animated: animated)
    }
    
    func setAsDeselected(animated: Bool){
        if let selectionView = self.currentSelectionCoverView{
            selectionView.removeFromSuperview()
            self.currentSelectionCoverView = nil
        }
        self.pushViewOut(animated: animated)
    }
    

    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    private func pushViewIn(animated: Bool = true){
        UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        })
    }
    
    private func pushViewOut(animated: Bool = true){
        UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform.identity
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isInSelectionMode{return}
        pushViewIn()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isInSelectionMode{return}
        pushViewOut()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if isInSelectionMode{return}
        pushViewOut()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}



extension PhotoLibraryCollectionViewCell: PhotoOptionsMiniPresenter{
    
    var viewControllerForTransition: UIViewController{
        return vcOwner!.topMostLevelParent
    }
    
    func getSnapshotInfo() -> (snapshot: UIView, cornerRadius: CGFloat, currentFrame: CGRect, currentTransform: CGAffineTransform, endingFrame: CGRect) {
        
        let snapshot = self.snapshotView(afterScreenUpdates: false)!
        let collectionView = superview! as! UICollectionView
        let endingFrame = collectionView.layoutAttributesForItem(at: collectionView.indexPath(for: self)!)!.frame
        let frameToUse = UIScreen.main.coordinateSpace.convert(frame, from: superview!)
        let endingFrameToUse = UIScreen.main.coordinateSpace.convert(endingFrame, from: superview!)
        
        return (snapshot, layer.cornerRadius, frameToUse, transform, endingFrameToUse)
    }
    
    func prepareForPresentation() {
        self.alpha = 0
    }
    
    func cleanUpAfterDismissal() {
        self.alpha = 1
    }
}
