//
//  PhotoLibrarayTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class PhotoLibraryCollectionVC: SCCollectionView, PhotoLibraryLayoutDelegate{
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
    
    
    
    override var collectionViewLayout: UICollectionViewLayout{
        let layout = PhotoLibraryLayout()
        layout.delegate = self
        return layout
    }
}






