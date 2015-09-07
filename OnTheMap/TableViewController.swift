//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 13/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdatableTab
{

    
    @IBOutlet weak var tableView: UITableView!
    
    var model: [ParseAPIClient.UserInformation] {
        return ParseAPIClient.sharedInstance.userInformation
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    //MARK: TableView delegate and data source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonLocationCell") as! UITableViewCell
        let userInfo = model[indexPath.row]
        cell.textLabel?.text = "\(userInfo.firstName) \(userInfo.lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userWebsite = model[indexPath.row].mediaURL
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        vc.urlString = userWebsite
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    //MARK: UpdatableTab protocol method
    func update() {
        tableView.reloadData()
    }



}