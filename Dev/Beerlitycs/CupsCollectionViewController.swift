//
//  CupsCollectionViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 26/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class CupsCollectionViewController: UICollectionViewController{
    
    var cups = []
    var selectedCup : CupManager?
    var parentVC : CheckInViewController!
    var set = Set<Int>()
     var index : Int!
     var aux :Int!

 
    
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
    
        let cupControl = CupManager(dictionary: self.cups[indexPath.row] as! PFObject)
        
        cell.sizeCup.text = String(cupControl.size) + "ml"
        cell.iconCup.image = UIImage(named: cupControl.icon!)
        
        Util.roundedView(cell.contentView.layer, border: false, colorHex: nil, borderSize: nil, radius: cell.contentView.frame.height / 9)
        
        var index = indexPath.row
        
        if set.contains(index){
            cell.contentView.backgroundColor = UIColor(red: 24.0/255.0, green: 27.00/255.0, blue: 32.0/255.0, alpha: 1.0)
            cell.sizeCup.textColor = UIColor(red: 255.0/255.0, green: 246.0/255.0, blue: 241.0/255.0, alpha: 1.0)

            
            
        }else{
            cell.contentView.backgroundColor = UIColor(red: 255.0/255.0, green: 246.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            cell.sizeCup.textColor = UIColor(red: 24.0/255.0, green: 27.00/255.0, blue: 32.0/255.0, alpha: 1.0)
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        set.removeAll(keepCapacity: true)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CupsCollectionViewCell
        cell?.contentView.backgroundColor = UIColor(red: 24.0/255.0, green: 27.00/255.0, blue: 32.0/255.0, alpha: 1.0)
        index = indexPath.row
        set.insert(index)
        
    cell?.sizeCup.textColor = UIColor(red: 255.0/255.0, green: 244.0/255.0, blue: 237.0/255.0, alpha: 1.0)


        
        self.selectedCup = CupManager(dictionary: self.cups[indexPath.row] as! PFObject)
        self.parentVC!.cupSelected = self.selectedCup
    }
    
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        println("ok")
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CupsCollectionViewCell
        var index = indexPath.row
        
 
            cell?.contentView.backgroundColor = UIColor(red: 255.0/255.0, green: 246.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        
            cell?.sizeCup.textColor = UIColor(red: 24.0/255.0, green: 27.00/255.0, blue: 32.0/255.0, alpha: 1.0)

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
