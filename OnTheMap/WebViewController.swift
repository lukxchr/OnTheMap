//
//  WebViewController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 07/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var urlString = ""
    
    override func viewDidLoad() {
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        webView.loadRequest(request)
        webView.delegate = self
    }
    
    @IBAction func cancelAndDismissViewController(sender: UIBarButtonItem) {
        presentingViewController!.dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }


}
