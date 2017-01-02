//
//  Report.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class Reports: BackendlessEntity {
    
    enum typeReport: String {
        case user = "User"
        case organization = "Organization"
        case event = "Event"
        case followingRequest = "FollowingRequest"
    }
    
    var toUser: Users?
    var fromUser: Users?
    var organization: Organizations?
    var event: RippleEvent?
    var type: typeReport?
    var accept = false
}
