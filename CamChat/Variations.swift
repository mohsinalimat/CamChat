//
//  Variations.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import HelpKit



struct Devices: OptionSet {

    let rawValue: Int
    

    static let iPhonePlus = Devices(rawValue: 1)
    static let iPhoneX = Devices(rawValue: 2)
    static let iPhone = Devices(rawValue: 4)
    static let iPhoneSE = Devices(rawValue: 8)
    static let iPhone4 = Devices(rawValue: 32)




    static func getFrom(size: CGSize) -> Devices{
        switch size{

        case iPhonePlusSize: return .iPhonePlus
        case iPhoneXSize: return .iPhoneX
        case iPhoneSize: return .iPhone
        case iPhoneSESize: return .iPhoneSE
        case iPhone4Size: return .iPhone4


        default: fatalError("This device is not supported!!!! The initializer for the Device enum fell into the default case")
        }
    }
}


class Variations{

    private static var currentDevice = Devices.getFrom(size: UIScreen.main.bounds.size)

    
    static func doOn(_ devices: Devices, action: () -> Void){
        if devices.contains(currentDevice){
            action()
        }
    }
    
    static func doOnAll(except devices: Devices, action: () -> Void){
        if !devices.contains(currentDevice){
            action()
        }
    }
    
    static var notchHeight: CGFloat{
        switch currentDevice{
        case .iPhoneX: return 30
        default: return 0
        }
    }
    
    static var homeIndicatorHeight: CGFloat{
        switch currentDevice{
        case .iPhoneX: return 22
        default: return 0
        }
    }
    
    
    
    static func currentDevice(is device: Devices) -> Bool{
        return device.contains(currentDevice)
    }
}


