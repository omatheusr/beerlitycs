//
//  RegisterNewBeerViewController.swift
//  Beerlitycs
//
//  Created by Lucas Correa on 26/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class RegisterNewBeerViewController: UITableViewController {

    @IBOutlet var txtNewBeerName: UITextField!
    @IBOutlet var txtNewBeerAlcoholContent: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        if((txtNewBeerName != nil) && (txtNewBeerAlcoholContent != nil)) {
            
            var newBeer = PFObject(className: "Beer")
            
            newBeer["name"] = txtNewBeerName.text
            newBeer["alcoholcontent"] = txtNewBeerAlcoholContent.text
            newBeer["active"] = false
            
            newBeer.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (success) {
                    println("New beer register successfully")
                    
                    // Cerveja enviada para lista de aprovação
                    var alert = UIAlertController(title: "Obrigado por nos ajudar!", message: "A cerveja adicionada entrará para um lista de aprovação.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ (action) -> Void in
                        self.performSegueWithIdentifier("saveBeer", sender: nil)
                    })
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    println(error)
                    
                    // Erro ao cadastrar a cerveja
                    var alert = UIAlertController(title: "", message: "Opss... Ocorreu um erro. Tente de novo.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            
        }
        
    }
    
}
