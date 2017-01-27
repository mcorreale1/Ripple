//
//  EventParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class EventParcer : NSObject {
    
    func fetchCoreDataEntity(fromEvent event: RippleEvent, withContext context: NSManagedObjectContext) -> CDEvent? {
        var cdEvent = CDEvent.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: event.objectId, inContext: context)
        
        if cdEvent == nil {
            cdEvent = CDEvent.MR_createEntityInContext(context)
            
            if cdEvent == nil {
                return nil
            }
            
            cdEvent!.serverID = event.objectId
        }
        
        cdEvent!.address = event.address
        cdEvent!.cost = event.cost
        cdEvent!.descr = event.descr
        cdEvent!.endDate = event.endDate
        cdEvent!.isPrivate = event.isPrivate
        cdEvent!.latitude = event.latitude
        cdEvent!.longitude = event.longitude
        cdEvent!.name = event.name
        cdEvent!.serverID = event.objectId
        cdEvent!.startDate = event.startDate
        cdEvent!.location = event.location
        cdEvent!.address = event.address
        cdEvent!.city = event.city
        
        
        if event.picture != nil {
            cdEvent!.picture = PictureParcer().fetchCoreDataEntity(fromPicture: event.picture!, withContext: context)
        }
        
        if event.organization != nil {
            cdEvent!.organization = OrganizationParcer().fetchCoreDataEntity(fromOrganization: event.organization!, withContext: context)
        }
        
        if event.picture != nil {
            cdEvent!.picture = PictureParcer().fetchCoreDataEntity(fromPicture: event.picture!, withContext: context)
        }
        
        return cdEvent
    }
    
    func fetchBackendlessEntity(fromCDEvent cdEvent: CDEvent) -> RippleEvent {
        let event = RippleEvent()
        event.objectId = cdEvent.serverID
        event.name = cdEvent.name
        event.descr = cdEvent.descr
        event.latitude = cdEvent.latitude!.doubleValue
        event.longitude = cdEvent.longitude!.doubleValue
        event.cost = cdEvent.cost!.doubleValue
        event.startDate = cdEvent.startDate
        event.endDate = cdEvent.endDate
        event.address = cdEvent.address
        event.isPrivate = cdEvent.isPrivate?.boolValue ?? false
        event.location = cdEvent.location
        event.address = cdEvent.address
        event.city = cdEvent.city
        
        if let cdOrganization = cdEvent.organization {
            event.organization = OrganizationParcer().fetchBackendlessEntity(fromCDOrganization: cdOrganization)
        }
        
        if let cdPicture = cdEvent.picture {
            event.picture = PictureParcer().fetchBackendlessEntity(fromCDPicture: cdPicture)
        }
        
        return event
    }
    
}
