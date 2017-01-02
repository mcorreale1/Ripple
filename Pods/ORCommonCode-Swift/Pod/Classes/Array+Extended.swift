//
//  Array+Extended.swift
//  Pods
//
//  Created by Maxim Soloviev on 24/05/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import Foundation

extension Array {
    
    // Returns the first element satisfying the predicate, or `nil`
    // if there is no matching element.
    public func or_findFirstMatching<L : BooleanType>(predicate: Element -> L) -> Element? {
        for item in self {
            if predicate(item) {
                return item // found
            }
        }
        return nil // not found
    }
    
    public func or_limitedBySize(size: Int) -> [Element] {
        if (self.count <= size) {
            return self
        } else {
            return Array(self[0..<size])
        }
    }
}
