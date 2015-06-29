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
    var birth: NSDate!
    var height: String!
    var weight: String!
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
        self.email = dictionary["email"] as! String
        self.birth = dictionary["birth"] as! NSDate
        self.height = dictionary["height"] as! String
        self.weight = dictionary["weight"] as! String
        self.photo = dictionary["photo"] as? PFFile
    }

    func newUser(userControl: UserManager, callback: (error: NSError?) -> ()) {
        var query = PFUser()
        
        query["name"]? = userControl.name
        query["email"]? = userControl.email
        query["birth"]? = userControl.birth
        query["height"]? = userControl.height
        query["weight"]? = userControl.weight
        
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
                
                query["name"] = userControl.name
                query["email"] = userControl.email
                
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
