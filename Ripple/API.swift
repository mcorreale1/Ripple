//
//  API.swift
//  Ripple
//
//  Created by evgeny on 08.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import FBSDKLoginKit

class API: NSObject {
    
    private var backendless = Backendless.sharedInstance()
    
    func loginToApp(userName: String, password: String, completion: (Bool, NSError?) -> Void) {
        
        if userName == "" || password == "" {
            let fault = Fault(message: NSLocalizedString("Please, enter valid credentials", comment: "Please, enter valid credentials"))
            completion(false, ErrorHelper().convertFaultToNSError(fault))
            return
        }
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        
        backendless.userService.login(userName, password: password, response: { (registredUser : BackendlessUser!) -> () in
            UserManager().initMe({
                completion(true,  nil)
            })
        }, error: { (fault : Fault!) -> () in
            completion(false, ErrorHelper().convertFaultToNSError(fault))
        });
    }
    
    func signUp(password: String, email: String, fullName: String, completion: (Bool, NSError?) -> Void) {
        if password == "" || email == "" || fullName.characters.count > 30 || fullName.characters.count < 3 {
            let fault = Fault(message: NSLocalizedString("Pleaseentervalidcredentials", comment: "Pleaseentervalidcredentials"))
            completion(false, ErrorHelper().convertFaultToNSError(fault))
            return
        }
        
        if (password.characters.count < 6) {
            let fault = Fault(message: NSLocalizedString("Your password must contain at least 6 characters", comment: "Your password must contain at least 6 characters"))
            completion(false, ErrorHelper().convertFaultToNSError(fault))
            return
        }
        
        let user = Users()
        user.password = password
        user.email = email.lowercaseString
        user.fullName = fullName
        user.name = fullName
        user.isPrivate = false
        
        backendless.userService.registering(user, response: { (registredUser : BackendlessUser!) -> () in
            self.loginToApp(email, password: password, completion: completion)
        }, error: { (fault : Fault!) -> () in
            completion(false, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func loginToApp(withFacebookToken token: FBSDKAccessToken, completion: (Users!, NSError?) -> Void) {
        
        print("Token string: \(token.expirationDate)")
        func tryToUseFacebookProfileAvatar(forUser user: Users) {
            let params = ["redirect" : false, "type" : "normal"]
            let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: params)
            
            request.startWithCompletionHandler { (connection, result, error) in
                if error != nil {
                    completion(user, ErrorHelper().getNSError(withMessage: "Failed to get facebook profile avatar.".localized()))
                    return
                }
                
                guard let resultDict = result as? [String : AnyObject] else {
                    completion(user, nil)
                    return
                }
                
                guard let dataDict = resultDict["data"] as? [NSObject : AnyObject], let imageURLStr = dataDict["url"] as? String else {
                    completion(user, nil)
                    return
                }
                
                if user.picture != nil {
                    // maybe we should update user picture instead of ignoring?
                    completion(user, nil)
                    return
                }
                
                PictureManager().downloadImage(fromURL: imageURLStr, completion: { (image, error) in
                    if error != nil {
                        completion(user, ErrorHelper().getNSError(withMessage: "Failed to get facebook profile avatar.".localized()))
                        return
                    }
                    
                    let picture = Pictures()
                    picture.imageURL = imageURLStr
                    picture.save({ (entity, error) in
                        if entity != nil {
                            user.picture = picture
                            completion(user, nil)
                        } else {
                            completion(user, ErrorHelper().getNSError(withMessage: "Failed to save facebook profile avatar.".localized()))
                        }
                    })
                })
            }
        }
        
        //WHAT ENABLES AUTO LOGIN
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        //Only gets first name, fix later
        backendless.userService.loginWithFacebookSDK(token, fieldsMapping: ["email" : "email", "first_name": "fullName"], response: { (user: BackendlessUser!) -> Void in
            guard let currentUser = user else {
                completion(nil, ErrorHelper().getNSError(withMessage: "Failed to fetch user".localized()))
                return
            }
            tryToUseFacebookProfileAvatar(forUser: Users.userFromBackendlessUser(currentUser))
        }, error: { (fault: Fault!) -> Void in
                completion(nil, ErrorHelper().convertFaultToNSError(fault))
            
        })
    }
    
    func loginWithFacebook(fromViewController viewController: UIViewController, completion: (Users!, NSError?) -> Void, onCancel : () -> Void) {
        let facebookManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        facebookManager.logOut()
        facebookManager.logInWithReadPermissions(permissions, fromViewController: viewController, handler: { (result, error) in
            if let err = error {
                completion(nil, err)
                return
            }
            
            if !result.isCancelled {
                self.loginToApp(withFacebookToken: result.token, completion: completion)
            } else {
                onCancel()
            }
        })
    }
    
    func resetPassword(forUser: String) {
        backendless.userService.restorePassword(forUser, response: { (any) in }, error:  { (fault) in })
    }
    
    func saveArrayOfEntities(array: [AnyObject], completion: (Bool, NSError?) -> Void) {
        if array.count > 0 {
            var arrayCopy = array
            
            if let objToSave = arrayCopy.popLast() as? BackendlessEntity {
                objToSave.save({ (success, error) in
                    if error != nil {
                        completion(false, error)
                    } else {
                        self.saveArrayOfEntities(arrayCopy, completion: completion)
                    }
                })
            } else if let objToSave = arrayCopy.popLast() as? Users {
                objToSave.save({ (success, error) in
                    if error != nil {
                        completion(false, error)
                    } else {
                        self.saveArrayOfEntities(arrayCopy, completion: completion)
                    }
                })
            } else {
                completion(false, ErrorHelper().getNSError(withCode: 0, withMessage: "save failed : wrong argument type"))
            }
            
        } else {
            completion(true, nil)
        }
    }
    
    func logout() {
        Backendless.sharedInstance().messaging.unregisterDeviceAsync({ (response) in
            Backendless.sharedInstance().userService.logout()
        }) { (fault) in
            Backendless.sharedInstance().userService.logout()
        }
    }
    
    func autoLogin() -> Bool {
        
        let user = Backendless.sharedInstance().userService.getPersistentUser()
        if  user {
            print( "auto logged in \(Backendless.sharedInstance().userService.currentUser.name)")
            return true
        } else {
            print("Auto login failed")
            return false
        }
    }
}
