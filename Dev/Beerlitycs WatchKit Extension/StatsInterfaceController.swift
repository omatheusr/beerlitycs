//
//  StatsInterfaceController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 02/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import WatchKit
import Foundation


class StatsInterfaceController: WKInterfaceController {
    var stats = ["a", "b"]
//    let statsHelper = CoinHelper()

    @IBOutlet weak var statsTable: WKInterfaceTable!
    @IBOutlet weak var statusText: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        reloadTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func reloadTable() {
        // 1
        
        statsTable.setNumberOfRows(stats.count, withRowType: "StatsCell")
        
        for(var i = 0; i < stats.count; i++) {
            // 2
            let row = statsTable.rowControllerAtIndex(i) as! StatsCell
            
            
            row.statsOption.setText("a")
                // 3
//                row.titleLabel.setText(coin.name)
//                row.detailLabel.setText("\(coin.price)")
        }
    }
}
