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

    var lat : Double?
    var long : Double?
    var clLocation = CLLocationCoordinate2D()

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var choiceBeerButton: UIButton!
    @IBOutlet weak var choicePlaceButton: UIButton!
    @IBOutlet var confirmationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.confirmationButton.enabled = true
        
        Util.roundedView(self.confirmationButton.layer, border: false, colorHex: nil, borderSize: nil, radius: 6)

        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.confirmationButton.enabled = true
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
            if(self.placeSelected != nil) {
                loadData()
            }
        }
    }

    @IBAction func makeCheckIn(sender: AnyObject) {
        let drinkControl = DrinkManager()
        let userControl = UserManager()
        
        drinkControl.place = self.placeSelected
        drinkControl.beer = self.beerSelected
        drinkControl.cup = self.cupSelected
        
//        println(drinkControl.place)
//        println(drinkControl.beer)
//        println("segundo")
//        println(self.beerSelected)
//        println(drinkControl.cup)
        
        self.confirmationButton.enabled = false
        
        // Nao foi selecionado o local
        if(placeSelected != nil) && (beerSelected != nil) && (cupSelected != nil) {
                drinkControl.prepareForDrink(drinkControl, callback: { (error) -> () in
                        if(error == nil) {
                            userControl.addNewBeerInMLToTotal(PFUser.currentUser()!.objectId!, mlDrunk: drinkControl.cup!.size!, callback: { (error) -> () in
                            if (error == nil) {
                                UserDefaultsManager.needReloadHome = true
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                println(error)
                                }
                            })
                    
                        } else {
                            println("erro no check in")
                        }
                    })
        } else {
//            drinkControl.newDrink(drinkControl) { (error) -> () in
//                if(error == nil) {
                    
                    //var decision = self.showAlert("Cuidado!", message: "Você não selecionou nenhum bar. Deseja continuar mesmo assim? ")
                    //if(decision == true){
//                    userControl.addNewBeerInMLToTotal(PFUser.currentUser()!.objectId!, mlDrunk: drinkControl.cup!.size!, callback: { (error) -> () in
//                        if (error == nil) {
//                            self.dismissViewControllerAnimated(true, completion: nil)
//                        }else {
//                            println(error)
//                        }
//                    })
                    //}
            
                self.showAlert("Oops!", message: "Voce deve selecionar um local e uma cerveja para fazer o check in.", buttonOption1: "OK!", buttonOption2: "")

                self.confirmationButton.enabled = true
                    
//                } else {
//                    println("erro no check in")
//                }
//            }
        }
    }

    func loadData() {
        if(self.placeSelected != nil) {
            self.choicePlaceButton.setTitle(self.placeSelected?.name, forState: UIControlState.Normal)
            
            self.lat = self.placeSelected?.location.latitude
            self.long = self.placeSelected?.location.longitude
            
            addStaticMap()
        } else {
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    self.lat = geoPoint!.latitude
                    self.long = geoPoint!.longitude
                    self.clLocation = CLLocationCoordinate2D()
                    
                    self.addStaticMap()
                } else {
                    println("erro de localização")
                }
            }
        }
    }

    func addStaticMap() {
        if lat != nil{
            if long != nil{
                clLocation = CLLocationCoordinate2DMake(lat!, long!)
            }
        }

        let markerOverlay = MapboxStaticMap.Marker(
            coordinate: clLocation,
            size: .Medium,
            label: "triangle",
            color: UIColor.whiteColor()
        )
        
        var mapSize : CGSize!
        if(self.mapImage.layer.frame.width < 640) {
            mapSize = CGSize(width: self.mapImage.layer.frame.width, height: self.mapImage.layer.frame.height)
        } else {
            mapSize = CGSize(width: 640, height: self.mapImage.layer.frame.height)
        }

        let map = MapboxStaticMap(
            mapID: "matheusbecker.873c9d11",
            center: clLocation,
            zoom: 17,
            size: mapSize,
            accessToken: "sk.eyJ1IjoibWF0aGV1c2JlY2tlciIsImEiOiJiYWZhNTg4NjRlYWJkYzUyNjBiYzNiYzk5YmFlOWZmZCJ9.Y4vw-oFFlJjuvhKdc0F8qA",
            overlays: [markerOverlay],
            retina: true
        )

        self.mapImage.setImageWithURL(map.requestURL, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
    
    func showAlert(title : String, message: String, buttonOption1: String?, buttonOption2: String?) -> Bool{
        
        var decision = Bool()
        var alert = UIAlertController()
        
        if buttonOption1!.isEmpty {
            // NADA
        } else {
            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: buttonOption1!, style: UIAlertActionStyle.Default){ (action) -> Void in
                decision = true
            })
        }

        if buttonOption2!.isEmpty {
            // NADA
        } else {
            alert.addAction(UIAlertAction(title: buttonOption2!, style: UIAlertActionStyle.Default){ (action) -> Void in
                decision = false
            })
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        return decision
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedCups" {
            let childViewController = segue.destinationViewController as! CupsCollectionViewController
            childViewController.parentVC = self
        }
    }
    
}

/*
cell.contentView.backgroundColor = UIColor

cell.sizeCup.textColor = UIColor(red: 255.0/255.0, green: 246.0/255.0, blue: 241.0/255.0, alpha: 1.0)
*/


