//
//  CDPicture+CoreDataProperties.swift
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

extension CDPicture {

    @NSManaged var imageUrl: String?
    @NSManaged var serverID: String?
    @NSManaged var storagePath: String?
    @NSManaged var userId: String?
    @NSManaged var event: CDEvent?
    @NSManaged var owner: CDOrganization?
    @NSManaged var user: CDUser?

}
