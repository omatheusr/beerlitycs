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
    @IBOutlet weak var statusAlcoholBlood: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        var request = ["request": "getStatus"]
        
        WKInterfaceController.openParentApplication(request, reply: { (replyFromParent, error) -> Void in
            if(error != nil) {
                println("there was an error receiving a reply")
            } else {
                var type : String!
                if let id = replyFromParent["reply"]![1] as? String {
                    // If we get here, we know "id" exists in the dictionary, and we know that we
                    // got the type right.
                    type = id
                }
                
                self.statusAlcoholBlood.setText(replyFromParent["reply"]![0] as? String)

                if(type == "1") {
                    self.statusText.setText("Parábens! Você é o motorista da rodada")
                    self.statusImage.setImage(UIImage(named: "22"))
                } else if(type == "2"){
                    self.statusText.setText("OPA! Abrindo os trabalhos!")
                    self.statusImage.setImage(UIImage(named: "17"))
                } else if(type == "3"){
                    self.statusText.setText("BELEZA! Tudo está ficando lindo!")
                    self.statusImage.setImage(UIImage(named: "05"))
                } else {
                    self.statusText.setText("CUIDADO! Não vá fazer algo que se arrependa.. e chame um Taxi!")
                    self.statusImage.setImage(UIImage(named: "04"))
                }
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
