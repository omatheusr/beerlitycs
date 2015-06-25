//
//  PlacesViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 23/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class PlacesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var places = []

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
        return places.count
    }
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell") as! PlacesTableViewCell
        
        let placeControl = PlaceManager(array: places[indexPath.row])
        
        cell.placeName.text = placeControl.name

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func loadData() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                let location = CLLocation(
                    latitude: geoPoint!.latitude,
                    longitude: geoPoint!.longitude
                )
                
                let placeControl = PlaceManager()
                self.places = placeControl.requestPlacesWithLocation(location)
                self.updateTableView()
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
