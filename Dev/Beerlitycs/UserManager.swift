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
    var email: String!
    var password: String!
    var birth: NSDate?
    var height: String?
    var weight: String?
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    var photo: PFFile?
    
    override init() {
        super.init()
    }

    init(dictionary : PFUser) {
        super.init()
        
        self.objectId = dictionary.objectId
        self.name = dictionary["name"] as! String
        self.username = dictionary.username
        self.email = dictionary["email"] as! String
        self.birth = dictionary["birth"] as? NSDate
        self.height = dictionary["height"] as? String
        self.weight = dictionary["weight"] as? String
        self.photo = dictionary["photo"] as? PFFile
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
        
        query.signUpInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
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
                    query["email"] = userControl.email
                    
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
                let userID: NSString = result.valueForKey("id") as! NSString
                let userName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                
                var currentUser = UserManager()
                currentUser.objectId = user.objectId
                currentUser.name = userName as String
                currentUser.email = userEmail as String
                
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
}
