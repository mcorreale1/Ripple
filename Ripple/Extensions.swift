//
//  Extensions.swift
//  Ripple
//
//  Created by Nikita Egoshin on 9/23/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    static func unique() -> String {
        let uuid = NSUUID().UUIDString
        return uuid.stringByReplacingOccurrencesOfString("-", withString: "")
    }
}

extension UIAlertController {
    func addAction(withTitle title: String, style: UIAlertActionStyle = .Default, handler: ((action: UIAlertAction) -> Void)? = nil) {
        let act = UIAlertAction(title: title, style: style, handler: handler)
        self.addAction(act)
    }
    
    func addCancelAction(withTitle title: String, handler: ((action: UIAlertAction) -> Void)? = nil) {
        addAction(withTitle: title, style: .Cancel, handler: handler)
    }
    
    func addDestructiveAction(withTitle title: String, handler: ((action: UIAlertAction) -> Void)? = nil) {
        addAction(withTitle: title, style: .Destructive, handler: handler)
    }
}
