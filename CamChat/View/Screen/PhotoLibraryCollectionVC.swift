//
//  PhotoLibrarayTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class PhotoLibraryCollectionVC: SCCollectionView, PhotoLibraryLayoutDelegate, PhotoLibraryViewerTransitioningPresenter{
    

    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.item{
        case 0, 2, 4, 6: return 300 - 30
        default: return 300
        }
    }
    
    private let imageArray: [UIImage] = {
        var images = [UIImage]()
        for i in 0...4{
            images.append(UIImage(named: "iphoneImage\(i)")!)
        }
        
        var imagesToReturn = [UIImage]()
        for i in 1...30{
            imagesToReturn.append(images.randomElement()!)
        }
        
        return imagesToReturn
    }()
    
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    private var previousContentOffset: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    private let cellID = "The Best cell ever"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PhotoLibraryCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override var topLabelText: String{
        return "Photo Library"
    }
    
    override var topLabelTextColor: UIColor{
        return REDCOLOR
    }
    
   
    
  
    
    
    var viewForSnapshotToEnterForDismissal: UIView!{
        return self.view
    }
    
    var viewControllerForPhotoLibraryTransition: UIViewController{
        return parent!
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = cellToHideForPhotoViewerDismissal{
            cell.alpha = 1
            cellToHideForPhotoViewerDismissal = nil
        }
    }
    
    func photoViewerPresentationDidBegin() {
        if let cell = cellToHideForPhotoViewerDismissal{
            cell.alpha = 0
        }
    }
    func photoViewerDismissalWillBegin() {
        if let cell = cellToHideForPhotoViewerDismissal{
            cell.alpha = 0
        }
    }
    
    private var cellToHideForPhotoViewerDismissal: UICollectionViewCell?
    
    
    func getThumbnailInfo(forItemAt index: Int) -> (snapshot: UIView, frame: CGRect, cornerRadius: CGFloat) {
        if let cell = cellToHideForPhotoViewerDismissal{cell.alpha = 1}
        let indexPath = IndexPath(item: index, section: 0)
        
        var cell: UICollectionViewCell!
        
        if let gottenCell = collectionView.cellForItem(at: indexPath){
            cell = gottenCell
            
        } else {
            let frame = collectionViewLayout.layoutAttributesForItem(at: indexPath)!.frame
            collectionView.scrollRectToVisible(frame, animated: false)
            view.layoutIfNeeded()
            cell = collectionView.cellForItem(at: indexPath)!
            cell.layoutIfNeeded()
        }
        
        
        cellToHideForPhotoViewerDismissal = cell
    
        return (cell.snapshotView(afterScreenUpdates: true)!, view.convert(cell.frame, from: collectionView), cell.layer.cornerRadius)
    }
    
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoLibraryCollectionViewCell
        cell.imageView.image = imageArray[indexPath.item]
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewer = PhotoLibraryViewerVC(imageArray: imageArray, currentIndex: indexPath.row, presenter: self)
        self.present(viewer, animated: true, completion: nil)
    }
    
    private lazy var _collectionViewLayout: UICollectionViewLayout = {
        let layout = PhotoLibraryLayout()
        layout.delegate = self
        return layout
    }()
    
    override var collectionViewLayout: UICollectionViewLayout{
        return _collectionViewLayout
    }
}






