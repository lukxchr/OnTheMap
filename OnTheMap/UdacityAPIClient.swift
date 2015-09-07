
//
//  UdacityAPIClient.swift
//  OnTheMapAPIClients
//
//  Created by Lukasz Chrzanowski on 09/08/2015.
//
//

import Foundation

class UdacityAPIClient {
    
    static let sharedInstance = UdacityAPIClient()
    
    static var uniqueKey: String?
    static var firstName: String?
    static var lastName: String?
    
    static func authenticateWithUdacityCredentials(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
     
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Failed to authenticate (network connection?)")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            UdacityAPIClient.parseJSONWithCompletionHandler(newData) {
                result, error in
                if error != nil {
                    completionHandler(success: false, errorString: "Failed to parse the response")
                    return
                }
                let dataDict = result as! [String:AnyObject]
                if let accountData = dataDict["account"] {
                    let accountDict = accountData as! [String:AnyObject]
                    let userID = accountDict["key"] as! String
                    self.getAndSaveUserData(userID)
                    completionHandler(success: true, errorString: nil)
                }
                else {
                    completionHandler(success: false, errorString: "Incorrect username or password")
                }
            }
        }
        task.resume()
    }
    
    static func logOutOfUdacity(completionHandler: (sucess: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(sucess: false, errorString: "Failed connection")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            self.uniqueKey = nil
            self.firstName = nil
            self.lastName = nil
            
            completionHandler(sucess: true, errorString: nil)
        }
        task.resume()
    }
    
    static func getAndSaveUserData(userID: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            self.parseJSONWithCompletionHandler(newData) {
                (result, error) in
                if let resultDict = result as? [String:AnyObject] {
                    let userData = resultDict["user"] as? [String:AnyObject]
                    let lastName = userData?["last_name"] as? String
                    let firstName = userData?["first_name"] as? String
                    
                    self.uniqueKey = userID
                    self.firstName = firstName ?? "unknown"
                    self.lastName = lastName ?? "unknown"
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
