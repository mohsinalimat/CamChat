//
//  Convenience Alerts.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



extension UIViewController{
    
    /// Presents a CCAlertController with a simple Oops title, the description provided and the primary button, with its text set to "OK."
    func presentOopsAlert(description: String){
        let alert = presentCCAlert(title: "Oops! 😣", description: description, primaryButtonText: "OK")
        alert.addPrimaryButtonAction({[unowned alert] in alert.dismiss(animated: true)})
    }
    /// Performs the action closure specified, and if it throws an error, the function handles the error by presenting a CCAlert with the error's localized description.
    func handleErrorWithOopsAlert(action: () throws -> Void){
        do{ try action() }
        catch {
            presentOopsAlert(description: error.localizedDescription)
        }
    }
    
}
