//
//  CupManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 22/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class CupManager: NSObject {
    var objectId: String!
    var name: String!
    var size: NSNumber!
    var icon: String?
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()

        self.objectId = dictionary.objectId
        self.name = dictionary["name"] as! String
        self.size = dictionary["size"] as! NSNumber
        self.icon? = dictionary["icon"] as! String
    }
    
    func newCup(cupControl: CupManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Cup")
        
        query["name"] = cupControl.name
        query["size"] = cupControl.size
        query["icon"] = cupControl.icon
        
        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
    
    func getCups(callback: (allCups: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Cup")
        
        var auxCups: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxCups = objects!
                callback(allCups: auxCups, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allCups: nil, error: error!)
            }
        }
    }
}
