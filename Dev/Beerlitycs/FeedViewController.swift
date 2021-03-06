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
    var feed : NSMutableArray = []
    var refreshControl:UIRefreshControl!
    var loadApp : Bool?
    var Skip : Int = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension

        PushNotifications.associateDeviceWithCurrentUser()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadDataUpdate:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.refreshControl.beginRefreshing()

        self.loadDataUpdate(nil)

        Util.roundedView(self.checkButton.layer, border: false, colorHex: nil, borderSize: nil, radius: 6)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()?.objectId

        if currentUser == nil {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        } else {
            if(UserDefaultsManager.getUserId == nil) {
                UserDefaultsManager.getUserId = currentUser
            }
            let stats = StatsManager()
            
            
            // Pega a posicao apenas se estiver logado com o facebook
            if(PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)){
                stats.get(currentUser, callback: { (position, error) -> () in
                    if(error == nil) {
                        var str = ""
                        if let v = position {
                            str = "\(v)"
                        }
                        UserDefaultsManager.getRankingPosition = str
                    } else {
                        println(error)
                    }
                })
            }
            
            if(UserDefaultsManager.needReloadHome == true) {
                loadDataUpdate(nil)
                UserDefaultsManager.needReloadHome = false
            }
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
            let statusControl = StatsManager()
            
            if(PFUser.currentUser() != nil) {
                statusControl.alcoholContentInBlood(PFUser.currentUser()!.objectId!, callback: { (alcoholInBlood, type, error) -> () in
                    if(error == nil){
                        cell.alcoholContentInBlood.text = NSString(format: "%.2f",  alcoholInBlood!) as String
                        
                        if(type == 1) {
                            cell.textStatus.text = "Parábens! Você é o motorista da rodada!"
                            cell.imageStatus.image = UIImage(named: "01")
                        } else if(type == 2){
                            cell.textStatus.text = "OPA! Abrindo os trabalhos!"
                            cell.imageStatus.image = UIImage(named: "02")
                        } else if(type == 3){
                            cell.textStatus.text = "BELEZA! Tudo está ficando lindo!"
                            cell.imageStatus.image = UIImage(named: "03")
                        } else {
                            cell.textStatus.text = "CUIDADO! Não vá fazer algo que se arrependa.. e chame um Taxi!"
                            cell.imageStatus.image = UIImage(named: "04")
                        }
                        
                        UserDefaultsManager.getAlcoholType = String(stringInterpolationSegment: type!)
                        UserDefaultsManager.getAlcoholInBlood = NSString(format: "%.2f",  alcoholInBlood!) as String
                    } else {
                        println(error)
                    }
                })
            }
            
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
                activityText = activityText + " " + String(drinkControl.cup!.size) + " ml"
            }

            if(drinkControl.place != nil) {
                activityText = activityText + " no " + drinkControl.place!.name
            }
            
//            let url = NSURL.fileURLWithPath(drinkControl.user!.photo!.url!)
            let url = NSURL(string: drinkControl.user!.photo!.url!)
            
            cell.profileImage.setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

            Util.roundedView(cell.profileImage.layer, border: false, colorHex: nil, borderSize: nil, radius: cell.profileImage.frame.size.width / 2)
            cell.profileImage.clipsToBounds = true

            cell.profileName.text = drinkControl.user!.name
            cell.activityText.text = activityText
            cell.dateAgo.text = Util.howLongTime(drinkControl.createdAt)

            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            return 160
        } else {
            return 90
        }
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (indexPath.row-1 ==  (self.feed.count-1) - self.Skip/2) {
            self.Skip = self.Skip + 10
            self.loadData(nil)
        }
    }

    func isLandscapeOrientation() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }

    func loadData(sender:AnyObject?) {
        loadData(sender, update: false)
    }
    func loadDataUpdate(sender:AnyObject?) {
        self.Skip = 0
        loadData(sender, update: true)
    }

    func loadData(sender:AnyObject?, update: Bool) {
        let drinkControl = DrinkManager()
        
        drinkControl.getDrinks(self.Skip, callback: { (allDrinks, error) -> () in
            if(error == nil) {
                if(update == true) {
                    self.feed = allDrinks!.mutableCopy() as! NSMutableArray
                    self.updateTableView()
                } else {
                    self.feed.addObjectsFromArray(allDrinks! as [AnyObject])
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        })
    }

    func updateTableView() {
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

        
    /*
    constante = 0,74 (homem) || 0,67 (mulher)
    
    VolumeAlcoolBebida = (volumeBebida * porcentualAlcool) / 100
    MassaEtanol = VolumeAlcoolBebida * 0,8g
    AlcoolNoSangue = MassaEtanol / (PesoPessoa * constante)
    */

}
