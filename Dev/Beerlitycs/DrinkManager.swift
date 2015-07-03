//
//  DrinkManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 25/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class DrinkManager: NSObject {
    var objectId: String!
    var user: UserManager?
    var place: PlaceManager?
    var beer: BeerManager?
    var cup: CupManager?
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()

        self.user = UserManager(dictionary: dictionary["user"] as! PFUser)
        
        if(dictionary["place"] != nil) {
            self.place = PlaceManager(dictionary: dictionary["place"] as! PFObject)
        }

        if(dictionary["beer"] != nil) {
            self.beer = BeerManager(dictionary: dictionary["beer"] as! PFObject)
        }

        if(dictionary["cup"] != nil) {
            self.cup = CupManager(dictionary: dictionary["cup"] as! PFObject)
        }

        self.date = formatDate(dictionary.createdAt!, format: "dd/MM/yyyy")
        self.hour = formatDate(dictionary.createdAt!, format: "HH:mm")
    }
    
    func prepareForDrink(drinkControl: DrinkManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Drink")

        query["user"] = PFUser.currentUser()
        
        let placeControl = PlaceManager()
        placeControl.verifyPlace(drinkControl.place!.foursquareId, callback: { (exist, objIdV, error) -> () in
            if(error == nil) {
                if(exist != true) {
                    placeControl.newPlace(drinkControl.place!, callback: { (objId, error) -> () in // N Existe place criar um e pegar o ID
                        if(error == nil) {
                            drinkControl.place?.objectId = objId
                            
                            self.newDrink(drinkControl, callback: { (error) -> () in
                                if (error == nil) {
                                    callback(error: nil)
                                } else {
                                    callback(error: error)
                                }
                            })
                        } else {
                            callback(error: error)
                        }
                    })
                } else {
                    drinkControl.place?.objectId = objIdV
                    
                    self.newDrink(drinkControl, callback: { (error) -> () in
                        if (error == nil) {
                            callback(error: nil)
                        } else {
                            callback(error: error)
                        }
                    })
                }
            } else {
                println("Ocorreu um erro")
            }
        })
    }
    
    
    func newDrink(drinkControl: DrinkManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Drink")

        query["user"] = PFUser.currentUser()

        if(drinkControl.place?.objectId != nil) {
            query["place"] = PFObject(withoutDataWithClassName:"Place", objectId: drinkControl.place?.objectId)
        }
        if(drinkControl.beer?.objectId != nil) {
            query["beer"] = PFObject(withoutDataWithClassName:"Beer", objectId: drinkControl.beer?.objectId)
        }
        if(drinkControl.cup?.objectId != nil) {
            query["cup"] = PFObject(withoutDataWithClassName:"Cup", objectId: drinkControl.cup?.objectId)
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

    func getDrinks(callback: (allDrinks: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Drink")
        
        query.includeKey("user")
        query.includeKey("place")
        query.includeKey("beer")
        query.includeKey("cup")
        
        query.orderByDescending("createdAt")

        var auxDrinks: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxDrinks = objects!
                callback(allDrinks: auxDrinks, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allDrinks: nil, error: error!)
            }
        }
    }
    
    func getLatestDrinkPerUser(userID: String, callback:(drinks: NSArray?, error: NSError?) ->()){
        
        //let timeZone = NSTimeZone.localTimeZone().secondsFromGMT
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)

        //var value = -3 - timezone/3600
        var value = -3
        var newDate = calendar.dateByAddingUnit(.CalendarUnitHour, value: value, toDate: date, options: nil)
        
        var query = PFQuery(className: "Drink")
        
        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))
        query.whereKey("createdAt", greaterThan: newDate!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(error == nil){
                var drinks: NSArray! = objects!
                callback(drinks: objects, error: nil)
            } else {
                callback(drinks: nil, error: error)
            }
        }
    }
    
    
    func getDrinksForGraph(numberPoints: Int,  dayPoints: Bool, callback: (beerPoints: [Double]?, datePoints: [String]?, error: NSError?) ->()) {
        let cal = NSCalendar.currentCalendar()
        var date = cal.startOfDayForDate(NSDate())
        
        var days = [Int]()
        var dateweek = cal.dateByAddingUnit(.CalendarUnitDay, value: -numberPoints, toDate: date, options: nil)!
        
        var query = PFQuery(className:"Drink")
        
        query.whereKey("createdAt", greaterThan: dateweek)

        var graphPoints:[Double] = []
        var datePoints:[String] = []

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                for i in 0...numberPoints {
                    let day = cal.component(.CalendarUnitDay, fromDate: date)
                    if(dayPoints){
                        let day = cal.component(.CalendarUnitDay, fromDate: date)
                        days.append(day)
                    
                        date = cal.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: date, options: nil)!
                    }else if(dayPoints == false){
                        let day = cal.component(.CalendarUnitMonth, fromDate: date)
                        days.append(day)
                        
                        date = cal.dateByAddingUnit(.CalendarUnitMonth, value: -1, toDate: date, options: nil)!
                    }
                    var teste = false
                    var aux:Double = 0
                    
                    if(objects!.count != 0) {
                        for j in 0...objects!.count-1 {
                            //                        let day2 = cal.component(.CalendarUnitDay, fromDate: objects![j].createdAt)
                            let day2 = cal.component(.CalendarUnitDay, fromDate: objects![j].createdAt as NSDate)
                            if(dayPoints){
                                let day2 = cal.component(.CalendarUnitDay, fromDate: objects![j].createdAt as NSDate)
                            }else if(dayPoints == false){
                                let day2 = cal.component(.CalendarUnitMonth, fromDate: objects![j].createdAt as NSDate)
                            }
                            
                            
                            if(day == day2) {
                                aux = aux + 1
                                if(teste == true) {
                                    
                                } else {
                                    //                                println(day)
                                }
                                //                            println("1")
                                //                            graphPoints.insert(1, atIndex: i)
                                teste = true
                            } else {
                                if(teste == false) {
                                    teste = true
                                    //                                println(day)
                                } else {
                                }
                            }
                        }
                        datePoints.insert(String(day), atIndex: i)
                        graphPoints.insert(aux, atIndex: i)
                    }
                }
                
                callback(beerPoints: graphPoints.reverse(), datePoints: datePoints.reverse(), error: nil)
            } else {
                // Log details of the failure
                println("Error: \(error) \(error!.userInfo!)")
                callback(beerPoints: nil, datePoints:nil, error: error!)
            }
        }
    }

    func formatDate(date: NSDate, format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        
        let myString = dateFormatter.stringFromDate(date)
        
        return myString;
    }
}
