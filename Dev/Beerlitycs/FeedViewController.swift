//
//  FeedViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 27/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {
    var feed = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        PushNotifications.associateDeviceWithCurrentUser()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()?.objectId
        
        if currentUser == nil {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count+1
    }
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("statusCell") as! StatusTableViewCell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("feedCell") as! FeedTableViewCell
 
            var drinkControl = DrinkManager(dictionary: self.feed[indexPath.row-1] as! PFObject)
            
            var activityText = "está bebendo"
            
            if(drinkControl.beer != nil) {
                activityText = activityText + " uma " + drinkControl.beer!.name
            }
            
            if(drinkControl.cup != nil) {
                activityText = activityText + String(drinkControl.cup!.size) + "ml"
            }

            if(drinkControl.place != nil) {
                activityText = activityText + " no " + drinkControl.place!.name
            }

            drinkControl.user?.photo?.getDataInBackgroundWithBlock({ (image, error) -> Void in
                cell.profileImage.image = UIImage(data: image!)
                Util.roundedView(cell.profileImage.layer, border: false, colorHex: nil, borderSize: nil, radius: cell.profileImage.frame.size.width / 2)
                cell.profileImage.clipsToBounds = true
            })

            cell.profileName.text = drinkControl.user!.name
            cell.activityText.text = activityText

            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            return 160
        } else {
            return 80
        }
    }
    
    func loadData() {
        let drinkControl = DrinkManager()
        
        drinkControl.getDrinks { (allDrinks, error) -> () in
            if(error == nil) {
                self.feed = allDrinks!
                self.updateTableView()
            }
        }
    }

    func updateTableView() {
        self.tableView.reloadData()
    }

    /*
    constante = 0,74 (homem) || 0,67 (mulher)
    
    VolumeAlcoolBebida = (volumeBebida * porcentualAlcool) / 100
    MassaEtanol = VolumeAlcoolBebida * 0,8g
    AlcoolNoSangue = MassaEtanol / (PesoPessoa * constante)
    */

}
