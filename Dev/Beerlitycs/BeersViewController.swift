//
//  BeersViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 25/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class BeersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var beers = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("beerCell") as! BeersTableViewCell
        
        var beerControl = BeerManager(dictionary: self.beers[indexPath.row] as! PFObject)
        cell.beerName.text = beerControl.name

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func loadData() {
        var beerControl = BeerManager()
        
        beerControl.getBeers { (allBeers, error) -> () in
            if(error == nil) {
                self.beers = allBeers!
                self.updateTableView()
            } else {
                println("Ocorreu um erro ao carregar as cervejas")
            }
        }
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
