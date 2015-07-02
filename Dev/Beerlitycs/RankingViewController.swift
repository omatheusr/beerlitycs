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
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()

        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            self.tableView.tableFooterView = UIView()
            self.refreshControl.addTarget(self, action: "loadMutualFriends:", forControlEvents: UIControlEvents.ValueChanged)
            self.tableView.addSubview(refreshControl)
            self.refreshControl.beginRefreshing()

            loadMutualFriends(nil)
        }
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
            if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
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
//                self.refreshControl.endRefreshing()
                let cell = tableView.dequeueReusableCellWithIdentifier("connectFB") as! ConectFBTableViewCell
                return cell
            }
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
            if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                return self.tableView.frame.height - (self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height)
            } else {
                return 160
            }
        } else {
            return 80
        }
    }

    func updateTableView() {
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    @IBAction func connectUserWithFb(sender: AnyObject) {
        var permissions = ["user_friends"]
        
        let userControl = UserManager()

        let user = PFUser.currentUser()!
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: permissions, block: { (success, error) -> Void in
                if success {
                    userControl.returnUserData(user, linked: true, callback: { (error) -> () in
                        if(error == nil) {
                            self.loadMutualFriends(nil)
                        } else {
                            println("erro na funcao do FB")
                        }
                    })
                } else {
                    println("usuário já linkado com outro usuário")
                }
            })
        }
    }

    func loadMutualFriends(sender:AnyObject?) {
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
