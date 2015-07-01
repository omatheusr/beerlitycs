//
//  PushNotifications.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 30/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse

class PushNotifications: NSObject {
    static func associateDeviceWithCurrentUser() {
        let installation = PFInstallation.currentInstallation()
        
        if((installation["user"] == nil) && PFUser.currentUser() != nil) {
            installation["user"] = PFUser.currentUser()
            installation.saveInBackground()
        }
    }
}