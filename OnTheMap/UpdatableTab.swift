//
//  UpdatableTab.swift
//  OnTheMap
//
//  Created by Lukasz Chrzanowski on 13/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation

protocol UpdatableTab: class {
    //called wehenever userInformation is updated
    //example usage: if your tab uses table view 
    //call .reloadData() inside this method
    func update()
}