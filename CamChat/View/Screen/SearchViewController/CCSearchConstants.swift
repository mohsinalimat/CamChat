//
//  SearchConstants.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

class CCSearchConstants{
    static let searchIconSize = CGSize(width: 25, height: 25)
    static let searchIconLeftPadding: CGFloat = 15
    static let searchIconRightPadding: CGFloat = 10
    static let searchLabelFont = SCFonts.getFont(type: .demiBold, size: 20)
    static let searchTintColor = UIColor.white
    static var opaqueBackingColor: UIColor{
        let val: CGFloat = 70
        return UIColor(red: val, green: val, blue: val).withAlphaComponent(0.9)
    }
}

