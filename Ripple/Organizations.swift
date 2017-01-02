//
//  Organization.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class Organizations: BackendlessEntity {
    var leaderId: String?
    var admins: String?
    var city: String?
    var name: String?
    var info: String?
    var state: String?
    var address: String?
    var members: String?
    var events = [RippleEvent]()
    var GreekLife: String?
    var picture: Pictures?
}
