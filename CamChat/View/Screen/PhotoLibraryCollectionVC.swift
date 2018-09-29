//
//  PhotoLibrarayTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class PhotoLibraryCollectionVC: SCCollectionView, PhotoLibraryLayoutDelegate {
    
    private weak var screen: Screen?
    
    
    init(screen: Screen){
        self.screen = screen
        super.init()
    }
    
    private var heightCache = [IndexPath: CGFloat]()
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        if let height = heightCache[indexPath]{return height}
        else {
            let screenWidth = UIScreen.main.bounds.width
            let randomUpperBound = Int(screenWidth * 0.16)
            let height = (screenWidth * 0.45) + CGFloat((0...randomUpperBound).randomElement()!)
            heightCache[indexPath] = height
            return height
        }
        

    }
    
    private let imageArray: [UIImage] = {
        let images = AssetImages.examplePhotos
        
        
        var imagesToReturn = [UIImage]()
        for i in 1...30{
            imagesToReturn.append(images.randomElement()!)
        }
        
        return imagesToReturn
    }()
    
   
    
    
    private let cellID = "The Best cell ever"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func registerCells() {
        collectionView.register(PhotoLibraryCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override var topLabelText: String{
        return "Photo Library"
    }
    
    override var topLabelTextColor: UIColor{
        return REDCOLOR
    }
    
   
    
  
    
    
   
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = cellToHideForPhotoViewerDismissal{
            cell.alpha = 1
            cellToHideForPhotoViewerDismissal = nil
        }
    }
    
  
    
    private var cellToHideForPhotoViewerDismissal: UICollectionViewCell?
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoLibraryCollectionViewCell
        cell.vcOwner = self
        cell.screen = screen
        cell.imageView.image = imageArray[indexPath.item]
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 7
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








extension PhotoLibraryCollectionVC: PhotoLibraryViewerTransitioningPresenter{
    
    
    var viewForSnapshotToEnterForDismissal: UIView!{
        return self.view
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
    
   
    
}








