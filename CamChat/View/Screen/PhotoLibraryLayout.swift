//
//  PhotoLibraryLayout.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

protocol PhotoLibraryLayoutDelegate: class{
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
}

class PhotoLibraryLayout: UICollectionViewLayout{
    
    
    private var contentHeight: CGFloat = 0
    
    var numberOfColumns = 2
    weak var delegate: PhotoLibraryLayoutDelegate!
    private var width: CGFloat{
        collectionView?.layoutIfNeeded()
        return collectionView!.frame.width
    }
    
    
    override var collectionViewContentSize: CGSize{
        
        return CGSize(width: width, height: self.contentHeight)
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesToReturn: [UICollectionViewLayoutAttributes] = []
        for attribute in attributes where attribute.frame.intersects(rect){
            attributesToReturn.append(attribute)
        }
        return attributesToReturn
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for i in attributes where i.indexPath == indexPath{
            return i
        }
        return nil
    }
    
    
    private var attributes = [UICollectionViewLayoutAttributes]()

    
    var margins: CGFloat = 10

    override func prepare() {
        attributes = []
        let columnWidth = (self.width - (margins * CGFloat(numberOfColumns + 1))) / CGFloat(numberOfColumns)
        var xOffsets = Array<CGFloat>.init(repeating: 0, count: numberOfColumns)
        
        for i in 0..<numberOfColumns{
            xOffsets[i] = (margins * CGFloat(i + 1)) + (columnWidth * CGFloat(i))
        }
        
        var yOffsets = Array<CGFloat>(repeating: 0, count: numberOfColumns)
        var column = 0
        for item in 0..<collectionView!.numberOfItems(inSection: 0){
    
            let indexPath = IndexPath(item: item, section: 0)
            let height = delegate.collectionView(collectionView!, heightForItemAt: indexPath)
            
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame
            attributes.append(attribute)
            
            
            self.contentHeight = max(contentHeight, frame.maxY)
            yOffsets[column] += (height + margins)

            column = (column < numberOfColumns - 1) ? column + 1 : 0
        }
    }
}
