//
//  BarChartViewController.swift
//  Beerlitycs
//
//  Created by Rafael Costa da Silva on 30/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Charts

class BarChartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var year: [String]!
    var month: [String]!
    var week: [String]!
    var months: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        barChartView.delegate = self
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(months, values: unitsSold)
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
        
        chartDataSet.colors = [UIColor(red: 157/255, green: 140/255, blue: 112/255, alpha: 1)]
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.labelPosition = .Bottom
        
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.drawValueAboveBarEnabled = false
        
        barChartView.legend.enabled = false
        
        
        barChartView.backgroundColor = UIColor(red: 55/255, green: 61/255, blue: 74/255, alpha: 1)
        barChartView.gridBackgroundColor = UIColor(red: 55/255, green: 61/255, blue: 74/255, alpha: 1)
        
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
            cell.lblNumber.text = "4"
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
}

