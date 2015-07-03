//
//  InterfaceController.swift
//  Beerlitycs WatchKit Extension
//
//  Created by Matheus Frozzi Alberton on 02/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var statusImage: WKInterfaceImage!
    @IBOutlet weak var statusText: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        /*
        var request = ["request": "getStatus"]
        
        WKInterfaceController.openParentApplication(request, reply: { (replyFromParent, error) -> Void in
            if(error != nil) {
                println("there was an error receiving a reply")
            } else {
                let average : String = (replyFromParent["reply"] as? String)!
                println(average)
                self.statusImage.setImage(UIImage(named: "1"))
                self.statusText.setText("Ops parece que você está bebado")
            }
        })
*/
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
