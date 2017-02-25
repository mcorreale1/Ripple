//
//  CDOrganization+CoreDataProperties.swift
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

extension CDOrganization {

    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var greekLife: String?
    @NSManaged var info: String?
    @NSManaged var name: String?
    @NSManaged var serverID: String?
    @NSManaged var state: String?
    @NSManaged var admins: NSSet?
    @NSManaged var events: NSSet?
    @NSManaged var invitations: NSSet?
    @NSManaged var leader: CDUser?
    //@NSManaged var members: NSSet?
    @NSManaged var membersOf: NSSet?
    @NSManaged var picture: CDPicture?
    @NSManaged var reports: NSSet?

}
