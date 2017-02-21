//
//  PulseNotification.swift
//  Ripple
//
//  Created by Apple on 07.10.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

enum PulseNotification: String {
    // dont use short enum cases because rawValue will be used as notification name
    case PulseNotificationEventSendInvitations
    case PulseNotificationIsEventCreate
    case PulseNotificationIsEventEdit
}
