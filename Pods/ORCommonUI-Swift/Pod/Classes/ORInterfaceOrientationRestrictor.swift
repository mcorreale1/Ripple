//
//  ORInterfaceOrientationRestrictor.swift
//  Pods
//
//  Created by Maxim Soloviev on 19/05/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import Foundation

public protocol ORInterfaceOrientationRestrictor {
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
}

// add following to AppDelegate

//func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
//    return or_supportedInterfaceOrientations(or_topViewController())
//}

public func or_supportedInterfaceOrientations(vc: UIViewController?) -> UIInterfaceOrientationMask {
    guard let vc = vc, let restrictor = vc as? ORInterfaceOrientationRestrictor else {
        return UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(UIApplication.sharedApplication().keyWindow)
    }
    if vc.isBeingDismissed() {
        return or_supportedInterfaceOrientations(vc.presentingViewController)
    }
    return restrictor.supportedInterfaceOrientations()
}
