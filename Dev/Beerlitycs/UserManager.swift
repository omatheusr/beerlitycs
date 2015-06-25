//
//  UserManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 23/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class UserManager: NSObject {
    var objectId: String!
    var name: String!
    var email: String!
    var password: String!
    var birth: String!
    var height: String!
    var weight: String!
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }

    init(dictionary : PFObject) {
        super.init()
        
        self.objectId = dictionary["objectId"] as! String
        self.name = dictionary["name"] as! String
        self.email = dictionary["email"] as! String
        self.birth = dictionary["birth"] as! String
        self.height = dictionary["height"] as! String
        self.weight = dictionary["weight"] as! String
    }

    func newUser(userControl: UserManager, callback: (error: NSError?) -> ()) {
        var query = PFUser()
        
        query["name"]? = userControl.name
        query["email"]? = userControl.email
        query["birth"]? = userControl.birth
        query["height"]? = userControl.height
        query["weight"]? = userControl.weight
        
        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }

    func login(userControl: UserManager, callback: (error: NSError?) -> ()) {
        PFUser.logInWithUsernameInBackground(userControl.email, password:userControl.password) {
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
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else if let query = gameScore {
                query["name"]? = userControl.name
                query["email"]? = userControl.email
                query["birth"]? = userControl.birth
                query["height"]? = userControl.height
                query["weight"]? = userControl.weight
                
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
}
