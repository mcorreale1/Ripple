//
//  CDUser.swift
//  Ripple
//
//  Created by nikitaivanov on 07/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import CoreData

@objc(CDUser)
class CDUser: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func create(fromUser user:Users) {
        var cdUser:CDUser = MR_createEntity()! as CDUser
        cdUser.name = user.name
    }
}
