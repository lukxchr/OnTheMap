//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 11/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var middleTextField: UITextField!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomFindButton: UIButton!
    @IBOutlet weak var bottomSubmitButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var userCoords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        middleTextField.delegate = self
        middleTextField.becomeFirstResponder()
        self.configureUIForStepOne()
    }
    
    @IBAction func findOnTheMap() {
        self.activityIndicator.startAnimating()
        let userLocationString = middleTextField.text!
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationString) {
            (placemarks: [AnyObject]!, error: NSError!) in
            self.activityIndicator.stopAnimating()
            if error != nil || placemarks.isEmpty {
                //self.showErrorMessageUsingAlertView(error.description)
                let errorString: String
                switch error.code {
                case 2:
                    errorString = "No network connection"
                case 8:
                    errorString = "Failed to find specified location"
                default:
                    errorString = "Unknown error"
                }
                self.showErrorMessageUsingAlertView(errorString)
                return
            }
            let placemark = placemarks?[0] as? CLPlacemark
            
            self.userCoords = placemark?.location.coordinate
            
            let newAnnotation = MKPlacemark(placemark: placemark)
            self.mapView?.addAnnotation(newAnnotation)
            let region = MKCoordinateRegion(center: newAnnotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
            self.mapView.setRegion(region, animated: true)
            self.configureUIForStepTwo()
        }
    }
    
    
    @IBAction func submit() {
        let userInfo = ParseAPIClient.UserInformation(dict: [
        "firstName":UdacityAPIClient.firstName!,
        "lastName":UdacityAPIClient.lastName!,
        "uniqueKey":UdacityAPIClient.uniqueKey!,
        "mapString":self.middleTextField.text!,
        "mediaURL":self.topTextField.text!,
        "latitude":self.userCoords!.latitude,
        "longitude":self.userCoords!.longitude
            ])
        
        if userInfo == nil {
            self.showErrorMessageUsingAlertView("Failed to post location")
            return
        }
        
        self.activityIndicator.startAnimating()
        
        ParseAPIClient.postUserInformation(userInfo!) {
            (success, errorString) in
            self.activityIndicator.stopAnimating()
            if errorString != nil {
                self.showErrorMessageUsingAlertView(errorString!)
                return
            }
            
            
            if let pvc = self.presentingViewController as? TabBarController {
                pvc.updateUserInformation()
            }
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func cancelInformationPosting() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func configureUIForStepOne() {
        topTextField.hidden = true
        
        middleTextField.text = ""
        middleTextField.becomeFirstResponder()
        
        bottomSubmitButton.hidden = true
        //add rounded corners to buttons
        bottomSubmitButton.layer.cornerRadius = 10
        bottomFindButton.layer.cornerRadius = 10
        
        mapView.hidden = true
        
    }
    
    private func configureUIForStepTwo() {
        topTextField.hidden = false
        topTextField.becomeFirstResponder()
        topLabel.hidden = true
        
        middleView.hidden = true
        
        bottomView.alpha = CGFloat(0.5)
        bottomFindButton.hidden = true
        bottomSubmitButton.hidden = false
        
        mapView.hidden = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}
