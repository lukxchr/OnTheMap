//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 28/07/2015.
//  Copyright © 2015 ___LC___. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
    }

    
    @IBAction func login() {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        self.activityIndicator.startAnimating()
        
        UdacityAPIClient.authenticateWithUdacityCredentials(username, password: password) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                if errorString != nil {
                    self.showErrorMessageUsingAlertView(errorString!)
                    return
                }
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! TabBarController
                self.presentViewController(vc, animated: false, completion: nil)
            }
        }
    }
    
    
    @IBAction func udacitySignUp() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.urlString = "http://udacity.com/"
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

