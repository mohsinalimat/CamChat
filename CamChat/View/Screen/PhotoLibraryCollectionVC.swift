//
//  PhotoLibrarayTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit
import AVFoundation

class PhotoLibraryCollectionVC: SCCollectionView, PhotoLibraryLayoutDelegate {
    
    private weak var screen: Screen?
    
    
    init(screen: Screen){
        
        
        
        self.screen = screen
        super.init()
        collectionView.alwaysBounceVertical = true
        viewModel = CoreDataListViewVM(delegate: self, context: CoreData.mainContext)
        collectionView.canCancelContentTouches = false
    }
    
    private var heightCache = [IndexPath: CGFloat]()
    
    
    private var viewModel: CoreDataListViewVM<PhotoLibraryCollectionVC>!
    
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
    
    private var currentSelectionBottomBar: UIView?
    private let totalBottomSelectionBarHeight = APP_INSETS.bottom + 50
    
    private var isInSelectionMode = false
    private let minBottomBarAlpha: CGFloat = 0.5
    private var currentSelectedCellIndexPaths = [IndexPath](){
        didSet{
            if let bar = currentSelectionBottomBar?.subviews.first as? PhotoSelectionBottomBar{
                if currentSelectedCellIndexPaths.count < 1{
                    bar.alpha = minBottomBarAlpha
                    bar.isUserInteractionEnabled = false
                } else {
                    bar.alpha = 1
                    bar.isUserInteractionEnabled = true
                }
            }
        }
    }
    private var allCellsInUse = Set<PhotoLibraryCollectionViewCell>()
    func selectionButtonTapped(){
        isInSelectionMode = true
        currentSelectedCellIndexPaths = []
        let topBar = PhotoSelectionTopBar { [weak self] in
            self?.selectionDissmissButtonTapped()
        }
        screen?.enterSelectionMode(newTopBar: topBar)
        
        let bottomBarContainer = UIView()
        bottomBarContainer.backgroundColor = REDCOLOR
        let bottomBar = PhotoSelectionBottomBar()
        bottomBar.alpha = minBottomBarAlpha
        bottomBar.isUserInteractionEnabled = false
        bottomBar.pinAllSides(addTo: bottomBarContainer, pinTo: bottomBarContainer, insets: UIEdgeInsets(bottom: APP_INSETS.bottom))
        bottomBarContainer.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor], constants: [.height: totalBottomSelectionBarHeight])
        currentSelectionBottomBar = bottomBarContainer
        
        
        bottomBarContainer.transform = CGAffineTransform(translationX: 0, y: totalBottomSelectionBarHeight)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            bottomBarContainer.transform = CGAffineTransform.identity
        }, completion: nil)
        
       changeEditingStateForAllCellsTo(true)
        
        bottomBar.cameraRollButton.addAction {[weak self] in self?.respondToCameraRollSaveButtonTapped()
        }
        bottomBar.shareButton.addAction {[weak self] in
            self?.respondToShareButtonTapped()
        }
        bottomBar.trashButton.addAction {[weak self] in
            self?.respondToDeletionButtonTapped()
        }
        bottomBar.sendButton.addAction { [weak self] in
            self?.respondToSendButtonTapped()
        }
    }
    
    private func selectionDissmissButtonTapped(){
        self.screen?.endSelectionMode()
        isInSelectionMode = false
        currentSelectedCellIndexPaths = []
        self.changeEditingStateForAllCellsTo(false)
        if let bottomBar = self.currentSelectionBottomBar {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                bottomBar.transform = CGAffineTransform(translationX: 0, y: self.totalBottomSelectionBarHeight)
            }, completion: { _ in
                bottomBar.removeFromSuperview()
                self.currentSelectionBottomBar = nil
            })
        }
    }
    
    private func changeEditingStateForAllCellsTo(_ isEditing: Bool){
        if isEditing.isFalse{
            allCellsInUse.forEach{$0.setAsDeselected(animated: true)}
        }
        allCellsInUse.forEach{
            $0.isInSelectionMode = isEditing
        }
        
        
    }
    

    
    override var topLabelText: String{
        return "Photo Library"
    }
    
    override var topLabelTextColor: UIColor{
        return REDCOLOR
    }
    
   
    

    
  
    
    private var cellToHideForPhotoViewerDismissal: UICollectionViewCell?
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        if isInSelectionMode {
            let cell = collectionView.cellForItem(at: indexPath) as? PhotoLibraryCollectionViewCell
            if self.currentSelectedCellIndexPaths.contains(indexPath){
                cell?.setAsDeselected(animated: true)
                
                self.currentSelectedCellIndexPaths.removeElementsEqual(to: indexPath)
                
            } else {
                cell?.setAsSelected(animated: true)
                self.currentSelectedCellIndexPaths.append(indexPath)
            }
        } else {
            let viewer = PhotoLibraryViewerVC(imageArray: viewModel.objects, currentIndex: indexPath.row, presenter: self)
            
            DispatchQueue.main.async {
                self.present(viewer, animated: true, completion: nil)
            }
        }
        
        
        
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
        let snapshot = cell.snapshotView(afterScreenUpdates: true)!
        cell.alpha = 0
        return (snapshot, view.convert(cell.frame, from: collectionView), cell.layer.cornerRadius)
    }
    
   
    
}

extension PhotoLibraryCollectionVC: HKVCTransEventAwareParticipator{
    func cleanUpAfterDismissal() {
        if isBeingDismissed.isFalse{
            if let cell = cellToHideForPhotoViewerDismissal{
                cell.alpha = 1
                cellToHideForPhotoViewerDismissal = nil
            }
        }
    }
}


extension PhotoLibraryCollectionVC: CoreDataListViewVMDelegate{
    var listView: UICollectionView {
        return collectionView
    }
    
    var fetchRequest: NSFetchRequest<Memory> {
        let request = Memory.typedFetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Memory.authorID)) == %@", DataCoordinator.currentUserUniqueID!)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Memory.dateTaken), ascending: false)]
        return request
    }
    
    
    func configureCell(_ cell: PhotoLibraryCollectionViewCell, at indexPath: IndexPath, for object: Memory) {
        allCellsInUse.insert(cell)
        cell.vcOwner = self
        cell.screen = screen
        cell.setWith(memory: viewModel.objects[indexPath.row])
    
        cell.isInSelectionMode = self.isInSelectionMode
        cell.setAsDeselected(animated: false)
        if self.currentSelectedCellIndexPaths.contains(indexPath){
            cell.setAsSelected(animated: false)
        }
    }
}


extension PhotoLibraryCollectionVC{
    
    private var selectedMemories: [Memory]{
        return currentSelectedCellIndexPaths.map{viewModel.objects[$0.row]}
    }
    
    private func respondToDeletionButtonTapped(){
        
        
        let alert = self.presentCCAlert(title: "Are you sure?", description: "Deleted photos and videos cannot be recovered.", primaryButtonText: "Delete", secondaryButtonText: "cancel")
        alert.addPrimaryButtonAction { [weak alert, weak self] in
            guard let self = self else {return}
            alert?.dismiss(animated: true, completion: {
                Memory.delete(memories: self.selectedMemories)
                self.currentSelectedCellIndexPaths = []

            })
        }
        alert.addSecondaryButtonAction {
            alert.dismiss()
        }
    }
    
    private func respondToShareButtonTapped(){
        let vc = Memory.getActivityVCFor(memories: selectedMemories)
        self.present(vc)
    }
    
    private func respondToCameraRollSaveButtonTapped(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        Memory.saveToCameraRoll(memories: selectedMemories) {[weak self] (success) in
            guard let self = self else {return}
            UIApplication.shared.endIgnoringInteractionEvents()
            if success {
                self.presentSuccessAlert(description: "The items were successfully saved to your device.")
            } else {
                self.presentOopsAlert(description: "Something went wrong when trying to save the items to your device. Please ensure that you have allowed CamChat access to your photo library in your privacy settings.")
            }
        }
    }
    
    private func respondToSendButtonTapped(){
        self.present(MemorySenderVC(presenter: self))
    }
    
    
    
    
}








