//
//  PlaceManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 22/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

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

        //                query.saveInBackgroundWithBlock { Salvar no Servidor
        query.pinInBackgroundWithBlock {
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
        query.fromLocalDatastore()

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
}
