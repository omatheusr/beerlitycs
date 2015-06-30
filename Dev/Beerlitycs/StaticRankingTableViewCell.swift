//
//  StaticRankingTableViewCell.swift
//  Beerlitycs
//
//  Created by Lucas Correa on 29/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class StaticRankingTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.profileImage.layer.borderWidth = 1
//        profileImage.layer.masksToBounds = false
//        profileImage.layer.borderColor = hexStringToUIColor("#9D8C70").CGColor
//        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
//        profileImage.clipsToBounds = true
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
