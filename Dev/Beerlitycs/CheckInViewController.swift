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


    @IBOutlet var baseMapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //estyle
        mapViewCustom = MGLMapView ( frame :  CGRectMake(0, 0,self.view.frame.size.width, baseMapView.frame.size.height), styleURL :  NSURL(string: "asset://styles/dark-v7.json"))
        mapViewCustom.delegate = self
        
        //zoom

        
        //ponto
        
        self.baseMapView.addSubview(mapViewCustom)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        mapViewCustom.setCenterCoordinate(CLLocationCoordinate2D(latitude: -30.024246, longitude: -51.202715), zoomLevel: 14, animated: true)
        
        let pin = MGLPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: -30.024246, longitude: -51.202715)
        pin.title = "Thomas Pub"//NOME DO BUTECO
        pin.subtitle = "subtitulo"//SLA DA PRA POR ALGO AQUI
        mapViewCustom.addAnnotation(pin)

    }
    
//        // passar longitude e latitudo do bar aqui
//        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(-30.024180, longitude: -51.202917, zoom: 16.0)
//        mapView.myLocationEnabled = true
//        mapView.camera = camera
//        var marker = GMSMarker()
//        marker.position = camera.target
//        
//        //passar nome do bar aqui!
//        marker.snippet = "Thomas Pub"
//        marker.appearAnimation = kGMSMarkerAnimationPop
//        marker.map = mapView
//        
//        mapView.mapType = kGMSTypeTerrain
        
        


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelCheckIn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func selectBeer(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectBeer") {
            println("cerveja selecionada")
        }
    }

    @IBAction func selectPlace(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectPlace") {
            println("local selecionado")
        }
    }

    func mapView(mapView: MGLMapView, symbolNameForAnnotation annotation: MGLAnnotation) -> String? {
        return "default_marker"
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}


