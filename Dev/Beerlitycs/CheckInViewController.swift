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
import GoogleMaps
import MapboxGL

class CheckInViewController: UIViewController, MGLMapViewDelegate {

    var beerSelected : BeerManager?
    var placeSelected : PlaceManager?
    var cupSelected : CupManager?
    var mapViewCustom : MGLMapView!

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var choiceBeerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelCheckIn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func selectBeer(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectBeer") {
            if(self.beerSelected != nil) {
                let textButton = self.beerSelected?.name
                self.choiceBeerButton.setTitle(textButton! + " - Trocar", forState: UIControlState.Normal)
            }
        }
    }

    @IBAction func selectPlace(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectPlace") {
            addStaticMap()
        }
    }

    func addStaticMap() {
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
        
        self.mapImage.image = map.image
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
}


