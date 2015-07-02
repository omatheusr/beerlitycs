//
//  RankingViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class RankingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ranking = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        loadMutualFriends()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.count+1
    }
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("StaticRankingTableViewCell") as! StaticRankingTableViewCell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            let userControl = UserManager(dictionary: PFUser.currentUser()!)
            
            cell.profileName.text = userControl.name

            let url = NSURL(string: userControl.photo!.url!)
            cell.profileImage.setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            Util.roundedView(cell.profileImage.layer, border: true, colorHex: "E55122", borderSize: 2.0, radius: cell.profileImage.frame.size.width / 2)
            
            cell.profileImage.clipsToBounds = true

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("rankingCell") as! RankingTableViewCell
            
            let userControl = UserManager(dictionary: ranking[indexPath.row-1] as! PFUser)
            
            cell.userName.text = userControl.name
            
            let url = NSURL(string: userControl.photo!.url!)
            cell.userPhoto.setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

            Util.roundedView(cell.userPhoto.layer, border: false, colorHex: nil, borderSize: nil, radius: cell.userPhoto.frame.size.width / 2)
            cell.userPhoto.clipsToBounds = true
            
            cell.userPosition.text = String(indexPath.row) + "º"
            
            
            var mlDrunk = NSInteger()
            mlDrunk = 0
            
            userControl.getCupsDrunk(userControl.objectId, callback: { (cups, error) -> () in
                if(error == nil) {
                    mlDrunk = cups!
                    cell.userDrinked.text = String(mlDrunk) + " ml"
                } else {
                    println("erro")
                }
            })

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

    func updateTableView() {
        self.tableView.reloadData()
    }

    func loadMutualFriends() {
        let userControl = UserManager()
        
        userControl.getMutualFriendsDescendingByMLDrunk(PFUser.currentUser()!, callback: { (friends, error) -> () in
            if(error == nil) {
                self.ranking = friends!
                self.updateTableView()
            } else {
                println(error)
            }
        })
        
    }
    
}
