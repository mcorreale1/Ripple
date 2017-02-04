//
//  AppDelegate.swift
//  Ripple
//
//  Created by Adam Gluck on 8/10/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import CoreData
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import SDWebImage
import UserNotifications
import MagicalRecord

let backendlessIDApp = "DF3A760C-9D03-A752-FF65-8BB1D7690900"
let backendlessSecretKey = "D2BF03BC-6005-0614-FF4E-2EDC549F8C00"
let backendlessVersionNumber = "v1"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        initMagicalRecords()
        Backendless.sharedInstance().initApp(backendlessIDApp, secret: backendlessSecretKey, version: backendlessVersionNumber)
        Backendless.sharedInstance().messaging.registerForRemoteNotifications()
        SDWebImageManager.sharedManager().imageCache.maxCacheSize = 30 * 1024 * 1024;
        
        if Backendless.sharedInstance().userService.currentUser?.objectId != nil {
            if(Backendless.sharedInstance().userService.currentUser.name != nil) {
                print("Logging in" + Backendless.sharedInstance().userService.currentUser.name)
            }
            loginComplete()
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        registerForRemoteNotifications()
        print("App did finish with options")
        return true
    }
   
    
    func loginComplete() {
        UserManager().initMe {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController")
            self.window?.rootViewController = mainTabBarController
            self.tabBarSelectIndex(2)
            //self.subscribe()
            //MessagesManager.sharedInstance.subscribeToMyChannel()
            UserManager().followUsersWithConfirmedRequest(withCompletion: {() -> Void in } )
            Backendless.sharedInstance().userService.setPersistentUser()
            print("login complete finished")
        }
        print("UIDevice ID \(UIDevice.currentDevice().identifierForVendor?.description)")
    }
    
    func changeLaguageApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! BaseTabBarViewController
        window?.rootViewController = mainTabBarController
        mainTabBarController.selectedIndex = 4
        let mainNavigationSettingsScreen = mainTabBarController.customizableViewControllers![4] as! UINavigationController
        let settingsMainVC = storyboard.instantiateViewControllerWithIdentifier("MainSettings") as! SettingsMain
        mainNavigationSettingsScreen.viewControllers.append(settingsMainVC)
        settingsMainVC.performSegueWithIdentifier("showChangeLanguage", sender: nil)
    }
    
    func tabBarSelectIndex(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! BaseTabBarViewController
        window?.rootViewController = mainTabBarController
        mainTabBarController.selectedIndex = index
    }
    
    func toLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toLoginTabBarController = storyboard.instantiateViewControllerWithIdentifier("LoginTabBarController")
        window?.rootViewController = toLoginTabBarController
    }
    
    /*func askNotificationsPermissions() {
        if UIApplication.sharedApplication().respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
    }*/

    // MARK: - Push notifications
    
    
    func registerForRemoteNotifications() {
        print("In register for remote")
        if #available(iOS 10.0, *)
        {
           let center = UNUserNotificationCenter.currentNotificationCenter()
            center.delegate = self
            center.requestAuthorizationWithOptions([.Sound,.Alert,.Badge], completionHandler: { (granted, error) in
                if error == nil{
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                }
            })
        }
        else {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
//        Backendless.sharedInstance().messaging.registerForRemoteNotifications() //uncommented
        
        //DEPRECATED Russian Method
        
//        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
//        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//        UIApplication.sharedApplication().registerForRemoteNotifications()
 
    }
    
    

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("registering device with token \(deviceToken)")
        //Backendless.sharedInstance().messaging.registerDeviceToken(deviceToken)
        
//        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            Backendless.sharedInstance().messaging.registerDeviceToken(deviceToken)
//        }

        let responder = Responder.init(responder: self, selResponseHandler: #selector(self.gotDeviceID), selErrorHandler: #selector(MessagesManager.sharedInstance.errorHandler(_:)))
        Backendless.sharedInstance().messagingService.registerDeviceToken(deviceToken, responder: responder)
        print("After register")
        //DEPRECATED Russian Method caused "tried to find something and came back with nil" error
       /* let deviceTokenStr = Backendless.sharedInstance().messaging.deviceTokenAsString(deviceToken)
        Backendless.sharedInstance().messaging.registerDevice([UserManager().currentUser().objectId], expiration: NSDate().addYear(), token: deviceToken, response: { (result) in
            print("Push registration service: deviceToken = " + deviceTokenStr + ", deviceRegistrationId = " + result)
        }) { (fault) in
            print("Push registration service error: deviceToken = " + deviceTokenStr + ", FAULT = " + fault.message)
        } */
    }
    
    func gotDeviceID() {
        print("device registered")
        let deviceID = UserManager().currentUser().deviceID
        if(deviceID == nil || deviceID == " ") {
            print("device ID empty")
            UserManager().currentUser().deviceID = Backendless.sharedInstance().messaging.currentDevice().deviceId
            UserManager().currentUser().save() { [weak self] (success, error) in
                if(success) {
                    print("saved device ID in gotDeviceID")
                }
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Active {
            let localNote = UILocalNotification()
            localNote.userInfo = userInfo
            localNote.soundName = UILocalNotificationDefaultSoundName
            localNote.fireDate = NSDate()
            application.scheduleLocalNotification(localNote)
            
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("Recieved \(notification.request.content.userInfo)")
        completionHandler([.Alert, .Badge, .Sound])
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func initMagicalRecords() {
        MagicalRecord.setupCoreDataStack()
    }

}

