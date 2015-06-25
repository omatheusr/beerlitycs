//
//  PlaceManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 22/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

let API_URL = "https://api.foursquare.com/v2/"
let CLIENT_ID = "URTAIWYA3BRK2KJMI021TPJGSD2DC4SSQEJEUAY4YFDTRXTA"
let CLIENT_SECRET = "JTLHDJCLSALUBS5MGFOQGPQSMLV3LW10JODXSDQNW5FJNKL3"

class PlaceManager: NSObject {
    var objectId: String!
    var name: String!
    var foursquareId: String!
    var totalml: String!
    var createdAt: NSDate!
    var date: String!
    var hour: String!

    override init() {
        super.init()
    }

    init(dictionary : PFObject) {
        super.init()
        
        self.name = dictionary["name"] as! String
        self.foursquareId = dictionary["foursquareId"] as! String
        self.totalml = dictionary["totalml"] as! String
    }

    func newPlace(placeControl: PlaceManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Place")

        query["name"] = placeControl.name
        query["foursquareId"] = placeControl.foursquareId
        query["totalml"] = placeControl.totalml

        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }

    func getPlaces(callback: (allPlaces: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Place")

        var auxPlaces: NSArray!

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxPlaces = objects!
                callback(allPlaces: auxPlaces, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allPlaces: nil, error: error!)
            }
        }
    }

    func requestPlacesWithLocation(location: CLLocation) -> [AnyObject] {
        let requestString = "\(API_URL)venues/search?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&categoryId=4d4b7105d754a06376d81259&v=20130815&ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        if let url = NSURL(string: requestString) {
            let request = NSURLRequest(URL: url)
            if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
                if let returnInfo = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? [String:AnyObject] {
                    let responseInfo = returnInfo["response"] as! [String:AnyObject]
                    let venues = responseInfo["venues"] as! [[String:AnyObject]]
                    return venues
                }
            }
        }
        return []
    }
}