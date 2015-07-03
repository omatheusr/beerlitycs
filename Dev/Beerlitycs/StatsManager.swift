//
//  StatsManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 02/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class StatsManager: NSObject {
   
    func get(userId: String!, callback: (position: Int?, error: NSError?) -> ()) {
        let fbRequestFriends : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil)
        
        fbRequestFriends.startWithCompletionHandler{
            (connection:FBSDKGraphRequestConnection!,result:AnyObject?, error:NSError!) -> Void in
            
            var auxUsers: NSArray!
            
            if error == nil && result != nil {
                auxUsers = result!["data"]! as! NSArray
                var fbID = [String]()
                
                for user in auxUsers {
                    let fbIDe = user["id"]! as! String
                    fbID.append(fbIDe)
                }

                var userQuery  = PFUser.query()!
                userQuery.whereKey("objectId", equalTo: userId)

                var friendQuery = PFUser.query()!
                friendQuery.whereKey("facebookId", containedIn: fbID as [AnyObject])
                //friendQuery.orderByDescending("mlDrunk")
                
                var subQuery = PFQuery.orQueryWithSubqueries([userQuery, friendQuery])
                subQuery.orderByDescending("mlDrunk")
                
                subQuery.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        auxUsers = objects!
                        
                        for(var i = 0; i < auxUsers.count; i++) {
                            if(userId == (auxUsers[i].objectId!)) {
                                callback(position: i+1, error: nil)
                            }
                        }
                    } else {
                        callback(position: nil, error: error)
                    }
                }
            } else {
                callback(position: nil, error: error)
            }
        }
    }

}
