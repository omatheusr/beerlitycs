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

class CheckInViewController: UIViewController {

    var beerSelected : BeerManager?
    var placeSelected : PlaceManager?
    var cupSelected : CupManager?
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            println("cerveja selecionada")
        }
    }

    @IBAction func selectPlace(segue:UIStoryboardSegue) {
        if(segue.identifier == "selectPlace") {
            println("local selecionado")
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