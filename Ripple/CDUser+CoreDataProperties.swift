//
//  CDUser+CoreDataProperties.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDUser {

    @NSManaged var authData: FBSDKAccessToken?
    @NSManaged var college: String?
    @NSManaged var descr: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var email: String?
    @NSManaged var fullName: String?
    @NSManaged var isPrivate: NSNumber?
    @NSManaged var password: String?
    @NSManaged var serverID: String?
    @NSManaged var username: String?
    @NSManaged var adminedOrganizations: NSSet?
    @NSManaged var events: NSSet?
    @NSManaged var eventsBlackList: NSSet?
    @NSManaged var friends: NSSet?
    @NSManaged var incomingInvitations: NSSet?
    @NSManaged var incomingReports: NSSet?
    @NSManaged var incomingRequests: NSSet?
    @NSManaged var leadingOrganizations: NSSet?
    @NSManaged var organizations: NSSet?
    @NSManaged var outcomingInvitations: NSSet?
    @NSManaged var outcomingReports: NSSet?
    @NSManaged var outcomingRequests: NSSet?
    @NSManaged var picture: CDPicture?

}
