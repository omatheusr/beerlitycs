//
//  ConfigurationViewController.swift
//  Beerlitycs
//
//  Created by Lucas Correa on 26/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class ConfigurationViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonTapped(sender: UIButton) {
        var alert = UIAlertController(title: "Cuidado!", message: "Tem certeza que deseja sair do aplicativo?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Sim", style: UIAlertActionStyle.Default){ (action) -> Void in
            
            if ((PFUser.currentUser()) != nil){
                PFUser.logOut()
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            
        })
        
        alert.addAction(UIAlertAction(title: "Não", style: UIAlertActionStyle.Default){ (action) -> Void in })
        self.presentViewController(alert, animated: true, completion: nil)

    }


}
