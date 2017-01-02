//
//  String+Extended.swift
//  Ripple
//
//  Created by nikitaivanov on 21/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

extension String {
    
    func toBackendlessArray() -> [String] {
        let string1 = self.stringByReplacingOccurrencesOfString("\"", withString: "")
        let string2 = string1.stringByReplacingOccurrencesOfString("[", withString: "")
        let string3 = string2.stringByReplacingOccurrencesOfString("]", withString: "")
        let cuttedStr = string3.stringByReplacingOccurrencesOfString(" ", withString: "")
        return cuttedStr.componentsSeparatedByString(",")
    }
    
    func fromBackendlessArray(arr: [String]) -> String {
        return "[\"\(arr.joinWithSeparator(","))\"]"
    }
    
}
