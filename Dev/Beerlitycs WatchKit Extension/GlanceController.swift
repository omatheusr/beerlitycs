//
//  GlanceController.swift
//  Beerlitycs WatchKit Extension
//
//  Created by Matheus Frozzi Alberton on 02/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import WatchKit
import Foundation

class GlanceController: WKInterfaceController {
    
    var myPosition : String!

    @IBOutlet weak var rankingPosition: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var request = ["request": "getRankingPosition"]
        
        WKInterfaceController.openParentApplication(request, reply: { (replyFromParent, error) -> Void in
            if(error != nil) {
                println("there was an error receiving a reply")
                self.rankingPosition.setText("Faça login com o facebook para ter acesso ao ranking")
            } else {
                self.myPosition = replyFromParent["reply"]! as! String

                self.rankingPosition.setText(self.myPosition! + "º")
            }
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
