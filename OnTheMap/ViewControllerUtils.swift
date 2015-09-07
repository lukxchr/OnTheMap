//
//  ViewControllerUtils.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 09/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit

extension UIViewController
{
    func showErrorMessageUsingAlertView(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
