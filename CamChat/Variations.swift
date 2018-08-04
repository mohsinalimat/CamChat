////
////  Variations.swift
////  CamChat
////
////  Created by Patrick Hanna on 7/15/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import UIKit
//import HelpKit
//
//
//
//fileprivate enum Device {
//
//    case  iPhonePlus, iPhoneX, iPhone, iPhoneSE
//
//
//
//
//    static func getFrom(size: CGSize) -> Device{
//        switch size{
//
//        case iPhonePlusSize: return .iPhonePlus
//        case iPhoneXSize: return .iPhoneX
//        case iPhoneSize: return .iPhone
//        case iPhoneSESize: return .iPhoneSE
//
//
//        default: fatalError("This device is not supported!!!! The initializer for the Device enum fell into the default case")
//        }
//    }
//}
//
//
//class Variations{
//
//    private static var currentDevice = Device.getFrom(size: UIScreen.main.bounds.size)
//
////    struct LogingIn{
////
////        static var inputFormViewInsetFromTop_OneTextField: CGFloat{
////            switch currentDevice{
////            case .iPhoneSE: return 60
////            default: return 100
////
////            }
////        }
////        static var inputFormViewInsetFromTop_TwoTextFields: CGFloat{
////            return 65
////        }
////
////    }
////
////
////
//
//
//
//
//
//}
//
//
