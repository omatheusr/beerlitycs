//
//  Util.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 29/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class Util {
    static func roundedView(view: CALayer!, border: Bool, radius: CGFloat) {
        if(border == true) {
            view.borderWidth = 1
            view.borderColor = UIColor.lightGrayColor().CGColor
        }
        view.cornerRadius = radius
    }
}
