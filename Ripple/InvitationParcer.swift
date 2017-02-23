//
//  InvitationParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class InvitationParcer : NSObject {
    
    func fetchCoreDataEntity(fromInvitation invitation: Invitation, withContext context: NSManagedObjectContext) -> CDInvitation? {
        var cdInvitation = CDInvitation.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: invitation.objectId, inContext: context)
        
        if cdInvitation == nil {
            cdInvitation = CDInvitation.MR_createEntityInContext(context)
            
            if cdInvitation == nil {
                return nil
            }
            
            cdInvitation!.serverID = invitation.objectId
        }
        
        cdInvitation!.serverID = invitation.objectId
        cdInvitation!.accept = invitation.accept
        cdInvitation!.type = invitation.type
        
        if invitation.fromUser != nil {
            cdInvitation!.fromUser = UserParcer().fetchCoreDataEntity(fromUser: invitation.fromUser!, withContext: context)
        }
        
        if invitation.toUser != nil {
            cdInvitation!.toUser = UserParcer().fetchCoreDataEntity(fromUser: invitation.toUser!, withContext: context)
        }
        
        if invitation.organization != nil {
            cdInvitation!.organization = OrganizationParcer().fetchCoreDataEntity(fromOrganization: invitation.organization!, withContext: context)
        }
        
        if invitation.event != nil {
            cdInvitation!.event = EventParcer().fetchCoreDataEntity(fromEvent: invitation.event!, withContext: context)
        }
        
        return cdInvitation
}
    
    func fetchBackendlessEntity(fromCDInvitation cdInvitation: CDInvitation) -> Invitation {
        let invitation = Invitation()
        invitation.objectId = cdInvitation.serverID
        invitation.accept = cdInvitation.accept
        
        if let type = cdInvitation.type {
            invitation.type = type
        }
        
        if let fromCDUser = cdInvitation.fromUser {
            invitation.fromUser = UserParcer().fetchBackendlessEntity(fromCDUser: fromCDUser)
        }
        
        if let toCDUser = cdInvitation.toUser {
            invitation.toUser = UserParcer().fetchBackendlessEntity(fromCDUser: toCDUser)
        }
        
        if let cdOrganization = cdInvitation.organization {
            invitation.organization = OrganizationParcer().fetchBackendlessEntity(fromCDOrganization: cdOrganization)
        }
        
        if let cdEvent = cdInvitation.event {
            invitation.event = EventParcer().fetchBackendlessEntity(fromCDEvent: cdEvent)
        }
        
        return invitation
    }
    
}
