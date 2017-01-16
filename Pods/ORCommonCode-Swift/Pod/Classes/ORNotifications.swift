//
//  ORNotifications.swift
//  Pods
//
//  Created by Maxim Soloviev on 16/04/16.
//
//

import Foundation

public func or_addObserver(observer: AnyObject, selector aSelector: Selector, name aName: String?, object anObject: AnyObject? = nil) {
    NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: aName, object: anObject)
}

public func or_removeObserver(observer: AnyObject, name aName: String? = nil, object anObject: AnyObject? = nil) {
    NSNotificationCenter.defaultCenter().removeObserver(observer, name: aName, object: anObject)
}

public func or_postNotification(name: String, object anObject: AnyObject? = nil, userInfo: [NSObject : AnyObject]? = nil) {
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: anObject, userInfo: userInfo)
}
