//
//  BackendlessErrorHandler.swift
//  Ripple
//
//  Created by nikitaivanov on 06/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class ErrorHelper : NSObject {
    
    func convertFaultToNSError (fault: Fault) -> NSError {
        let codeNumber = NSNumberFormatter().numberFromString(fault.faultCode) ?? NSNumberFormatter().numberFromString("0")
        let userInfo: NSDictionary = [
            NSLocalizedDescriptionKey: fault.message ?? "No message",
            NSLocalizedFailureReasonErrorKey: fault.faultCode ?? "0",
            NSLocalizedRecoverySuggestionErrorKey: fault.detail ?? "No details"
        ]
        return NSError(domain: NSCocoaErrorDomain, code: (codeNumber?.integerValue)!, userInfo: userInfo as [NSObject : AnyObject])
    }
    
    func getNSError(withCode code: Int = 0, withMessage message: String = "No message", withDetail detail: String = "No details") -> NSError {
        let userInfo: NSDictionary = [
            NSLocalizedDescriptionKey: message,
            NSLocalizedFailureReasonErrorKey: NSNumberFormatter().stringFromNumber(code) ?? "0",
            NSLocalizedRecoverySuggestionErrorKey: detail
        ]
        return NSError(domain: NSCocoaErrorDomain, code: code, userInfo: userInfo as [NSObject : AnyObject])
    }
}
