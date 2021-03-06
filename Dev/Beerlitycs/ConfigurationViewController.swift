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
                PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                    if(error == nil) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            }
        })

        alert.addAction(UIAlertAction(title: "Não", style: UIAlertActionStyle.Default){ (action) -> Void in })
        self.presentViewController(alert, animated: true, completion: nil)

    }

    @IBAction func editProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("editProfile", sender: nil)
    }

    @IBAction func backToView(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func backFromNewBeer(segue:UIStoryboardSegue) {
    }

    @IBAction func selectBeer(segue:UIStoryboardSegue) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "editProfile") {
            let rVC : RegisterViewController = segue.destinationViewController as! RegisterViewController
            
            let userControl = UserManager(dictionary: PFUser.currentUser()!)
            rVC.userControl = userControl
            rVC.editView = true
        }
    }
}
