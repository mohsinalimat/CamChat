//
//  Fonts.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

enum SCFontType: String{
    case regular = "Regular"
    case demiBold = "DemiBold"
    case bold = "Bold"
    case heavy = "Heavy"
    case medium = "Medium"
}

class SCFonts{
    
    private static var fontTypeString = "AvenirNext"
    
    static func getFont(type: SCFontType, size: CGFloat) -> UIFont{
        return UIFont(name: fontTypeString + "-" + type.rawValue, size: size)!
    }
}
