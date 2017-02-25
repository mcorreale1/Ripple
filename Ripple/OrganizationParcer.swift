//
//  OrganizationParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class OrganizationParcer : NSObject {
    
    func fetchCoreDataEntity(fromOrganization organization: Organizations, withContext context: NSManagedObjectContext) -> CDOrganization? {
        var cdOrganization = CDOrganization.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: organization.objectId, inContext: context)
        
        if cdOrganization == nil {
            cdOrganization = CDOrganization.MR_createEntityInContext(context)
            
            if cdOrganization == nil {
                return nil
            }
            
            cdOrganization!.serverID = organization.objectId
        }
    
        cdOrganization!.serverID = organization.objectId
        cdOrganization!.city = organization.city
        cdOrganization!.name = organization.name
        cdOrganization!.info = organization.info
        cdOrganization!.state = organization.info
        cdOrganization!.address = organization.address
        cdOrganization!.greekLife = organization.GreekLife
        
//        if organization.leaderId != nil {
//            cdOrganization!.leader = UserParcer().fetchCoreDataEntity(fromUser: organization.leader!, withContext: context)
//        }
        
        if organization.picture != nil {
            cdOrganization!.picture = PictureParcer().fetchCoreDataEntity(fromPicture: organization.picture!, withContext: context)
        }
        
        var cdEvents = Set<CDEvent>()
        for event in organization.events {
            if let cdEvent = EventParcer().fetchCoreDataEntity(fromEvent: event, withContext: context) {
                cdEvents.insert(cdEvent)
            }
        }
        cdOrganization!.events = cdEvents
        
        let cdMembersOf = Set<CDUser>()
        if let members = organization.getMembersOfUsers() {
            for member in members {
                UserParcer().fetchCoreDataEntity(fromUser: member, withContext: context)
            }
        }
        cdOrganization!.membersOf = cdMembersOf
    
        //let cdMembers = Set<CDUser>()
//        for member in organization.members {
//            if let cdMember = UserParcer().fetchCoreDataEntity(fromUser: member, withContext: context) {
//                cdMembers.insert(cdMember)
//            }
//        }
//        cdOrganization!.members = cdMembers
        
        let cdAdmins = Set<CDUser>()
//        for admin in organization.admins {
//            if let cdAdmin = UserParcer().fetchCoreDataEntity(fromUser: admin, withContext: context) {
//                cdAdmins.insert(cdAdmin)
//            }
//        }
        cdOrganization!.admins = cdAdmins
        
        return cdOrganization
    }
    
    func fetchBackendlessEntity(fromCDOrganization cdOrganization: CDOrganization) -> Organizations {
        let organization = Organizations()
        organization.objectId = cdOrganization.serverID
        organization.city = cdOrganization.city
        organization.name = cdOrganization.name
        organization.info = cdOrganization.info
        organization.state = cdOrganization.state
        organization.address = cdOrganization.address
        organization.GreekLife = cdOrganization.greekLife
        
//        if let leader = cdOrganization.leader {
//            organization.leader = UserParcer().fetchBackendlessEntity(fromCDUser: leader)
//        }
        
        if let picture = cdOrganization.picture {
            organization.picture = PictureParcer().fetchBackendlessEntity(fromCDPicture: picture)
        }
        
        var admins = [Users]()
        if let adminsSet = cdOrganization.admins?.allObjects {
            if let cdAdminsSet = adminsSet as? [CDUser] {
                for cdAdmin in cdAdminsSet {
                    admins.append(UserParcer().fetchBackendlessEntity(fromCDUser: cdAdmin))
                }
            }
        }
//        organization.admins = admins
        
        //var members = [Users]()
//        if let membersSet = cdOrganization.members?.allObjects {
//            if let cdMembersSet = membersSet as? [CDUser] {
//                for cdMember in cdMembersSet {
//                    members.append(UserParcer().fetchBackendlessEntity(fromCDUser: cdMember))
//                }
//            }
//        }
//        organization.members = members
        var membersOf = [BackendlessUser]()
        if let membersSet = cdOrganization.membersOf {
            if let cdMembersOfSet = membersSet as? [CDUser] {
                for cdUser in cdMembersOfSet {
                    membersOf.append(UserParcer().fetchBackendlessEntity(fromCDUser: cdUser))
                }
            }
        }
        
        var events = [RippleEvent]()
        if let eventsSet = cdOrganization.events?.allObjects {
            if let cdEventsSet = eventsSet as? [CDEvent] {
                for cdEvent in cdEventsSet {
                    events.append(EventParcer().fetchBackendlessEntity(fromCDEvent: cdEvent))
                }
            }
        }
        organization.events = events
        
        return organization
    }
    
}
