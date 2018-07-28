//
//  PhotoLibrarayTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class PhotoLibraryTableView: SCCollectionView, PhotoLibraryLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item{
        case 0, 2, 4, 6: return 300 - 30
        default: return 300
        
        }
    }
    
    
    private let cellID = "The Best cell ever"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override var topLabelText: String{
        return "Photo Library"
    }
    
    override var topLabelTextColor: UIColor{
        return REDCOLOR
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.random
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    
    
    override var collectionViewLayout: UICollectionViewLayout{
        let layout = PhotoLibraryLayout()
        layout.delegate = self
        return layout
    }
    
    
}
