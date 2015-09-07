//
//  ParseAPIClient.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 04/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation




class ParseAPIClient : NSObject
{
    static let sharedInstance = ParseAPIClient()
        
    var userInformation = [UserInformation]()
    
    private struct Constants {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let StudentLocationURLSecure = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    
    struct UserInformation {
        //some properties are necessary for UserInformation to be useful
        //these are declared as non-optional types below
        //when initilisig from [String:AnyObject], the initilizer fails 
        //if at least one of this properties can't be set
        
        let createdAt: String?
        let firstName: String
        let lastName: String
        let latitude: Double
        let longitude: Double
        let mapString: String?
        let mediaURL: String
        let objectID: String?
        let uniqueKey: String?
        let updatedAt: String?
        
        init?(dict: [String:AnyObject]) {
            
            //println(dict)
            //println(dict["updatedAt"] as NSDateFormatter)
            
            if let firstName = dict["firstName"] as? String,
                lastName = dict["lastName"] as? String,
                latitude = dict["latitude"] as? Double,
                longitude = dict["longitude"] as? Double,
                mediaURL = dict["mediaURL"] as? String{
                    self.firstName = firstName
                    self.lastName = lastName
                    self.latitude = latitude
                    self.longitude = longitude
                    self.mediaURL = mediaURL
                    //self.updatedAt = updatedAt
                    
                    self.createdAt = dict["createdAt"] as? String
                    self.mapString = dict["mapString"] as? String
                    self.objectID = dict["objectID"] as? String
                    self.uniqueKey = dict["uniqueKey"] as? String
                    self.updatedAt = dict["updatedAt"] as? String
        }
        else { return nil }
        }
    }
    
    
    
    static func getStudentLocations(completionHandler: (result: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.StudentLocationURLSecure)!)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, errorString: "Failed to fetch student locations")
                return
            }
            ParseAPIClient.parseJSONWithCompletionHandler(data) { result, error in
                if error != nil {
                    completionHandler(result: nil, errorString: "Failed to parse JSON")
                    return
                }
                let locations = ((result as? [String:AnyObject])?["results"]) as? [[String:AnyObject]]
                if locations == nil {
                    completionHandler(result: nil, errorString: "Failed to parse JSON")
                    return
                }
                completionHandler(result: locations, errorString: nil)
            }
        }
        task.resume()
    }
    
    static func updateStudentInformation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        ParseAPIClient.getStudentLocations {
            (result, errorString) in
            if errorString != nil {
                completionHandler(success: false, errorString: "Failed to update student locations(network connection?)")
                return }
            self.sharedInstance.userInformation.removeAll(keepCapacity: true)
            var newUserInformation = [UserInformation]()
            for infoDict in result! {
                //userInfo has a failable initilizer which fails when not all necessary info can be extracted
                if let info = UserInformation(dict: infoDict) {
                    newUserInformation.append(info)
                }
            }
            newUserInformation.sort({$0.updatedAt > $1.updatedAt})
            self.sharedInstance.userInformation = newUserInformation
            if errorString != nil {
                completionHandler(success: false, errorString: errorString)
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    static func postUserInformation(userInfo: UserInformation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uniqueKey = userInfo.uniqueKey!
        let firstName = userInfo.firstName
        let lastName = userInfo.lastName
        let mapString = userInfo.mapString!
        let mediaURL = userInfo.mediaURL
        let latitude = userInfo.latitude // 37.386052
        let longitude = userInfo.longitude // -122.083851
        
        
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorString: "Failed to post location")
                return
            }
            self.parseJSONWithCompletionHandler(data) { (result, error) in
                if let createdAt = (result as? [String:AnyObject])?["createdAt"] as? String {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Failed to post location")
                }
            }
        }
        task.resume()
    }
    
    static func parseJSONWithCompletionHandler(data: NSData,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

}