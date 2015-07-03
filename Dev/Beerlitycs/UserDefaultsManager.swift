//
//  UserDefaultsManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 03/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

private let dateRegister = "Date"
private let userId = ""

class UserDefaultsManager: NSObject {
    class var getDateRegister: NSDate? {
        get {
        return NSUserDefaults.standardUserDefaults().valueForKey(dateRegister) as? NSDate
        }
        set(newProperty) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty, forKey: dateRegister)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    class var getUserId: String? {
        get {
        return NSUserDefaults.standardUserDefaults().valueForKey(userId) as? String
        }
        set(newProperty) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty, forKey: userId)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}