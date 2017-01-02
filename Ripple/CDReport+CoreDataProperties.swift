//
//  CDReport+CoreDataProperties.swift
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

extension CDReport {

    @NSManaged var serverID: String?
    @NSManaged var type: String?
    @NSManaged var event: CDEvent?
    @NSManaged var fromUser: CDUser?
    @NSManaged var organization: CDOrganization?
    @NSManaged var toUser: CDUser?

}
