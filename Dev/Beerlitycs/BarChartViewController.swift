//
//  BarChartViewController.swift
//  Beerlitycs
//
//  Created by Rafael Costa da Silva on 30/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Charts
import Parse

class BarChartViewController: UITableViewController, ChartViewDelegate {
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var btnSelect: UISegmentedControl!

    var maName: String!
    var maSize: String!
    var miName: String!
    var miSize: String!
    var nPlace: String!
    var pName: String!
    var months: [String]!

    @IBOutlet weak var favBeer: UILabel!
    @IBOutlet weak var lessConsumedBeer: UILabel!
    @IBOutlet weak var mlDrunk: UILabel!
    @IBOutlet weak var favPlace: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.barChartView.delegate = self
        
        self.barChartView.noDataText = "Sem dados para mostrar."
        
        self.barChartView.backgroundColor = UIColor(red: 24/255, green: 27/255, blue: 34/255, alpha: 1)
        self.barChartView.pinchZoomEnabled = false
        self.barChartView.drawBarShadowEnabled = false
        self.barChartView.drawGridBackgroundEnabled = false
        self.barChartView.highlightEnabled = false

        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "loadData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.beginRefreshing()

        self.loadData(nil)
        self.loadUserPreferenceData()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            dataEntries.append(BarChartDataEntry(value: values[i], xIndex: i))
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.descriptionText = ""
        
        chartDataSet.colors = [UIColor(red: 225/255, green: 110/255, blue: 55/255, alpha: 1)]
        //chartDataSet.colors = ChartColorTemplates.colorful()

        barChartView.xAxis.labelPosition = .Bottom
        
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelTextColor = UIColor(red: 229/255, green: 110/255, blue: 55/255, alpha: 1)
        
        barChartView.drawValueAboveBarEnabled = false
        barChartView.data?.setValueTextColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
        barChartView.data?.setDrawValues(false)
        
        barChartView.legend.enabled = false
        //        barChartView.legend.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        barChartView.gridBackgroundColor = UIColor(red: 24/255, green: 27/255, blue: 34/255, alpha: 1)

        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .Linear)
    }

    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        println("\(entry.value) in \(months[entry.xIndex])")
    }

    @IBAction func saveChart(sender: UIBarButtonItem) {
        barChartView.saveToCameraRoll()
    }

    @IBAction func actSelect(sender: AnyObject) {
        showDataForSegment(self.btnSelect.selectedSegmentIndex)
    }

    func loadData(sender:AnyObject?) {
        self.showDataForSegment(self.btnSelect.selectedSegmentIndex)
    }

    func showDataForSegment(segment: Int){
        let graphControl = DrinkManager()
        switch(segment)
        {
        case 0:
            graphControl.getDrinksForDate(NSDate(), user: PFUser.currentUser()!, daysInRange: 6, callback: { (beerPoints, datePoints, error) -> () in
                
                if let error = error {
                    // Error treatment
                } else {
                    if let datePoints = datePoints {
                        self.months = datePoints

                        if let beerPoints = beerPoints {
                            self.setChart(self.months, values: beerPoints)
                        }
                    }
                }
            })
            
        case 1:
            graphControl.getDrinksForDate(NSDate(), user: PFUser.currentUser()!, daysInRange: 29, callback: { (beerPoints, datePoints, error) -> () in
                
                if let error = error {
                    // Error treatment
                } else {
                    if let datePoints = datePoints {
                        self.months = datePoints
                        
                        if let beerPoints = beerPoints {
                            self.setChart(self.months, values: beerPoints)
                        }
                    }
                }
            })
        case 2:
            graphControl.getDrinksForMonthWithDate(NSDate(), user: PFUser.currentUser()!, monthsInRange: 12, callback: { (beerPoints, datePoints, error) -> () in
                if let error = error {
                    // Error treatment
                } else {
                    if let datePoints = datePoints {
                        self.months = datePoints

                        if let beerPoints = beerPoints {
                            self.setChart(self.months, values: beerPoints)
                        }
                    }
                }
            })
        default:
            showDataForSegment(0)
            break;
        }
        self.refreshControl?.endRefreshing()
    }
    func loadUserPreferenceData() {
        
        let userControl = UserManager(dictionary: PFUser.currentUser()!)
        self.mlDrunk.text = String(stringInterpolationSegment: userControl.mlDrunk!) + " ml"
        
        let cupsControl = UserManager ()
        cupsControl.getFavBeer(userControl.objectId, callback: { (majorName, majorSize, minorName, minorSize, error) -> () in
            if(error == nil) {
                if majorName == "" {
                    self.maName = "Nenhuma"
                }else{
                    self.maName = majorName
                }
                self.favBeer.text = self.maName
                
                self.maSize = String(stringInterpolationSegment: majorSize) + " ml"

                if minorName == "" {
                    self.miName = "Nenhuma"
                } else {
                    self.miName = minorName
                }
                self.lessConsumedBeer.text = self.miName
                
                self.miSize = String(stringInterpolationSegment: minorSize) + " ml"
            } else {
                println("erro")
            }
        })
        
        cupsControl.getFavPlace(userControl.objectId) { (numPlace, placeName, error) -> () in
            if(error == nil) {
                self.nPlace = String(stringInterpolationSegment: numPlace!)
                
                if placeName! == "" {
                    self.pName = "Nenhum"
                } else {
                    self.pName = placeName!
                }
                self.favPlace.text = self.pName
                
            } else {
                println("erro")
            }
        }
        
    }
}

