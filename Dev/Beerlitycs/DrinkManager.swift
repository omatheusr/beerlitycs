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
    var user: UserManager!
    var place: PlaceManager!
    var beer: BeerManager!
    var cup: CupManager!
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()
        
        self.user = dictionary["user"] as! UserManager
        self.place = dictionary["place"] as! PlaceManager
        self.beer = dictionary["beer"] as! BeerManager
        self.cup = dictionary["cup"] as! CupManager

        self.date = formatDate(dictionary.createdAt!, format: "dd/MM/yyyy")
        self.hour = formatDate(dictionary.createdAt!, format: "HH:mm")
    }
    
    func newDrink(drinkControl: DrinkManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Drink")
        
        query["user"] = drinkControl.user
        query["place"] = drinkControl.place
        query["beer"] = drinkControl.beer
        query["cup"] = drinkControl.cup
        
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

    func getDrinksForGraph(callback: (beerPoints: [Int]?, error: NSError?) ->()) {
        let cal = NSCalendar.currentCalendar()
        var date = cal.startOfDayForDate(NSDate())
        
        var days = [Int]()
        var dateweek = cal.dateByAddingUnit(.CalendarUnitDay, value: -6, toDate: date, options: nil)!
        
        var query = PFQuery(className:"Drink")
        
        query.whereKey("createdAt", greaterThan: dateweek)

        var graphPoints:[Int] = []

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                for i in 0...6 {
                    let day = cal.component(.CalendarUnitDay, fromDate: date)
                    days.append(day)
                    
                    date = cal.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: date, options: nil)!
                    var teste = false
                    var aux = 0
                    
                    if(objects!.count != 0) {
                        for j in 0...objects!.count-1 {
                            //                        let day2 = cal.component(.CalendarUnitDay, fromDate: objects![j].createdAt)
                            let day2 = cal.component(.CalendarUnitDay, fromDate: objects![j]["localDate"] as! NSDate)
                            
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
                        
                        graphPoints.insert(aux, atIndex: i)
                    }
                }
                
                callback(beerPoints: graphPoints.reverse(), error: nil)
            } else {
                // Log details of the failure
                println("Error: \(error) \(error!.userInfo!)")
                callback(beerPoints: nil, error: error!)
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
