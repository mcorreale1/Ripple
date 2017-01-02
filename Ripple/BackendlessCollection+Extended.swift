//
//  BackendlessCollection+Extended.swift
//  Ripple
//
//  Created by nikitaivanov on 09/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

extension BackendlessCollection {
    
    func loadOtherPages(completion: (BackendlessCollection?) -> Void) {
        self.nextPageAsync({ (nextPageCollection) in
            if (nextPageCollection.data.count > 0) {
                completion(nextPageCollection)
                nextPageCollection.loadOtherPages(completion)
            } else {
                completion(nil)
            }
        }, error: { (fault) in
            completion(nil)
        })
    }
    
}
