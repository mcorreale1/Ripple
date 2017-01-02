//
//  Invitation.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class Invitation: BackendlessEntity {
    
    enum typeInvitation: String {
        case user = "User"
        case organization = "Organization"
        case event = "Event"
        case followingRequest = "FollowingRequest"
    }
    
    var fromUser: Users?
    var toUser: Users?
    var accept: Bool?
    var organization: Organizations?
    var event: RippleEvent?
    var type: String?
}
