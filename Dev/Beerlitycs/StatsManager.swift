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

    func alcoholContentInBlood(user: String, callback:(alcoholInBlood: Double?, type: Int?, error: NSError?)->()){
        let drink = DrinkManager()
        let userControl = UserManager(dictionary: PFUser(withoutDataWithObjectId: user))
        
        drink.getLatestDrinkPerUser(user, callback: { (drinks, error) -> () in
            if(error == nil){
                
                if(drinks != nil){
                    
                    var auxDrinks: NSArray = drinks!
                    var objects = DrinkManager()
                    var cups = CupManager()
                    var beer = BeerManager()
                    
                    var mlDrunk = Double()
                    var alcoholContent = Double()
                    var alcoholContentOnDrink = Double()
                    var etanol = Double()
                    var alcoholInBlood = Double()
                    var constant = 0.70
                    var i = NSInteger()
                    
                    for (i=0;i < auxDrinks.count; i++){
                        var drinkControl = DrinkManager(dictionary: auxDrinks[i] as! PFObject)
                        
                        mlDrunk = mlDrunk + Double(drinkControl.cup!.size!)
                        //println(mlDrunk)
                        alcoholContent = alcoholContent + (drinkControl.beer!.alcoholContent! as NSString).doubleValue
                        //println(alcoholContent)
                        
                        alcoholContentOnDrink = alcoholContentOnDrink + ((alcoholContent * mlDrunk) / 100)
                    }
                    
                    etanol = 0.8 * alcoholContentOnDrink
                    var weight = NSString(string: userControl.weight!)
                    alcoholInBlood = etanol / ((weight as NSString).doubleValue * constant)
                    
                    var type = Int()
                    if(alcoholInBlood == 0){
                        type = 1
                    } else if (alcoholInBlood <= 1){
                        type = 2
                    } else if (alcoholInBlood <= 2){
                        type = 3
                    } else if (alcoholInBlood <= 3){
                        type = 4
                    } else {
                        type = 4
                    }
                    
                    callback(alcoholInBlood: alcoholInBlood, type: type, error: nil)
                }
                
            } else {
                callback(alcoholInBlood: nil, type: nil, error: error)
            }
        })
        
    }
}
