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

        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()?.objectId
        
        if currentUser == nil {
//            self.performSegueWithIdentifier("loginSegue", sender: nil)
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
            let activityText = "\(drinkControl.user!.name) está bebendo uma \(drinkControl.beer!.name) \(drinkControl.cup!.size)ml"

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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
