//
//  UIViewController+Alert.swift
//  Pods
//
//  Created by Maxim Soloviev on 06/04/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public typealias ActionBlock = (action: UIAlertAction) -> Void
    
    public func or_showAlert(title title: String?, message: String, buttonTitle: String = "OK", actionBlock: ActionBlock? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertVC.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Cancel, handler: actionBlock))
        
        presentViewController(alertVC, animated: true, completion: nil)
    }
}
