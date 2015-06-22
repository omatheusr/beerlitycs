//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class BeerManager: NSObject {
    var objectId: String!
    var name: String!
    var alcoholContent: String!
    var createdAt: NSDate!
    var date: String!
    var hour: String!
    
    override init() {
        super.init()
    }
    
    init(dictionary : PFObject) {
        super.init()

        self.name = dictionary["name"] as! String
        self.alcoholContent = dictionary["alcoholContent"] as! String
        
        self.date = formatDate(dictionary["localDate"] as! NSDate, format: "dd/MM/yyyy")
        self.hour = formatDate(dictionary["localDate"] as! NSDate, format: "HH:mm")
    }
    
    func newBeer(beerControl: BeerManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className:"Cup")

        query["name"] = beerControl.name
        query["alcoholcontent"] = beerControl.alcoholContent
        query["localDate"] = NSDate()

        //                query.saveInBackgroundWithBlock { Salvar no Servidor
        query.pinInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
    
    func getBeers(callback: (allBeers: NSArray?, error: NSError?) -> ()) {
        var query = PFQuery(className:"Beer")
        query.fromLocalDatastore()
        
        var auxBeers: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxBeers = objects!
                callback(allBeers: auxBeers, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allBeers: nil, error: error!)
            }
        }
    }
    
    func getBeersForGraph(callback: (beerPoints: [Int]?, error: NSError?) ->()) {
        let cal = NSCalendar.currentCalendar()
        var date = cal.startOfDayForDate(NSDate())
        
        var days = [Int]()
        var dateweek = cal.dateByAddingUnit(.CalendarUnitDay, value: -6, toDate: date, options: nil)!
        
        var query = PFQuery(className:"Beer")
        query.fromLocalDatastore()

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