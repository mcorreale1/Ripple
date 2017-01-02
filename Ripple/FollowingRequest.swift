//
//  FollowingRequest.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class FollowingRequest: BackendlessEntity {
    var fromUser: Users?
    var toUser: Users?
    var isConfirmed = false
}
