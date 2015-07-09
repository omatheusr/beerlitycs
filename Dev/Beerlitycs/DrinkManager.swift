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
        
        self.createdAt = dictionary.createdAt
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
    
    func getDrinks(skip: Int, callback: (allDrinks: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Drink")
        
        query.includeKey("user")
        query.includeKey("place")
        query.includeKey("beer")
        query.includeKey("cup")
        
        query.orderByDescending("createdAt")
        query.limit = 10
        query.skip = skip
        
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
        
        query.includeKey("user")
        query.includeKey("cup")
        query.includeKey("beer")
        query.includeKey("place")
        
        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: userID))
        query.whereKey("createdAt", greaterThan: newDate!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(error == nil){
                var drinks: NSArray! = objects!
                callback(drinks: drinks, error: nil)
            } else {
                callback(drinks: nil, error: error)
            }
        }
    }
    
    func getDrinksForDate(date : NSDate, user: PFUser, daysInRange: Int, callback: (beerPoints: [Double]?, datePoints: [String]?, error: NSError?) -> ()){
        let calendar = NSCalendar.currentCalendar()
        
        // Set the start of the day (00:00:00)...
        var startDate = calendar.startOfDayForDate(date)
        // Set the day X (daysInRange) days before the startDate...
        let finishDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: -daysInRange, toDate: startDate, options: nil)!
        
        var queryDrink = PFQuery(className: "Drink")
        queryDrink.whereKey("createdAt", greaterThan: finishDate)
        queryDrink.whereKey("createdAt", lessThan: startDate)
        queryDrink.whereKey("user", equalTo: user)
        
        var graphPoints:[Double] = []
        var datePoints:[String] = []
        
        var days = [Int]()
        
        queryDrink.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let error = error
            {
                // Error
                callback(beerPoints: nil, datePoints:nil, error: error)
            }else{
                if let objects = objects
                {
                    if objects.count <= 0
                    {
                        // No objects found
                        callback(beerPoints: nil, datePoints:nil, error: error)
                    }else{
                        var aux : Double = 0
                        for i in 0...daysInRange
                        {
                            aux = 0
                            let day     = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: startDate)
                            let month   = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: startDate)
                            let year    = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: startDate)
                            days.append(day)
                            
                            startDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: -1, toDate: startDate, options: nil)!
                            
                            for drink in objects
                            {
                                if let drink = drink as? PFObject
                                {
                                    let drinkDay    = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: drink.createdAt!)
                                    let drinkMonth  = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: drink.createdAt!)
                                    let drinkYear   = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: drink.createdAt!)
                                    
                                    if (day == drinkDay && month == drinkMonth && year == drinkYear)
                                    {
                                        aux++
                                    }
                                }
                            }
                            
                            datePoints.insert(String(day), atIndex: i)
                            graphPoints.insert(aux, atIndex: i)
                        }
                        
                        callback(beerPoints: graphPoints.reverse(), datePoints: datePoints.reverse(), error: nil)
                    }
                }
                else{
                    // Objects nil
                    callback(beerPoints: nil, datePoints:nil, error: error)
                }
            }
        }
    }
    
    
    func getDrinksForMonthWithDate(date : NSDate, user: PFUser, monthsInRange: Int, callback: (beerPoints: [Double]?, datePoints: [String]?, error: NSError?) -> ()){
        let calendar = NSCalendar.currentCalendar()
        
        // Set the start of the day (00:00:00)...
        var startDate = calendar.startOfDayForDate(date)
        // Get the last day of the last month
        let componentStartDate = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth, fromDate: startDate)
        startDate = calendar.dateFromComponents(componentStartDate)!.dateByAddingTimeInterval(-1)
        

        
        // Set the day X (daysInRange) days before the startDate...
        var finishDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitMonth, value: -monthsInRange, toDate: startDate, options: nil)!
        // Get the first day of the month
        let componentStartDateFinish = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth, fromDate: startDate)
        finishDate = calendar.dateFromComponents(componentStartDateFinish)!
        
        var queryDrink = PFQuery(className: "Drink")
        queryDrink.whereKey("createdAt", greaterThan: finishDate)
        queryDrink.whereKey("createdAt", lessThan: startDate)
        queryDrink.whereKey("user", equalTo: user)
        
        var graphPoints:[Double] = []
        var datePoints:[String] = []
        
        var months = [Int]()
        
        queryDrink.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let error = error
            {
                // Error
                callback(beerPoints: nil, datePoints:nil, error: error)
            }else{
                if let objects = objects
                {
                    if objects.count <= 0
                    {
                        // No objects found
                        callback(beerPoints: nil, datePoints:nil, error: error)
                    }else{
                        var auxMonth : Double = 0
                        for i in 0...monthsInRange
                        {
                            let month   = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: startDate)
                            let year    = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: startDate)
                            months.append(month)
                            
                            startDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitMonth, value: -1, toDate: startDate, options: nil)!
                            
                            for drink in objects
                            {
                                if let drink = drink as? PFObject
                                {
                                    let drinkMonth  = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: drink.createdAt!)
                                    let drinkYear   = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: drink.createdAt!)
                                    
                                    if (month == drinkMonth && year == drinkYear)
                                    {
                                        auxMonth++
                                    }
                                }
                            }
                            datePoints.insert(String(month), atIndex: i)
                            graphPoints.insert(auxMonth, atIndex: i)
                        }
                        
                        callback(beerPoints: graphPoints.reverse(), datePoints: datePoints.reverse(), error: nil)
                    }
                }
                else{
                    // Objects nil
                    callback(beerPoints: nil, datePoints:nil, error: error)
                }
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
