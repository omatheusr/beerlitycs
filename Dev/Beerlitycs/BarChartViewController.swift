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

class BarChartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var btnSelect: UISegmentedControl!
    
    var year: [String]!
    var month: [String]!
    var week: [String]!
    var months: [String]!
    @IBOutlet weak var lblMl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        barChartView.delegate = self
        
        let graphControl = DrinkManager()
        
        graphControl.getDrinksForGraph(6, dayPoints: true) { (beerPoints, datePoints, error) -> () in
            if(error == nil) {
                self.months = datePoints!
                let unitsSold = beerPoints!
                self.setChart(self.months, values: unitsSold)
            } else {
                
            }
        }
        
        
        
        let userControl = UserManager(dictionary: PFUser.currentUser()!)
        let cupsControl = UserManager()
        var mlDrunk = NSInteger()
        mlDrunk = 0
        
        cupsControl.getCupsDrunk(userControl.objectId, callback: { (cups, error) -> () in
            if(error == nil) {
                mlDrunk = cups!
                self.lblMl.text = String(mlDrunk) + " ml"
            } else {
                println("erro")
            }
        })
        
        cupsControl.getFavBeer(userControl.objectId, callback: { (cups, error) -> () in
            if(error == nil) {
                mlDrunk = cups!
                self.lblMl.text = String(mlDrunk) + " ml"
            } else {
                println("erro")
            }
        })
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AnalyticsCell
        
        tableView.backgroundColor = UIColor.clearColor()
        
        if(indexPath.row == 0) {
            cell.lblName.text = "Mais bebida"
            cell.lblBeer.text = "Polar"
            cell.lblNumber.text = "1.300ml"
        }else if(indexPath.row == 1) {
            cell.lblName.text = "Menos bebida"
            cell.lblBeer.text = "Bohemia"
            cell.lblNumber.text = "345ml"
        }else if(indexPath.row == 2) {
            cell.lblName.text = "Novas adicionadas"
            cell.lblBeer.text = ""
            cell.lblNumber.text = "0"
        }else if(indexPath.row == 3) {
            cell.lblName.text = "Bares visitados"
            cell.lblBeer.text = ""
            cell.lblNumber.text = "97"
        }else if(indexPath.row == 4) {
            cell.lblName.text = "Bar preferido"
            cell.lblBeer.text = ""
            cell.lblNumber.text = "Ramblas"
        }

    
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
}

