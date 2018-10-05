//
//  PhotoOptionsVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class PhotoOptionsVC: UIViewController{
    
    override var prefersStatusBarHidden: Bool{ return true }
    private let memory: Memory
    private weak var photoOptionsDelegate: PhotoOptionMenuDelegate?
    init(memory: Memory, presenter: HKVCTransParticipator, delegate: PhotoOptionMenuDelegate){
        self.memory = memory
        self.photoOptionsDelegate = delegate
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .black
        customTransitioningDelegate = PhotoOptionsVCTransitioningDelegate(presenter: presenter, presented: self)
        transitioningDelegate = customTransitioningDelegate
        imageView.image = memory.info.image
        
    }
    
    private var customTransitioningDelegate: PhotoOptionsVCTransitioningDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelsPadding: CGFloat = 15
        let topPadding = !Variations.currentDevice(is: .iPhoneWithNotch) ? labelsPadding : 0
        let labelsHeight = labelStackView.spacing + topLabel.intrinsicContentSize.height + bottomLabel.intrinsicContentSize.height
        labelsLayoutGuide.pin(addTo: view, anchors: [.left: view.leftAnchor, .top: view.safeAreaLayoutGuide.topAnchor, .right: view.rightAnchor], constants: [.left: labelsPadding, .top: topPadding, .right: labelsPadding, .height: labelsHeight])
        
        let optionsPadding: CGFloat = 25
        optionsMenuLayoutGuide.pin(addTo: view, anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.safeAreaLayoutGuide.bottomAnchor], constants: [.height: 200, .left: optionsPadding, .right: optionsPadding, .bottom: optionsPadding])
        
        let imagePadding: CGFloat = 23
        let widthRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        imageLayoutGuide.pin(addTo: view, anchors: [.centerX: view.centerXAnchor, .top: labelsLayoutGuide.bottomAnchor, .bottom: optionsMenuLayoutGuide.topAnchor, .width: imageLayoutGuide.heightAnchor], constants: [.top: imagePadding, .bottom: imagePadding], multipliers: [.width: widthRatio])
        
        labelStackView.pinAllSides(addTo: view, pinTo: labelsLayoutGuide)
        imageView.pinAllSides(addTo: view, pinTo: imageLayoutGuide)
        tappableHitArea.pinAllSides(addTo: view, pinTo: view)
        optionsMenu.pinAllSides(addTo: view, pinTo: optionsMenuLayoutGuide)
        
    }
    
    private func moveViewsOnScreen(){
        self.labelStackView.transform = CGAffineTransform.identity
        self.optionsMenu.transform = CGAffineTransform.identity
    }
    
    private func moveViewsOffScreen(){
        view.layoutIfNeeded()
        
        let labelsTranslation = -labelsLayoutGuide.layoutFrame.maxY
        let optionsTranslation = view.bounds.height - optionsMenuLayoutGuide.layoutFrame.minY
        
        labelStackView.transform = CGAffineTransform(translationX: 0, y: labelsTranslation)
        optionsMenu.transform = CGAffineTransform(translationX: 0, y: optionsTranslation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.alpha = 1
    }
    
    
    @objc private func respondToTap(gesture: UITapGestureRecognizer){
        if gesture.state != .ended{return}
        self.dismiss(animated: true, completion: nil)
    }

    

    private lazy var labelsLayoutGuide = UILayoutGuide()
    private lazy var imageLayoutGuide = UILayoutGuide()
    private lazy var optionsMenuLayoutGuide = UILayoutGuide()
    
    
    private lazy var tappableHitArea: UIView = {
        let x = UIView()
        x.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToTap(gesture:))))
        return x
    }()
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.setCornerRadius(to: 10)
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    private lazy var labelStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        x.axis = .vertical
        x.spacing = 2
        return x
    }()
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        x.font = SCFonts.getFont(type: .regular, size: 16)
        x.textColor = .white
        x.text = "Nassau, Bahamas"
        return x
    }()
    
    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.textColor = .gray
        x.font = SCFonts.getFont(type: .medium, size: 12)
        x.text = "July 5, 2018, 8:45 AM"
        return x
    }()
    
    private lazy var optionsMenu: PhotoOptionMenu = {
        let x = PhotoOptionMenu(memory: memory, vcOwner: self, delegate: photoOptionsDelegate)
        return x
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension PhotoOptionsVC: PhotoOptionsVCPresented{
    
    
    func getPhotoViewSnapshotInfo() -> (snapshot: UIView, endingFrame: CGRect, endingCornerRadius: CGFloat) {
        view.layoutIfNeeded()
        let snapshot = imageView.snapshotView(afterScreenUpdates: true)!
        let endingFrame = imageLayoutGuide.layoutFrame
        imageView.alpha = 0
        return (snapshot, endingFrame, imageView.layer.cornerRadius)
    }
    
    
    
    
}

extension PhotoOptionsVC: HKVCTransEventAwareParticipator{
    
    func prepareForPresentation() {
        if isBeingPresented{
            moveViewsOffScreen()
        }
        

    }
    
    func performUnanimatedPresentationAction() {
        if isBeingPresented{
            moveViewsOnScreen()
        }
        

    }
    
    func performUnanimatedDismissalAction() {
        if isBeingDismissed{
            moveViewsOffScreen()
        }
        

    }
    

    
    
}





