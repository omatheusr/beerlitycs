//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class BeerManager: NSObject {
    var objectId: String!
    var name: String!
    var alcoholContent: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()

        self.objectId = dictionary.objectId

        if(dictionary["name"] != nil) {
            self.name = dictionary["name"] as! String
        } else {
            self.name = ""
        }

        if(dictionary["alcoholcontent"] != nil) {
            self.alcoholContent = dictionary["alcoholcontent"] as! String
        } else {
            self.alcoholContent = "0"
        }
    }

    func newBeer(beerControl: BeerManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Beer")

        query["name"] = beerControl.name
        query["alcoholcontent"] = beerControl.alcoholContent

        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
    
    func getBeers(callback: (allBeers: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Beer")
        
        query.whereKey("active", equalTo: true)
        query.orderByAscending("name")

        var auxBeers: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxBeers = objects!
                callback(allBeers: auxBeers, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allBeers: nil, error: error!)
            }
        }
    }
    
}