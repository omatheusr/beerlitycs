//
//  UserDefaultsManager.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 03/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

private let dateRegister = "Date"
private let userId = "userId"
private let rankingPosition = "rankingPosition"
private let alcoholInBlood = "alcoholInBlood"
private let alcoholType = "alcoholType"
private let reloadHome = "reloadHome"

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

    class var getRankingPosition: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(rankingPosition) as? String
        }
        set(newProperty) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty, forKey: rankingPosition)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    class var getAlcoholInBlood: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(alcoholInBlood) as? String
        }
        set(newProperty1) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty1, forKey: alcoholInBlood)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class var getAlcoholType: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(alcoholType) as? String
        }
        set(newProperty2) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty2, forKey: alcoholType)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    class var needReloadHome: Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(reloadHome) as? Bool
        }
        set(newProperty2) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty2, forKey: reloadHome)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}