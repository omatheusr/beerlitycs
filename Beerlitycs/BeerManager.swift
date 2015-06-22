//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class BeerManager: NSObject {
    var objectId: String!
    var user: PFUser!
    var location: PFGeoPoint!
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()
        
        //        self.date = formatDate(dictionary.createdAt!, format: "dd/MM/yyyy")
        //        self.hour = formatDate(dictionary.createdAt!, format: "HH:mm")
        self.location = dictionary["location"] as! PFGeoPoint
        
        self.date = formatDate(dictionary["localDate"] as! NSDate, format: "dd/MM/yyyy")
        self.hour = formatDate(dictionary["localDate"] as! NSDate, format: "HH:mm")
    }
    
    func newPoop(userID: String, callback: (error: NSError?) -> ()) {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                var nPoop = PFObject(className:"Poop")
                //                nPoop["user"] = PFUser.objectWithoutDataWithObjectId(userID)
                nPoop["location"] = geoPoint
                nPoop["localDate"] = NSDate()
                
                
                nPoop.pinInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        callback(error: nil)
                    } else {
                        callback(error: error)
                    }
                }
                //
                //                nPoop.saveInBackgroundWithBlock {
                //                    (success: Bool, error: NSError?) -> Void in
                //                    if (success) {
                //                        callback(error: nil)
                //                    } else {
                //                        callback(error: error)
                //                    }
                //                }
            } else {
                println("no geopoint");
            }
        }
    }
    
    func getPoops(userID: String, callback: (poopResult: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Poop")
        var saveQuery = PFObject(className:"Poop")
        //        saveQuery.un
        query.fromLocalDatastore()
        
        //        query.whereKey("user", equalTo:PFUser.objectWithoutDataWithObjectId(userID))
        
        var poopResultar: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                poopResultar = objects!
                callback(poopResult: poopResultar, error: nil)
                //                println(objects!)
                //                PFObject.pinAllInBackground(objects)
                //                saveQuery.saveEventually()
            } else {
                // Log details of the failure
                println("Error: \(error) \(error!.userInfo!)")
                callback(poopResult: nil, error: error!)
            }
        }
    }
    
    func getPoopsForGraph(userID: String, callback: (poopPoints: [Int]?, error: NSError?) ->()) {
        let cal = NSCalendar.currentCalendar()
        var date = cal.startOfDayForDate(NSDate())
        
        var days = [Int]()
        var dateweek = cal.dateByAddingUnit(.CalendarUnitDay, value: -6, toDate: date, options: nil)!
        
        var query = PFQuery(className:"Poop")
        query.fromLocalDatastore()
        
        //        query.whereKey("user", equalTo:PFUser.objectWithoutDataWithObjectId(userID))
        query.whereKey("localDate", greaterThan: dateweek)
        
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
                
                callback(poopPoints: graphPoints.reverse(), error: nil)
            } else {
                // Log details of the failure
                println("Error: \(error) \(error!.userInfo!)")
                callback(poopPoints: nil, error: error!)
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