//
//  Templates.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/22/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

typealias SignUpProgressionOuput = UserSignUpProgressionInfo.OutputType

class UserSignUpProgressionInfo {
    init(){}
    
    private var firstName: String?
    private var lastName: String?
    private var password: String?
    private var userName: String?
    private var email: String?
    private var profileImage: UIImage?
    
    func setProfileImage(to image: UIImage){
        profileImage = image
    }
    
    static var minimumPasswordLength = 8
    
    func setFirstName(to text: String) throws {
        let trimmedText = text.withTrimmedWhiteSpaces().capitalizingFirstLetter()
        let testResult = testName(text: trimmedText)
        if testResult.isValid.isFalse{
            let error = HKError(description: testResult.errorMessage ?? "An unknown error occured.")
            throw error
            
        }
        self.firstName = trimmedText
        
    }
    
    func setLastName(to text: String) throws {
        let trimmedText = text.withTrimmedWhiteSpaces().capitalizingFirstLetter()
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        let testResult = testName(text: trimmedText)
        if testResult.isValid.isFalse{throw HKError(description: testResult.errorMessage ?? "An unknown error occured.")}
        self.lastName = trimmedText
    }
    
    func testName(text: String) -> (isValid: Bool, errorMessage: String?) {
        let minAmount = 1, maxAmount = 20
        if text.count < minAmount{return (false, "Names must not be less than \(minAmount) characters.")}
        if text.count > maxAmount{return (false, "Names must not be longer than \(maxAmount) characters.")}
        return (true, nil)
    }
    
    func setPassword(to text: String) throws {
        
        if text.count < UserSignUpProgressionInfo.minimumPasswordLength{
            throw HKError(description: "Passwords must contain at least \(UserSignUpProgressionInfo.minimumPasswordLength) characters.")
        }
        else { self.password = text }
    }
    
    func setEmail(to text: String) throws {
        let trimmedText = text.withTrimmedWhiteSpaces()
        if trimmedText.isValidEmail.isFalse{throw HKError(description: "The email address provided is not valid.")}
        self.email = trimmedText
    }
    
    func setUsername(to text: String) throws{
        let minAmount = 4, maxAmount = 25
        let trimmedText = text.withTrimmedWhiteSpaces()
        if trimmedText.count < minAmount {throw HKError(description: "Usernames must be at least \(minAmount) characters long.")}
        if trimmedText.count > maxAmount{throw HKError(description: "Usernames must not be longer than \(maxAmount) characters.")}
        self.userName = trimmedText
    }
    
    
    typealias OutputType = (firstName: String, lastName: String, username: String, email: String, password: String, profilePicture: UIImage)
    
    
    var output: SignUpProgressionOuput?{
        if let firstname = firstName, let lastname = lastName, let password = password, let username = userName, let email = email, let image = profileImage{
            return (firstname, lastname, username, email, password, image)
        } else { return nil }
    }
}

struct LoginInfo{
    let email: String
    let password: String

    init(email: String, password: String) throws {
        if email.isValidEmail.isFalse{
            throw HKError(description: "The email address provided is not valid.")
        }
        self.email = email
        self.password = password
    }
}




