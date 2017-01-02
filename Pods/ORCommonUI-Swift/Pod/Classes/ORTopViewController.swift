//
//  ORTopViewController.swift
//  Pods
//
//  Created by Maxim Soloviev on 19/05/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

public func or_topViewController() -> UIViewController? {
    if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
        return or_topViewControllerWithRootViewController(rootViewController)
    }
    return nil
}

public func or_topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
    if let tabBarController = rootViewController as? UITabBarController {
        return or_topViewControllerWithRootViewController(tabBarController.selectedViewController)
    } else if let navigationController = rootViewController as? UINavigationController {
        return or_topViewControllerWithRootViewController(navigationController.visibleViewController)
    } else if let presentedViewController = rootViewController?.presentedViewController {
        return or_topViewControllerWithRootViewController(presentedViewController)
    } else {
        return rootViewController
    }
}
