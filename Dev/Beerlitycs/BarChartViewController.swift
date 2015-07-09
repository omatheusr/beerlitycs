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

        barChartView.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "loadData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.beginRefreshing()

        loadData(nil)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
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
        
        barChartView.drawValueAboveBarEnabled = true
        barChartView.data?.setValueTextColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
        barChartView.data?.setDrawValues(false)
        
        barChartView.legend.enabled = false
//        barChartView.legend.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        barChartView.backgroundColor = UIColor(red: 32/255, green: 36/255, blue: 45/255, alpha: 1)
        barChartView.gridBackgroundColor = UIColor(red: 32/255, green: 36/255, blue: 45/255, alpha: 1)
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .Linear)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        println("\(entry.value) in \(months[entry.xIndex])")
    }
    
    @IBAction func saveChart(sender: UIBarButtonItem) {
        barChartView.saveToCameraRoll()
    }

    @IBAction func actSelect(sender: AnyObject) {
        if(btnSelect.selectedSegmentIndex == 0){
            let graphControl = DrinkManager()
            graphControl.getDrinksForGraph(6, dayPoints: true) { (beerPoints, datePoints, error) -> () in
                if(error == nil) {
                    self.months = datePoints!
                    let unitsSold = beerPoints!
                    self.setChart(self.months, values: unitsSold)
                } else {
                    
                }
            }
        }else if(btnSelect.selectedSegmentIndex == 1){
            let graphControl = DrinkManager()
            
            graphControl.getDrinksForGraph(29, dayPoints: true) { (beerPoints, datePoints, error) -> () in
                if(error == nil) {
                    self.months = datePoints!
                    let unitsSold = beerPoints!
                    self.setChart(self.months, values: unitsSold)
                } else {
                    
                }
            }
            
            
        }else if(btnSelect.selectedSegmentIndex == 2){
            let graphControl = DrinkManager()
            
            graphControl.getDrinksForGraph(59, dayPoints: true) { (beerPoints, datePoints, error) -> () in
                if(error == nil) {
                    self.months = datePoints!
                    let unitsSold = beerPoints!
                    self.setChart(self.months, values: unitsSold)
                } else {
                    
                }
            }
        }
    }
    
    func loadData(sender:AnyObject?) {
        let graphControl = DrinkManager()

        graphControl.getDrinksForGraph(6, dayPoints: true) { (beerPoints, datePoints, error) -> () in
            if(error == nil) {
                self.months = datePoints!
                let unitsSold = beerPoints!
                self.setChart(self.months, values: unitsSold)
                
                self.refreshControl!.endRefreshing()
            } else {
                
            }
        }
        
        let userControl = UserManager(dictionary: PFUser.currentUser()!)
        self.mlDrunk.text = String(stringInterpolationSegment: userControl.mlDrunk!) + " ml"
        
        let cupsControl = UserManager ()
        cupsControl.getFavBeer(userControl.objectId, callback: { (majorName, majorSize, minorName, minorSize, error) -> () in
            if(error == nil) {
                self.maName = majorName
                self.favBeer.text = majorName
                self.maSize = String(stringInterpolationSegment: majorSize) + " ml"
                self.miName = minorName
                self.lessConsumedBeer.text = self.miName
                
                self.miSize = String(stringInterpolationSegment: minorSize) + " ml"
            } else {
                println("erro")
            }
        })
        
        cupsControl.getFavPlace(userControl.objectId) { (numPlace, placeName, error) -> () in
            if(error == nil) {
                self.nPlace = String(stringInterpolationSegment: numPlace!)
                self.pName = placeName!
                self.favPlace.text = self.pName
                
            } else {
                println("erro")
            }
        }
    }
}

