//
//  Util.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 29/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class Util {
    static func roundedView(view: CALayer!, border: Bool, colorHex: String?, borderSize: CGFloat?, radius: CGFloat) {
        if(border == true) {
            view.borderWidth = borderSize!
            view.borderColor = hexStringToUIColor(colorHex!).CGColor
        }
        view.cornerRadius = radius
    }

    static func hexStringToUIColor (hex:String) -> UIColor {
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
    
    static func howLongTime (date: NSDate) -> String {
        var messageAgo = ""

        let dateNow = NSDate()
        let userCalendar = NSCalendar.currentCalendar()

        let dayCalendarUnit = NSCalendarUnit(UInt.max)

        let dateAgo = userCalendar.components(
            dayCalendarUnit,
            fromDate: date,
            toDate: dateNow,
            options: nil)
        
        if(dateAgo.year > 0) {
            messageAgo = String(dateAgo.year) + "a"
        } else if(dateAgo.month > 0) {
            messageAgo = String(dateAgo.month) + "mês"
        } else if(dateAgo.weekdayOrdinal > 0) {
            messageAgo = String(dateAgo.weekdayOrdinal) + "sem"
        } else if(dateAgo.day > 0) {
            messageAgo = String(dateAgo.day) + "d"
        } else if(dateAgo.hour > 0) {
            messageAgo = String(dateAgo.hour) + "h"
        } else if(dateAgo.minute > 0) {
            messageAgo = String(dateAgo.minute) + "m"
        } else if(dateAgo.second > 0) {
            messageAgo = String(dateAgo.second) + "s"
        }

        return messageAgo
    }
}
