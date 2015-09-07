//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 13/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate, UpdatableTab
{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        syncMapAnnotationsWithModel()
    }
    
    //MARK: MapView delegate methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? UserAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let deququedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                deququedView.annotation = annotation
                view = deququedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let annotation = view.annotation as! UserAnnotation
        let userWebsite = annotation.website
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.urlString = userWebsite
        self.presentViewController(vc, animated: false, completion: nil)
        
    }
    
    func syncMapAnnotationsWithModel() {
        
        let userInfoArray = ParseAPIClient.sharedInstance.userInformation
        var userAnnotations = [UserAnnotation]()
        for userInfo in userInfoArray {
            userAnnotations.append(UserAnnotation(userInfo: userInfo))
        }
        self.mapView?.removeAnnotations(self.mapView?.annotations)
        self.mapView?.addAnnotations(userAnnotations)
    }
    
    //MARK: UpdatableTab method
    func update() {
        syncMapAnnotationsWithModel()
    }
}
