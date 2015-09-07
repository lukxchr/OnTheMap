//
//  UserAnnotation.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 06/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import MapKit

class UserAnnotation: NSObject, MKAnnotation
{
    let name: String
    let website: String
    let coordinate: CLLocationCoordinate2D
    
    var title: String {
        return name
    }
    var subtitle: String {
        return website
    }
    
    init(name: String, website: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.website = website
        self.coordinate = coordinate
        
        super.init()
    }
    
    convenience init(userInfo: ParseAPIClient.UserInformation){
            let userName = "\(userInfo.firstName) \(userInfo.lastName)"
            let coordinate = CLLocationCoordinate2D(latitude: userInfo.latitude, longitude: userInfo.longitude)
            self.init(name: userName, website: userInfo.mediaURL, coordinate: coordinate)
            }
    
    
}
