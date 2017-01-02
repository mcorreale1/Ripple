//
//  FollowingRequestParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class FollowingRequestParcer : NSObject {
    
    func fetchCoreDataEntity(fromRequest request: FollowingRequest, withContext context: NSManagedObjectContext) -> CDFollowingRequest? {
        var cdFollowingRequest = CDFollowingRequest.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: request.objectId, inContext: context)
        
        if cdFollowingRequest == nil {
            cdFollowingRequest = CDFollowingRequest.MR_createEntityInContext(context)
            
            if cdFollowingRequest == nil {
                return nil
            }
            
            cdFollowingRequest!.serverID = request.objectId
        }
        
        cdFollowingRequest!.isConfirmed = request.isConfirmed
        cdFollowingRequest!.serverID = request.objectId
        
        if request.fromUser != nil {
            cdFollowingRequest!.fromUser = UserParcer().fetchCoreDataEntity(fromUser: request.fromUser!, withContext: context)
        }
        
        if request.toUser != nil {
            cdFollowingRequest!.toUser = UserParcer().fetchCoreDataEntity(fromUser: request.toUser!, withContext: context)
        }
        
        return cdFollowingRequest
    }
    
    func fetchBackendlessEntity(fromCDFollowingRequest cdRequest: CDFollowingRequest) -> FollowingRequest {
        let request = FollowingRequest()
        request.objectId = cdRequest.serverID
        request.isConfirmed = cdRequest.isConfirmed?.boolValue ?? false
        
        if let fromCDUser = cdRequest.fromUser {
            request.fromUser = UserParcer().fetchBackendlessEntity(fromCDUser: fromCDUser)
        }
        
        if let toCDUser = cdRequest.toUser {
            request.toUser = UserParcer().fetchBackendlessEntity(fromCDUser: toCDUser)
        }
        
        return request
    }
}
