//
//  Convenience Alerts.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



extension UIViewController {
    
    @discardableResult func presentAreYouSureAlert(description: String, confirmationText: String, confirmationCompletion: @escaping () -> Void) -> CCAlertController{
        let alert = presentCCAlert(title: "Are You Sure? 🤔", description: description, primaryButtonText: confirmationText, secondaryButtonText: "CANCEL")
        
        alert.addPrimaryButtonAction({[weak alert] in
            confirmationCompletion()
            alert?.dismiss(animated: true)
        })
        alert.addSecondaryButtonAction({[weak alert] in alert?.dismiss(animated: true) })
        return alert
    }
    
    
    /// Presents a CCAlertController with a simple Oops title, the description provided and the primary button, with its text set to "OK."
    @discardableResult func presentOopsAlert(description: String) -> CCAlertController{
        let alert = presentCCAlert(title: "Oops! 😣", description: description, primaryButtonText: "OK")
        
        alert.addPrimaryButtonAction({[unowned alert] in alert.dismiss(animated: true)})
        return alert
    }
    
    
    @discardableResult func presentSuccessAlert(description: String) -> CCAlertController{
        let alert = self.presentCCAlert(title: "Success! 😃", description: description, primaryButtonText: "OK")
        alert.addPrimaryButtonAction { [weak alert] in
            alert?.dismiss()
        }
        return alert
    }
    
    
    /// Performs the action closure specified, and if it throws an error, the function handles the error by presenting a CCAlert with the error's localized description.
    func handleErrorWithOopsAlert(action: () throws -> Void){
        do{ try action() }
        catch {
            presentOopsAlert(description: error.localizedDescription)
        }
    }
    
    
    
    
    
    
    
}
