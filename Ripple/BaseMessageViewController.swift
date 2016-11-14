//
//  BaseMessageViewController.swift
//  Ripple
//
//  Created by Maxim Soloviev on 21/10/2016.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import Firebase

class BaseMessageViewController: BaseViewController {
    
    struct DatabaseHandlerInfo {
        let query: FIRDatabaseQuery
        let handlerId: FIRDatabaseHandle
    }
    
    var databaseHandlerList = [DatabaseHandlerInfo]()
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    deinit {
        for databaseHandler in databaseHandlerList {
            databaseHandler.query.removeObserverWithHandle(databaseHandler.handlerId)
        }
    }
}
