//
//  CamChatTests.swift
//  CamChatTests
//
//  Created by Patrick Hanna on 8/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import XCTest


@testable import CamChat


class SignUpProgressionInfoTests: XCTestCase {
    
    
    func testSettingInvalidEmailFails() {
        let info = UserSignUpProgressionInfo()
        
        XCTAssertThrowsError(try info.setEmail(to: "patrickjh1mail.com"))
        XCTAssertThrowsError(try info.setEmail(to: "a;lsdkfj"))
        XCTAssertThrowsError(try info.setEmail(to: " "))
        XCTAssertThrowsError(try info.setEmail(to: "something@something"))
    }
    
    func testSettingValidEmailDoesntFail(){
        let info = UserSignUpProgressionInfo()
        
        XCTAssertNoThrow(try info.setEmail(to: "patrickjh1998@hotmail.com"))
        XCTAssertNoThrow(try info.setEmail(to: "whatever@whatever.com"))
        XCTAssertNoThrow(try info.setEmail(to: "hello@helloWorld.com"))
    }
    
    
}
