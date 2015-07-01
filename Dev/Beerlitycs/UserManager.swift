//
//  UserManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 23/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class UserManager: NSObject {
    var objectId: String!
    var name: String!
    var username: String?
    var email: String?
    var password: String!
    var birth: NSDate?
    var height: String?
    var weight: String?
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    var photo: PFFile?
    var mlDrunk: String?
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFUser) {
        super.init()
    
        self.objectId = dictionary.objectId
        self.name = dictionary["name"] as! String
        self.username = dictionary.username
        self.email = dictionary["email"] as? String
        self.birth = dictionary["birth"] as? NSDate
        self.height = dictionary["height"] as? String
        self.weight = dictionary["weight"] as? String
        self.photo = dictionary["photo"] as? PFFile
        
        if((dictionary["mlDrunk"]) != nil) {
            self.mlDrunk = dictionary["mlDrunk"] as? String
        } else {
            self.mlDrunk = "0" 
        }
    }

    func newUser(userControl: UserManager, callback: (error: NSError?) -> ()) {
        var query = PFUser()
        
        query["name"] = userControl.name
        query["email"] = userControl.email
        query.password = userControl.password

        if userControl.username != nil{
            query.username = userControl.username
        }

        if userControl.birth != nil{
            query["birth"] = userControl.birth
        }

        if userControl.height != nil{
            query["height"] = userControl.height
        }
        
        if userControl.weight != nil{
            query["weight"] = userControl.weight
        }
        
        if userControl.photo != nil{
            query["photo"] = userControl.photo
        }
        
        query["mlDrunk"] = "0"
    
        query.signUpInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                PushNotifications.associateDeviceWithCurrentUser()
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }

    func login(userControl: UserManager, callback: (error: NSError?) -> ()) {
        PFUser.logInWithUsernameInBackground(userControl.username!, password:userControl.password) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                callback(error: nil)
            } else {
               callback(error: error)
            }
        }
    }

    func editUser(userControl: UserManager, callback: (error: NSError?) -> ()) {
        var query = PFUser.query()!
        
        query.getObjectInBackgroundWithId(userControl.objectId) {
            (userObject, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else if let userObject = userObject {
                if let query = userObject as? PFUser {
                    query["name"] = userControl.name
                    
                    if userControl.email != nil{
                        query["email"] = userControl.email
                    }
                    
                    if userControl.username != nil{
                        query.username = userControl.username
                    }

                    if userControl.birth != nil{
                        query["birth"] = userControl.birth
                    }
                    
                    if userControl.height != nil{
                        query["height"] = userControl.height
                    }
                    
                    if userControl.weight != nil{
                        query["weight"] = userControl.weight
                    }
                    
                    if userControl.photo != nil{
                        query["photo"] = userControl.photo
                    }
                    
                    if userControl.mlDrunk != nil{
                        query["mlDrunk"] = userControl.mlDrunk
                    } else {
                        query["mlDrunk"] = "0"
                    }
                    
                    
                    query.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            callback(error: nil)
                        } else {
                            callback(error: error)
                        }
                    }
                }

            }
        }
    }

    func getUsers(callback: (users: NSArray?, error: NSError?) -> ()) {
        var query = PFUser.query()!

        var auxUsers: NSArray!

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxUsers = objects!
                callback(users: auxUsers, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(users: nil, error: error!)
            }
        }
    }
    
    func returnUserData(user: PFUser, callback: (error: NSError?) -> ()) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if (error != nil) {
                callback(error: error)
            }
            else {
                var currentUser = UserManager()

                let userID: NSString = result.valueForKey("id") as! NSString
                let userName : NSString = result.valueForKey("name") as! NSString
                if let userEmail = result.valueForKey("email") as? NSString {
                    currentUser.email = userEmail as String
                }
                
                currentUser.objectId = user.objectId
                currentUser.name = userName as String

                // Get users image from facebook ans save on parse
                let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")!
                let urlRequest = NSURLRequest(URL: url)
                
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                    let image = UIImage(data: data)
                    
                    var jpegImage = UIImageJPEGRepresentation(image, 1.0)
                    let file = PFFile(name:currentUser.objectId + ".jpg" , data: jpegImage)
                    currentUser.photo = file

                    currentUser.editUser(currentUser, callback: { (error) -> () in
                        if (error == nil) {
                            callback(error: nil)
                        }
                    })
                })
            }
        })
    }
    
    func getMutualFriends(user: PFUser, callback: (friends: NSArray?, error: NSError?) -> ()) {
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

                var friendQuery = PFUser.query()!
                
                friendQuery.whereKey("facebookId", containedIn: fbID as [AnyObject])
                friendQuery.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        auxUsers = objects!
                        callback(friends: auxUsers, error: nil)
                    } else {
                        callback(friends: nil, error: error)
                    }
                }
            } else {
                callback(friends: nil, error: error)
            }
        }
    }
    
    
    //----------------------------------------------------------------------------------------------
    // Get mutual friends and sort by ML Drunk
    //----------------------------------------------------------------------------------------------
    
    func getMutualFriendsDescendingByMLDrunk(user: PFUser, callback: (friends: NSArray?, error: NSError?) -> ()) {
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
                userQuery.whereKey("objectId", equalTo: user.objectId!)
                
                var friendQuery = PFUser.query()!
                friendQuery.whereKey("facebookId", containedIn: fbID as [AnyObject])
                //friendQuery.orderByDescending("mlDrunk")
                
                var subQuery = PFQuery.orQueryWithSubqueries([userQuery, friendQuery])
                subQuery.orderByDescending("mlDrunk")
                
                subQuery.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        auxUsers = objects!
                        callback(friends: auxUsers, error: nil)
                    } else {
                        callback(friends: nil, error: error)
                    }
                }
            } else {
                callback(friends: nil, error: error)
            }
        }
    }

    
    
    //----------------------------------------------------------------------------------------------
    // Get Cups Drunk Per User
    //----------------------------------------------------------------------------------------------
    
    func getCupsDrunk (userID: String, callback: (cups: NSInteger?, error: NSError?) -> ()) {
    
        var query = PFQuery(className: "Drink")
        var mlDrunk = NSInteger()
        var auxDrinks = []
        
        mlDrunk = 0
    
        query.includeKey("cup")
        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))


        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxDrinks = objects!
    
                var i : Int
                for(i = 0; i < auxDrinks.count; i++) {
                    let drink = DrinkManager(dictionary: auxDrinks[i] as! PFObject)
                    
                    if let mililiters = drink.cup?.size {
                        mlDrunk = mlDrunk + mililiters
                    }
                }
                
                callback(cups: mlDrunk, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(cups: nil, error: error!)
            }
        }
        
    }
    
    //----------------------------------------------------------------------------------------------
    // When a new beer is added on table "Drink", call this function to add on total beer drunk
    // This fuction can only be used for current user.
    //----------------------------------------------------------------------------------------------
    
    func addNewBeerInMLToTotal (userID: String, mlDrunk: NSInteger, callback: (error: NSError?) -> ()){
    
        var query = PFUser.query()!
        
        query.getObjectInBackgroundWithId(userID){
            (objects, error) -> Void in
            
            if error != nil {
                callback(error: error)
                
            } else{
                if let query = objects as? PFUser {
                    
                    var name: String = query["mlDrunk"] as! String
                    var mililiters: Int = name.toInt()!
                    
                    mililiters = mililiters + mlDrunk
                
                    query["mlDrunk"] = String(mililiters)
                    query.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            callback(error: nil)
                        } else {
                            callback(error: error)
                        }
                    }
                    callback(error: nil)
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
}
