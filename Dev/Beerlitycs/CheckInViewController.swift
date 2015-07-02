//
//  CheckInViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import MapKit
import Parse

class CheckInViewController: UITableViewController {

    var beerSelected : BeerManager?
    var placeSelected : PlaceManager?
    var cupSelected : CupManager?

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var choiceBeerButton: UIButton!
    @IBOutlet weak var choicePlaceButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()

        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func childViewControllerDidPressButton(childViewController: CupsCollectionViewController) {
        // Do fun handling of child button presses!
    }

    @IBAction func cancelCheckIn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func selectBeer(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectBeer") {
            if(self.beerSelected != nil) {
                let textButton = self.beerSelected?.name
                self.choiceBeerButton.setTitle(textButton!, forState: UIControlState.Normal)
            }
        }
    }

    @IBAction func selectPlace(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectPlace") {
            addStaticMap()
        }
    }

    func addStaticMap() {
        self.choicePlaceButton.setTitle(self.placeSelected?.name, forState: UIControlState.Normal)

        let lat = self.placeSelected?.location.latitude
        let long = self.placeSelected?.location.longitude
        let clLocation = CLLocationCoordinate2DMake(lat!, long!)

        let markerOverlay = MapboxStaticMap.Marker(
            coordinate: clLocation,
            size: .Medium,
            label: "triangle",
            color: UIColor.whiteColor()
        )

        let map = MapboxStaticMap(
            mapID: "matheusbecker.873c9d11",
            center: clLocation,
            zoom: 17,
            size: CGSize(width: self.mapImage.layer.frame.width, height: self.mapImage.layer.frame.height),
            accessToken: "sk.eyJ1IjoibWF0aGV1c2JlY2tlciIsImEiOiJiYWZhNTg4NjRlYWJkYzUyNjBiYzNiYzk5YmFlOWZmZCJ9.Y4vw-oFFlJjuvhKdc0F8qA",
            overlays: [markerOverlay],
            retina: true
        )

//        let teste : String!
//
//        teste = "http://files.parsetfss.com/ec68a11d-2ad9-48a8-abfb-407dfc3ebd78/tfss-8cd4e020-b3c6-4cab-a34e-1def095f0214-NJm5gZHh82.jpg"
//        
////        let fileUrl = NSURL(fileURLWithPath: url)
//        let fileUrl = NSURL(string: teste!)

        self.mapImage.setImageWithURL(map.requestURL, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
    
    @IBAction func makeCheckIn(sender: AnyObject) {
        let drinkControl = DrinkManager()
        
        drinkControl.place = self.placeSelected
        drinkControl.beer = self.beerSelected
        drinkControl.cup = self.cupSelected
        
//        println(drinkControl.place)
//        println(drinkControl.beer)
//        println(drinkControl.cup)
        
        if(placeSelected != nil) {
            drinkControl.prepareForDrink(drinkControl, callback: { (error) -> () in
                if(error == nil) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    println("erro no check in")
                }
            })
        } else {
            drinkControl.newDrink(drinkControl) { (error) -> () in
                if(error == nil) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    println("erro no check in")
                }
            }
        }
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
                let places = placeControl.requestPlacesWithLocation(location) as NSArray
                self.placeSelected = PlaceManager(array: places.firstObject!)
                self.addStaticMap()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedCups" {
            let childViewController = segue.destinationViewController as! CupsCollectionViewController
            childViewController.parentVC = self
        }
    }
}


