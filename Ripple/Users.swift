//
//  User.swift
//  Ripple
//
//  Created by nikitaivanov on 05/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class Users: BackendlessUser {
    
    enum propertyName: String {
        case organizations = "organizations"
        case eventsBlackList = "eventsBlackList"
        case authData = "authData"
        case friends = "friends"
        case distance = "distance"
        case college = "college"
        case isPrivate = "isPrivate"
        case events = "events"
        case fullName = "fullName"
        case descr = "descr"
        case picture = "picture"
        case name = "name"
        case lastName = "lastName"
        case firstName = "firstName"
        case deviceID = "deviceID"
    
    }
    
    var authData:String? {
        get {
            return self.getProperty(propertyName.authData.rawValue) as? String ?? nil
        }
        set {
            self.setProperty(propertyName.authData.rawValue, object: newValue)
        }
    }
    
    var deviceID:String? {
        get {
            return self.getProperty(propertyName.authData.rawValue) as? String ?? nil
        }
        set {
            self.setProperty(propertyName.deviceID.rawValue, object: newValue)
        }
    }
    override var name:String? {
        get {
            return self.getProperty(propertyName.name.rawValue) as? String ?? nil
        }
        set {
            //print("setting name to" + newValue!)
            self.setProperty(propertyName.name.rawValue, object: newValue)
        }
    }
    
    var lastName:String? {
        get {
            return self.getProperty(propertyName.lastName.rawValue) as? String ?? nil
        }
        set {
            self.setProperty(propertyName.lastName.rawValue, object: newValue)
        }
    }
    
    var firstName:String? {
        get {
            return self.getProperty(propertyName.firstName.rawValue) as? String ?? nil
        }
        set {
            self.setProperty(propertyName.firstName.rawValue, object: newValue)
        }
    }
    
    var organizations: [Organizations] {
        get {
            return self.getProperty(propertyName.organizations.rawValue) as? [Organizations] ?? [Organizations]()
        }
        
        set {
            self.setProperty(propertyName.organizations.rawValue, object: newValue)
        }
    }
    
    var eventsBlackList: [RippleEvent] {
        get {
            return self.getProperty(propertyName.eventsBlackList.rawValue) as? [RippleEvent] ?? [RippleEvent]()
        }
        
        set {
            self.setProperty(propertyName.eventsBlackList.rawValue, object: newValue)
        }
    }
    
    var friends: [Users] {
        get {
            return self.getProperty(propertyName.friends.rawValue) as? [Users] ?? [Users]()
        }
        
        set {
            self.setProperty(propertyName.friends.rawValue, object: newValue)
        }
    }
    
    var isPrivate: Bool {
        get {
            return self.getProperty(propertyName.isPrivate.rawValue) as? Bool ?? false
        }
        
        set {
            self.setProperty(propertyName.isPrivate.rawValue, object: newValue)
        }
    }
    
    var events: [RippleEvent] {
        get {
            return self.getProperty(propertyName.events.rawValue) as? [RippleEvent] ?? [RippleEvent]()
        }
        
        set {
            self.setProperty(propertyName.events.rawValue, object: newValue)
        }
    }
    
    var fullName: String? {
        get {
            return self.getProperty(propertyName.fullName.rawValue) as? String ?? nil
        }
        
        set {
            self.setProperty(propertyName.fullName.rawValue, object: newValue)
        }
    }
    
    var descr : String? {
        get {
            return self.getProperty(propertyName.descr.rawValue) as? String ?? nil
        }
        
        set {
            self.setProperty(propertyName.descr.rawValue, object: newValue)
        }
    }
    
    var picture: Pictures? {
        get {
            return self.getProperty(propertyName.picture.rawValue) as? Pictures ?? nil
        }
        
        set {
            self.setProperty(propertyName.picture.rawValue, object: newValue)
        }
    }
    
    //populates the users from backendless
    static func userFromBackendlessUser(backendlessUser: BackendlessUser, friends:Bool = true) -> Users {
        let user = Users()
        user.populateFromBackendlessUser(backendlessUser, friends: friends)
        return user
    }
    
    //popultes all information on backendlessUsers
    func populateFromBackendlessUser(backendlessUser: BackendlessUser, friends:Bool = true) {
        self.objectId = backendlessUser.objectId
        self.email = backendlessUser.email;
        
        if let bOrganizations = backendlessUser.getProperty(propertyName.organizations.rawValue) {
            self.organizations = bOrganizations as? [Organizations] ?? [Organizations]()
        }
        
        if let bEventsBlackList = backendlessUser.getProperty(propertyName.eventsBlackList.rawValue) {
            self.eventsBlackList = bEventsBlackList as? [RippleEvent] ?? [RippleEvent]()
        }
        if(friends) {
            if let bFriends = backendlessUser.getProperty(propertyName.friends.rawValue) {
                self.friends = UserManager().backendlessUsersToLocalUsers(bFriends as? [BackendlessUser] ?? [BackendlessUser](), friends: false)
            }
        } else {
            self.friends = [Users]()
        }
        if let bIsPrivate = backendlessUser.getProperty(propertyName.isPrivate.rawValue) {
            self.isPrivate = bIsPrivate as? Bool ?? false
        }
        
        if let bEvents = backendlessUser.getProperty(propertyName.events.rawValue) {
            self.events = bEvents as? [RippleEvent] ?? [RippleEvent]()
        }
        
        if let bFullName = backendlessUser.getProperty(propertyName.fullName.rawValue) {
            self.fullName = bFullName as? String ?? ""
        }
        if let bName = backendlessUser.getProperty(propertyName.name.rawValue) {
            self.name = bName as? String ?? ""
        }
        if let bDeviceID = backendlessUser.getProperty(propertyName.deviceID.rawValue) {
            self.deviceID = bDeviceID as? String ?? nil
        }
        if let bLastName = backendlessUser.getProperty(propertyName.lastName.rawValue) {
            self.lastName = bLastName as? String ?? nil
        }
        if let bFirstName = backendlessUser.getProperty(propertyName.firstName.rawValue) {
            self.firstName = bFirstName as? String ?? nil
        }
        if let bDescr = backendlessUser.getProperty(propertyName.descr.rawValue) {
            self.descr = bDescr as? String ?? nil
        }
        
        if let bPicture = backendlessUser.getProperty(propertyName.picture.rawValue) {
            self.picture = bPicture as? Pictures ?? nil
        }
        
        if let bAuthDat = backendlessUser.getProperty(propertyName.authData.rawValue) {
            self.authData = bAuthDat as? String ?? nil
        }
    }
    
    
    func save(completion: (Bool, NSError?) -> Void) {
        dataStore().save(self, response: { (_) in
            completion(true, nil)
        }, error:  { (fault) in
            completion(false, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func dataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(ofClass())
    }
    
    func delete(completion: (Bool) -> Void) {
        dataStore().removeID(objectId, response: { (_) in
            completion(true)
        }, error: { (_) in
            completion(false)
        })
    }
    
}
