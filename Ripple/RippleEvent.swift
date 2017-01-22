//
//  RippleEvent.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class RippleEvent: BackendlessEntity {
    var name: String?
    var descr: String?
    var latitude = 0.0
    var longitude = 0.0
    var cost = 0.0
    var startDate: NSDate?
    var endDate: NSDate?
    var organization: Organizations?
    var address: String?
    var city: String?
    var location: String?
    var isPrivate = false
    var picture: Pictures?
}
