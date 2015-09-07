//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 13/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate
{
    weak var toolbar: UIToolbar!
    weak var activityBar: UILabel!
    
    override func viewDidLoad() {
        self.configureUI()
        updateUserInformation()
        super.viewDidLoad()
    }
    
    
    func configureUI() {
        //add toolbar with tiltle and 3 buttons
        let toolbar = UIToolbar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        toolbar.autoresizingMask = .FlexibleWidth
        toolbar.backgroundColor = UIColor.whiteColor()
        
        //create buttons
        let logoutButton = UIBarButtonItem()
        logoutButton.title = "Logout"
        logoutButton.target = self
        logoutButton.action = "logout"
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "updateUserInformation")
        
        let checkInButton = UIBarButtonItem()
        //checkInButton.title = "CheckIn"
        checkInButton.target = self
        checkInButton.action = "checkIn"
        checkInButton.image = UIImage(named: "pin")
        
        //make title item look like title in UINavigationBar
        let titleItem = UIBarButtonItem(title: "On The Map", style: .Plain, target: nil, action: nil)
        titleItem.enabled = false
        let textAttributes = [NSForegroundColorAttributeName : UIColor.darkTextColor()]
//        titleItem.setTitleTextAttributes(textAttributes, forState: UIControlState.Disabled)
        titleItem.setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
      
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolbar.items = [logoutButton, flexibleSpace, titleItem, flexibleSpace, checkInButton, refreshButton]
        
        self.view.addSubview(toolbar)
        self.toolbar = toolbar
        
        
        //add activityBar
        
        let activityBar = UILabel(frame: CGRectMake(0, 64, self.view.frame.size.width, 20))
        activityBar.autoresizingMask = .FlexibleWidth
        activityBar.text = "Fetching data..."
        //activityBar.font = UIFont(name: "System", size: 8)
        
        activityBar.backgroundColor = UIColor.greenColor()
        activityBar.textColor = UIColor.whiteColor()
        activityBar.hidden = true
        self.view.addSubview(activityBar)
        //keep reference to the bar to show/hide it when appropriate
        self.activityBar = activityBar
        
    }
    
    func checkIn() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func logout() {
        UdacityAPIClient.logOutOfUdacity() { (success, errorString) in
            if let message = errorString {
                self.showErrorMessageUsingAlertView(message)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
                }
            }
        }
    }
    
    func updateUserInformation() {
        activityBar.hidden = false
        ParseAPIClient.updateStudentInformation {
            (success, errorString) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityBar.hidden = true
                if errorString != nil {
                    self.showErrorMessageUsingAlertView(errorString!)
                    return
                }
                let pvc = self.selectedViewController
                //class that conforms to TabBarControllerDelegate 
                //implemets update method
                if let vc = pvc as? UpdatableTab {
                    vc.update()
                }
            }
        }
    }


}