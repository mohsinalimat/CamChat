//
//  PhotoLibraryCollectionViewCell.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class PhotoLibraryCollectionViewCell: UICollectionViewCell{
    
    
    
    weak var vcOwner: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        imageView.pinAllSides(addTo: self, pinTo: self)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToGesture(gesture:)))
        addGestureRecognizer(gesture)
        gesture.minimumPressDuration = 0.25
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.cancelsTouchesInView = true
    }
    
    
    @objc private func respondToGesture(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began { return }
        vcOwner!.present(PhotoOptionsMiniVC(presenter: self), animated: true)
    }
  
    
    
    lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    func pushViewIn(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        })
    }
    
    func pushViewOut(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations:  {
            self.transform = CGAffineTransform.identity
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pushViewIn()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pushViewOut()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pushViewOut()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}



extension PhotoLibraryCollectionViewCell: PhotoOptionsMiniPresenter{
    var viewControllerForTransition: UIViewController {
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
