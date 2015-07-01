//
//  BeersViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 25/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class BeersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate {

    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var beers = [PFObject]()
    var filteredBeers = [PFObject]()
    var selectedBeer : BeerManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = true
        self.tableView.hideSearchBar()

        loadData()
    }
    
    func loadData() {
        var beerControl = BeerManager()
        
        beerControl.getBeers { (allBeers, error) -> () in
            if(error == nil) {
                self.beers = allBeers! as! [(PFObject)]
                self.updateTableView()
            } else {
                println("Ocorreu um erro ao carregar as cervejas")
                self.activity.hidden = true
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView() {
        self.activity.hidden = true
        self.tableView.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            return self.filteredBeers.count
        }
        else {
            return beers.count
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("beerCell") as! BeersTableViewCell

        var beerControl = BeerManager()
        
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            beerControl = BeerManager(dictionary: filteredBeers[indexPath.row])
            cell.beerName.text = beerControl.name
            cell.beerAlcoholContent.text = beerControl.alcoholContent + "%"
            return cell

        }
        else {
            beerControl = BeerManager(dictionary: beers[indexPath.row])
            cell.beerName.text = beerControl.name
            cell.beerAlcoholContent.text = beerControl.alcoholContent + "%"
            return cell

        }
    }
    
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            self.selectedBeer = BeerManager(dictionary: filteredBeers[indexPath.row] as! PFObject)
            self.performSegueWithIdentifier("selectBeer", sender: nil)

        }
        else {
            self.selectedBeer = BeerManager(dictionary: beers[indexPath.row] as! PFObject)
            self.performSegueWithIdentifier("selectBeer", sender: nil)

        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - Search Methods
    
    func filterContenctsForSearchText(searchText: String, scope: String = "Title") {
        self.filteredBeers =  self.beers.filter({ (beer:PFObject) ->
            Bool in
            var categoryMatch = (scope == "Title")
            var aux = beer
            var bbM = BeerManager(dictionary: aux)
            
            var stringMatch = bbM.name.rangeOfString(searchText)
            
            return categoryMatch && (stringMatch != nil)
            
         })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContenctsForSearchText(searchString, scope: "Title")
        
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContenctsForSearchText(self.searchDisplayController!.searchBar.text, scope: "Title")
        
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "selectBeer") {
            if(self.selectedBeer != nil) {
                let rVC : CheckInViewController = segue.destinationViewController as! CheckInViewController
            
                rVC.beerSelected = self.selectedBeer
            }
        }
    }
}

extension UITableView {
    func hideSearchBar() {
        
        if let bar = self.tableHeaderView as? UISearchBar {
            let height = CGRectGetHeight(bar.frame)
            let offset = self.contentOffset.y
            if offset < height {
                self.contentOffset = CGPointMake(0, height)
            }
        }
    }
}

