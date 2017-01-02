//
//  BackendlessDataQuery+Extended.swift
//  Ripple
//
//  Created by nikitaivanov on 21/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

extension BackendlessDataQuery {
    func getFieldInArraySQLQuery(field field: String, array: [String], notModifier: Bool = false) -> String {
        if array.count > 0 {
            return "\(field) \(notModifier ? "not" : "") in \(getSQLArray(array))"
        } else {
            return ""
        }
    }
    
    func getSQLArray(strings: [String]) -> String {
        if strings.count > 0 {
            return "('" + strings.joinWithSeparator("', '") + "')"
        } else {
            return "()"
        }
    }
}
