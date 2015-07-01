//
//  CupsCollectionViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 26/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class CupsCollectionViewController: UICollectionViewController {
    
    var cups = []
    var selectedCup : CupManager?
    var parentVC : CheckInViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCups()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cups.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cupCell", forIndexPath: indexPath) as! CupsCollectionViewCell
    
//        cell.iconCup.image = 
        let cupControl = CupManager(dictionary: self.cups[indexPath.row] as! PFObject)
        cell.sizeCup.text = String(cupControl.size) + "ml"
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedCup = CupManager(dictionary: self.cups[indexPath.row] as! PFObject)

        self.parentVC!.cupSelected = self.selectedCup
    }

    func loadCups() {
        let cupControl = CupManager()
        
        cupControl.getCups { (allCups, error) -> () in
            if(error == nil) {
                self.cups = allCups!
                self.updateTableView()
            } else {
                println("falha ao carregar")
            }
        }
    }

    func updateTableView() {
        self.collectionView!.reloadData()
    }
}
