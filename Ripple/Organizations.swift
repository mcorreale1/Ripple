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
    var membersOf = [AnyObject]()
//     var memberArray = [Users]()
//    var membersOf:[AnyObject]{
//        get {
//            return self.memberArray
//        }
//        set {
//            if (newValue is [BackendlessUser]) {
//                var new = [Users]()
//                for user in newValue {
//                    new.append(Users.userFromBackendlessUser(user as! BackendlessUser, friends: false))
//                }
//                memberArray = new
//            } else if (newValue is [Users]) {
//                memberArray = newValue as! [Users]
//            } else {
//                memberArray = [Users]()
//            }
//        }
//    }
    
    func setMembersFromBackendlessUsers(users:[BackendlessUser]) {
        self.membersOf = UserManager().backendlessUsersToLocalUsers(users, friends: false)
    }
}
