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
let CATEGORY_ID = "4d4b7105d754a06376d81259"

class PlaceManager: NSObject {
    var objectId: String!
    var name: String!
    var foursquareId: String!
    var totalml: String?
    var address: String?
    var location: PFGeoPoint!
    var createdAt: NSDate!
    var date: String!
    var hour: String!

    override init() {
        super.init()
    }

    init(dictionary : PFObject) {
        super.init()
        
        self.objectId = dictionary.objectId
        self.name = dictionary["name"] as! String
        self.foursquareId = dictionary["foursquareId"] as! String
        
        if(dictionary["totalml"] != nil) {
            self.totalml = dictionary["totalml"] as? String
        }
    }

    init(array : AnyObject) {
        super.init()
        
        var placeLocation : NSDictionary = array["location"] as! NSDictionary
        self.name = array["name"] as! String
        self.foursquareId = array["id"] as! String
        if ((placeLocation["address"]) != nil) {
            self.address = placeLocation["address"] as? String
        } else {
            self.address = placeLocation["crossStreet"] as? String
        }
        self.location = PFGeoPoint(latitude:placeLocation["lat"] as! Double, longitude: placeLocation["lng"] as! Double)
    }

    func newPlace(placeControl: PlaceManager, callback: (objId: String, error: NSError?) -> ()) {
        var query = PFObject(className:"Place")

        query["name"] = placeControl.name
        query["foursquareId"] = placeControl.foursquareId
        
        if placeControl.totalml != nil{
            query["totalml"] = placeControl.totalml
        }

        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(objId: query.objectId!, error: nil)
            } else {
                callback(objId: query.objectId!, error: error)
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

    func verifyPlace(foursquareId: String, callback: (exist: Bool, objId: String?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Place")
        query.whereKey("foursquareId", equalTo: foursquareId)

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                if(objects?.count == 1) {
                    let placeInfo = PlaceManager(dictionary: objects!.first as! PFObject)

                    callback(exist: true, objId: placeInfo.objectId, error: nil)
                } else {
                    callback(exist: false, objId: nil, error: nil)
                }
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(exist: true, objId: nil, error: error!)
            }
        }
    }
    

    func requestPlacesWithLocation(location: CLLocation) -> [AnyObject] {
        let requestString = "\(API_URL)venues/search?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&categoryId=\(CATEGORY_ID)&v=20130815&ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
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