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
    var position = NSInteger()
    
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
            
            if let mldrunk = userControl.mlDrunk{
                cell.mlDrunk.text = String(stringInterpolationSegment: userControl.mlDrunk!) + " ml"
            } else {
                cell.mlDrunk.text = "-"
            }
            
            cell.profileName.text = userControl.name
            cell.userPosition.text = String(self.position) + "º"
            cell.numberOFBarsVisited.text = String(10)

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
            cell.userDrinked.text = String(userControl.mlDrunk!) + " ml"

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
                
                var i = NSInteger()
                
                for(i=0;i<self.ranking.count;i++) {
                    if (PFUser.currentUser()?.objectId == self.ranking[i].objectId){
                        self.position = i+1;
                    }
                }
                 
                
                self.updateTableView()
            } else {
                println(error)
            }
        })
        
    }
    
}
