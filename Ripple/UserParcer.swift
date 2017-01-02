//
//  UserParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class UserParcer : NSObject {
    
    func fetchCoreDataEntity(fromUser user: Users, withContext context: NSManagedObjectContext) -> CDUser? {
        var cdUser = CDUser.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: user.objectId, inContext: context)
        
        if cdUser == nil {
            cdUser = CDUser.MR_createEntityInContext(context)
            
            if cdUser == nil {
                return nil
            }
            
            cdUser!.serverID = user.objectId
        }
        
        cdUser!.descr = user.descr
        cdUser!.email = user.email
        cdUser!.fullName = user.fullName
        cdUser!.isPrivate = user.isPrivate
        cdUser!.password = user.password
        cdUser!.serverID = user.objectId
        cdUser!.username = user.name
        
        if user.picture != nil {
            cdUser!.picture = PictureParcer().fetchCoreDataEntity(fromPicture: user.picture!, withContext: context)
        }
        
        var cdEvents = Set<CDEvent>()
        for event in user.events {
            if let cdEvent = EventParcer().fetchCoreDataEntity(fromEvent: event, withContext: context) {
                cdEvents.insert(cdEvent)
            }
        }
        cdUser!.events = cdEvents
        
        var cdEventsBlackList = Set<CDEvent>()
        for event in user.eventsBlackList {
            if let cdEvent = EventParcer().fetchCoreDataEntity(fromEvent: event, withContext: context) {
                cdEventsBlackList.insert(cdEvent)
            }
        }
        cdUser!.eventsBlackList = cdEvents
        
        var cdFriends = Set<CDUser>()
        for friend in user.friends {
            if let cdFriend = UserParcer().fetchCoreDataEntity(fromUser: friend, withContext: context) {
                cdFriends.insert(cdFriend)
            }
        }
        cdUser!.friends = cdFriends
        
        var cdOrganizations = Set<CDOrganization>()
        for organization in user.organizations {
            if let cdOrganization = OrganizationParcer().fetchCoreDataEntity(fromOrganization: organization, withContext: context) {
                cdOrganizations.insert(cdOrganization)
            }
        }
        cdUser!.organizations = cdOrganizations
        
        return cdUser

    }
    
    func fetchBackendlessEntity(fromCDUser cdUser: CDUser) -> Users {
        let user = Users()
        user.objectId = cdUser.serverID
        user.name = cdUser.username
        user.isPrivate = cdUser.isPrivate?.boolValue ?? false
        user.fullName = cdUser.fullName
        user.descr = cdUser.descr
        
        if let cdPicture = cdUser.picture {
            user.picture = PictureParcer().fetchBackendlessEntity(fromCDPicture: cdPicture)
        }
        
        var organizations = [Organizations]()
        if let orgSet = cdUser.organizations?.allObjects {
            if let cdOrgSet = orgSet as? [CDOrganization] {
                for cdOrg in cdOrgSet {
                    organizations.append(OrganizationParcer().fetchBackendlessEntity(fromCDOrganization: cdOrg))
                }
            }
        }
        user.organizations = organizations
        
        var events = [RippleEvent]()
        if let eventsSet = cdUser.events?.allObjects {
            if let cdEventsSet = eventsSet as? [CDEvent] {
                for cdEvent in cdEventsSet {
                    events.append(EventParcer().fetchBackendlessEntity(fromCDEvent: cdEvent))
                }
            }
        }
        user.events = events
        
        var eventsBlackList = [RippleEvent]()
        if let blackListSet = cdUser.eventsBlackList?.allObjects {
            if let cdBlackListSet = blackListSet as? [CDEvent] {
                for cdEvent in cdBlackListSet {
                    eventsBlackList.append(EventParcer().fetchBackendlessEntity(fromCDEvent: cdEvent))
                }
            }
        }
        user.eventsBlackList = eventsBlackList
        
        var friends = [Users]()
        if let friendsSet = cdUser.friends?.allObjects {
            if let cdFriendsSet = friendsSet as? [CDUser] {
                for cdFreind in cdFriendsSet {
                    friends.append(UserParcer().fetchBackendlessEntity(fromCDUser: cdFreind))
                }
            }
        }
        user.friends = friends
        
        return user
    }
    
}
