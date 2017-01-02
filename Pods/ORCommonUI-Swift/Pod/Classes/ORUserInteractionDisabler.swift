//
//  ORUserInteractionDisabler.swift
//  Pods
//
//  Created by Maxim Soloviev on 11/05/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import Foundation
import UIKit

public class ORUserInteractionDisabler {
    
    public static let sharedInstance = ORUserInteractionDisabler()
    private var enablingTimer: NSTimer?

    private init() {
    }
    
    public func disableInteractions(onTime duration: NSTimeInterval) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        enablingTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(enableInteractions), userInfo: nil, repeats: false)
    }
    
    @objc public func enableInteractions() {
        enablingTimer?.invalidate()
        enablingTimer = nil
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
}
