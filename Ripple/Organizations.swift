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
    var membersOf = [BackendlessUser]()
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
    
    func getMembersOfUsers() -> [Users]? {
        if(self.membersOf is [Users]) {
            return self.membersOf as? [Users]
        } else {
            let users = UserManager().backendlessUsersToLocalUsers(self.membersOf, friends: false)
            self.membersOf = users
            return self.membersOf as? [Users]
        }
    }
    
}
