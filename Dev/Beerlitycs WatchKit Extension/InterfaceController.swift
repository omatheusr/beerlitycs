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
        
        var request = ["request": "getStatus"]
        
        WKInterfaceController.openParentApplication(request, reply: { (replyFromParent, error) -> Void in
            if(error != nil) {
                println("there was an error receiving a reply")
            } else {
                
                println(replyFromParent["reply"]![0])
                println(replyFromParent["reply"]![1])
                
                
//                let type = replyFromParent["reply"]!
//                
//                if(type as! NSObject == 1) {
//                    self.statusText.setText("Parábens! Você é o motorista da rodada")
//                    self.statusImage.image = UIImage(named: "22")
//                } else if(type == 2){
//                    self.statusText.text = "OPA! Abrindo os trabalhos!"
//                    self.statusImage.image = UIImage(named: "17")
//                } else if(type == 2){
//                    self.statusText.text = "BELEZA! Tudo está ficando lindo!"
//                    self.statusImage.image = UIImage(named: "05")
//                } else {
//                    self.statusText.text = "CUIDADO! Não vá fazer algo que se arrependa.. e chame um Taxi!"
//                    self.statusImage.image = UIImage(named: "04")
//                }
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
