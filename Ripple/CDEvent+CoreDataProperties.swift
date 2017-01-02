//
//  CDEvent+CoreDataProperties.swift
//  Ripple
//
//  Created by nikitaivanov on 07/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDEvent {

    @NSManaged var adderess: String?
    @NSManaged var cost: NSNumber?
    @NSManaged var descr: String?
    @NSManaged var endDate: NSDate?
    @NSManaged var isPrivate: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var serverID: String?
    @NSManaged var startDate: NSDate?
    @NSManaged var invitations: NSSet?
    @NSManaged var organization: CDOrganization?
    @NSManaged var picture: CDPicture?
    @NSManaged var reports: NSSet?
    @NSManaged var usersBlacklisted: NSSet?
    @NSManaged var usersEvent: NSSet?

}
