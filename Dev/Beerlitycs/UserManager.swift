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
    var username: String?
    var email: String?
    var password: String!
    var birth: NSDate?
    var height: String?
    var weight: String?
    var sex: Bool?
    var facebookId: String?
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    var photo: PFFile?
    var mlDrunk: NSInteger?
    
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

        if((dictionary["weight"]) != nil) {
            self.weight = dictionary["weight"] as? String
        } else {
            self.weight = "0"
        }

        if((dictionary["sex"]) != nil) {
            self.sex = dictionary["sex"] as? Bool
        } else {
            self.sex = true
        }

        self.facebookId = dictionary["facebookId"] as? String
        self.photo = dictionary["photo"] as? PFFile

        if((dictionary["mlDrunk"]) != nil) {
            self.mlDrunk = dictionary["mlDrunk"] as? NSInteger
        } else {
            self.mlDrunk = 0
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

        if userControl.sex != nil{
            query["sex"] = userControl.sex
        }

        if userControl.photo != nil{
            query["photo"] = userControl.photo
        }

        query["mlDrunk"] = 0
    
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
                    
                    if userControl.name != nil{
                        query["name"] = userControl.name
                    }

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
                    
                    if userControl.sex != nil{
                        query["sex"] = userControl.sex
                    }

                    if userControl.facebookId != nil{
                        query["facebookId"] = userControl.facebookId
                    }

                    if userControl.photo != nil{
                        query["photo"] = userControl.photo
                    }
                    
                    if userControl.mlDrunk == nil {
                        query["mlDrunk"] = 0
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

    func getUserById(userId: String!, callback: (user: UserManager?, error: NSError?) -> ()) {
        var query = PFUser.query()!
        
        query.whereKey("objectId", equalTo: userId)

        var auxUsers: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxUsers = objects!
                
                let uControl = UserManager(dictionary: PFUser(withoutDataWithObjectId: userId))
                    callback(user: uControl, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(user: nil, error: error!)
            }
        }
    }

    func returnUserData(user: PFUser, linked: Bool, callback: (error: NSError?) -> ()) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if (error != nil) {
                callback(error: error)
            }
            else {
                var currentUser = UserManager()

                let userID: String! = result.valueForKey("id") as! String
                currentUser.objectId = user.objectId

                if(linked == false) {
                    if let userName = result.valueForKey("name") as? NSString {
                        currentUser.name = userName as String
                    }
                    if let userEmail = result.valueForKey("email") as? NSString {
                        currentUser.email = userEmail as String
                    }
                    
                    if(userID != nil) {
                        currentUser.facebookId = userID

                        let swiftString: String! = "http://graph.facebook.com/\(userID!)/picture?type=large"
                        
                        let url = NSURL(string: swiftString)
                        let data = NSData(contentsOfURL: url!)
                        
                        let image: UIImage = UIImage(data: data!)!
                        var jpegImage = UIImageJPEGRepresentation(image, 1.0)
                        let file = PFFile(name:currentUser.objectId + ".jpg" , data: jpegImage)

                        currentUser.photo = file
                    }
                } else {
                    currentUser.facebookId = userID
                }

                currentUser.editUser(currentUser, callback: { (error) -> () in
                    if (error == nil) {
                        println(currentUser.facebookId!)
                        callback(error: nil)
                    }
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
    // Get Fav Place Per User
    //----------------------------------------------------------------------------------------------
    
    func getFavPlace (userID: String, callback: (numPlace: NSInteger?, placeName: String?, error: NSError?) -> ()) {
        
        var query = PFQuery(className: "Drink")
        var place = Int()
        var places = NSInteger()
        var plcName = String()
        var auxPlace = [String]()
        var auxDrinks = []
        var auxMajor = [String: Int]()
        
        mlDrunk = 0
        
        query.includeKey("place")
        query.includeKey("beer")
        query.includeKey("cup")
        query.includeKey("user")

        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxDrinks = objects!
                
                var i : Int
                for(i = 0; i < auxDrinks.count; i++) {
                    let drink = DrinkManager(dictionary: auxDrinks[i] as! PFObject)
                    auxPlace.insert(drink.place!.name, atIndex: i)
                }
                
                var outArray = sorted(auxPlace)
                
                for(i = 0; i < outArray.count; i++) {
        
                    if(plcName != outArray[i]){
                        places++
                        place++
                    }else{
                        place = 0
                    }
                    plcName = outArray[i]
                }
                
                println(auxMajor)
                println(outArray)
                
                callback(numPlace: places, placeName: plcName, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(numPlace: nil, placeName: nil, error: error!)
            }
        }
        
    }

    
    //----------------------------------------------------------------------------------------------
    // Get Fav Beer Drunk Per User
    //----------------------------------------------------------------------------------------------
    
    func getFavBeer (userID: String, callback: (majName: String, majSize: Int, minName: String, minSize: Int, error: NSError?) -> ()) {
        
        var query = PFQuery(className: "Drink")
        var query2 = PFQuery(className: "Drink")
        var mlDrunk = NSInteger()
        var auxBeer = []
        var auxDrinks = []
        var beerList = [String]()
        var beerQty = [Int]()
        var majorName : String = ""
        var minorName : String = ""
        var majorSize : Int = 0
        var minorSize : Int = 10000000
        var beerRanking : [String : Int]
        
        mlDrunk = 0
        
        query.includeKey("beer")
        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxBeer = objects!
                
                var i : Int
                var ii : Int = 0
                var aux : String = ""
                
                
                for(i = 0; i < auxBeer.count-1; i++) {
                    let drink = DrinkManager(dictionary: auxBeer[i] as! PFObject)

                    if(aux == drink.beer!.name){
                        
                    }else{
                        beerList.insert(drink.beer!.name, atIndex: ii)
                        aux = drink.beer!.name
                        ii++
                    }
                    
                }
                
                query2.includeKey("cup")
                query2.includeKey("beer")
                query2.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))
                query2.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        auxDrinks = objects!
                        
                        var i : Int
                        var ii : Int
                        var aux : Int = 0
                        var auxName : String = ""
                        
                        for(ii = 0; ii < beerList.count; ii++) {
                            for(i = 0; i < auxDrinks.count; i++) {
                                let drink = DrinkManager(dictionary: auxDrinks[i] as! PFObject)
                                
                                //beerQty.insert(drink.cup!.size, atIndex: i)
                                
                                if(beerList[ii] == drink.beer!.name){
                                    aux += drink.cup!.size
                                    auxName = drink.beer!.name
                                }
                            }
                            
                            if(majorSize < aux){
                                majorName = auxName
                                majorSize = aux
                            }
                            
                            if(minorSize >= aux){
                                minorName = auxName
                                minorSize = aux
                            }
                            
                            beerQty.insert(aux, atIndex: ii)
                            aux = 0;
                        }
                        
//                        println(beerList)
//                        println(beerQty)
//                        println(majorName)
//                        println(majorSize)
//                        println(minorName)
//                        println(minorSize)
                        
                        callback(majName: majorName, majSize: majorSize, minName: minorName, minSize: minorSize, error: nil)
                        
                    } else {
                        
                        println("Error: \(error) \(error!.userInfo!)")
                    }
                    
                    
                }
            
            } else {
                println("Error: \(error) \(error!.userInfo!)")
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
                    
                    var mililiters: NSInteger = query["mlDrunk"] as! NSInteger
                    //var mililiters: Int = name.toInt()!
                    
                    mililiters = mililiters + mlDrunk
                
                    query["mlDrunk"] = mililiters
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
    
    //Função de ordenação de array
    func backward(x : String, y: String) -> Bool
    {
        return x>y
    }
}
