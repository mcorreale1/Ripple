//
//  Dictionary+Extended.swift
//  Pods
//
//  Created by Maxim Soloviev on 12/07/16.
//  
//

import Foundation

extension Dictionary {
    
    public func or_dictionaryByAddingValuesFrom(other: Dictionary) -> Dictionary {
        var dict = self
        for (key, value) in other {
            dict.updateValue(value, forKey:key)
        }
        return dict
    }
}
