//
//  BackendlessEntity+Extended.swift
//  Ripple
//
//  Created by nikitaivanov on 12/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import UIKit

extension BackendlessEntity {
    
    func dataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(ofClass())
    }
    
    func delete(completion: (Bool) -> Void) {
        dataStore().removeID(objectId, response: { (_) in
            completion(true)
        }, error: { (_) in
            completion(false)
        })
    }
    
    func fetch<T: BackendlessEntity>() -> T? {
        if let data = dataStore().findID(objectId) {
            if let rippleEntity = data as? T {
                return rippleEntity
            }
        }
        return nil
    }
    
    func fetchAsync(completion: (BackendlessEntity?, NSError?) -> Void) {
        dataStore().findID(objectId, response: { (object) in
            completion(object as? BackendlessEntity? ?? nil, nil)
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func save(completion: (BackendlessEntity?, NSError?) -> Void) {
        dataStore().save(self, response: { (entity) in
            completion(entity as? BackendlessEntity, nil)
        }, error:  { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
}
