//
//  PictureParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class PictureParcer : NSObject {
    
    func fetchCoreDataEntity(fromPicture picture: Pictures, withContext context: NSManagedObjectContext) -> CDPicture? {
        var cdPicture = CDPicture.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: picture.objectId, inContext: context)
        
        if cdPicture == nil {
            cdPicture = CDPicture.MR_createEntityInContext(context)
            
            if cdPicture == nil {
                return nil
            }
            
            cdPicture!.serverID = picture.objectId
        }
        
        cdPicture!.imageUrl = picture.imageURL
        cdPicture!.serverID = picture.objectId
        cdPicture!.storagePath = picture.storagePath
        cdPicture!.userId = picture.userId
        
        if picture.user != nil {
            cdPicture!.user = UserParcer().fetchCoreDataEntity(fromUser: picture.user!, withContext: context)
        }
        
        if picture.owner != nil {
            cdPicture!.owner = OrganizationParcer().fetchCoreDataEntity(fromOrganization: picture.owner!, withContext: context)
        }
        
        return cdPicture
    }
    
    func fetchBackendlessEntity(fromCDPicture cdPicture: CDPicture) -> Pictures {
        let picture = Pictures()
        picture.objectId = cdPicture.serverID
        picture.storagePath = cdPicture.storagePath
        picture.userId = cdPicture.userId
        picture.imageURL = cdPicture.imageUrl
        
        if let cdUser = cdPicture.user {
            picture.user = UserParcer().fetchBackendlessEntity(fromCDUser: cdUser)
        }
        
        if let cdOrganization = cdPicture.owner {
            picture.owner = OrganizationParcer().fetchBackendlessEntity(fromCDOrganization: cdOrganization)
        }
        
        return picture
    }
    
}
