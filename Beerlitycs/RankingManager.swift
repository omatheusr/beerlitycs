//
//  RankingManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 23/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class RankingManager: NSObject {
    var objectId: String!
    var user: String!
    var totalml: String!
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()
        
        self.totalml = dictionary["totalml"] as! String
    }
    
    func getRanking(callback: (ranking: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Cup")
        query.fromLocalDatastore()
        
        var auxRanking: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxRanking = objects!
                callback(ranking: auxRanking, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(ranking: nil, error: error!)
            }
        }
    }
}
