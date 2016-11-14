//
//  API.swift
//  Ripple
//
//  Created by evgeny on 08.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import Firebase
import ParseFacebookUtilsV4
import ORLocalizationSystem

class API: NSObject {

    var message :String = ""
    func loginToApp(userName: String, password: String, completion: (onLogin: Bool, errorMessage: String) -> Void) {
        if userName == "" || password == ""
        {
            message = NSLocalizedString("Please, enter valid credentials", comment: "Please, enter valid credentials")
            completion(onLogin: false, errorMessage: message)
        }
        
        PFUser.logInWithUsernameInBackground(userName.lowercaseString, password: password, block: { (user, error) -> Void in
            if user != nil {
                //логинация
//                let userFB = FIRAuth.auth()?.currentUser
                FIRAuth.auth()?.signInWithEmail(userName, password: password) { (userFB,  error) in
                    if let error = error{
                        if (error.localizedDescription == "invalid login parameters" ){
                            print("Please, enter valid credentials")
                        }
                        else {
                            print("Error: " + error.localizedDescription)
                        }
                        completion(onLogin: false, errorMessage: "")
                    }
                    else {
                        print("login")
                        completion(onLogin: true, errorMessage: "")
                    }
                }
                
                //completion(onLogin: true, errorMessage: "")
            } else {
                if var errorString = error!.userInfo["error"] as? String {
                    if errorString ==  "invalid login parameters" {
                        errorString = "Please, enter valid credentials"
                    }
                    completion(onLogin: false, errorMessage: errorString)
                }
            }
        })
    }
    
    func signUp(password: String, email: String, fullName: String, completion: (signUpComplete: Bool, errorMessage: String) -> Void) {
        if password == "" || email == "" || fullName == "" || fullName.characters.count > 30 || fullName.characters.count < 3 {
            message = NSLocalizedString("Pleaseentervalidcredentials", comment: "Pleaseentervalidcredentials")
            completion(signUpComplete: false, errorMessage: message)
            return
        }
        if (password.characters.count < 6)
        {
            message = NSLocalizedString("Your password must contain at least 6 characters", comment: "Your password must contain at least 6 characters")
            completion(signUpComplete: false, errorMessage: message)
            return
        }
        
        let user = PFUser()
        user.username = email.lowercaseString
        user.password = password
        user.email = email.lowercaseString
        user["fullName"] = fullName
        user["distance"] = 5
        user["isPrivate"] = false
        user["organizations"] = [PFObject]()
        user["events"] = [PFObject]()
        user["friends"] = [PFObject]()
        user["eventsBlackList"] = [PFObject]()
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                //регистрация
                FIRAuth.auth()?.createUserWithEmail(user.username!, password: user.password!) { (user, error) in
                    if let error = error {
                        completion(signUpComplete: false, errorMessage: error.localizedDescription)
                        return
                    }
                }
                completion(signUpComplete: true, errorMessage: "")
            } else {
                if let errorMessageString = error!.userInfo["error"] as? String {
                    completion(signUpComplete: false, errorMessage: errorMessageString)
                } else {
                    self.message = NSLocalizedString("Pleasetryagainlater", comment: "Pleaseentervalidcredentials")
                    completion(signUpComplete: false, errorMessage: self.message)
                }
            }
        }
    }
    

    // MARK: - Events
    
    func eventsWithUser(user: PFUser, completion: ([PFObject]?, NSError?) -> Void) {
        let tempIds = user["EventIds"]
        let query = PFQuery(className: "Events")
        query.includeKeys(["organization"])
        
        if (tempIds != nil) {
            query.whereKey("objectId", containedIn: tempIds as! [AnyObject])
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    completion (results, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func nameOrgsEvents(completion: ([String]?, NSError?) -> Void) {
        let query = PFUser.query()!
        query.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results  {
                    if result["OrgsFollowing"] != nil {
                        let tempData = result["OrgsFollowing"] as! [String]
                        let query3 = PFQuery(className:"Events")
                        query3.whereKey("OrgId", containedIn: tempData)
                        query3.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            var nameEvents = [String]()
                            if let users = objects {
                                for cool in users {
                                    let name = String(cool["name"])
                                    nameEvents.append(name)
                                }
                            }
                            completion(nameEvents, nil)
                        })
                    } else {
                        completion(nil, nil)
                    }
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func eventsInLocation(userLocation: CLLocation, completion: ([String]?, NSError?) -> Void) {
        let geoLoc = PFGeoPoint(location: userLocation)
        let queryLocation = PFUser.query()
        queryLocation?.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        queryLocation!.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results  {
                    if result["distance"] == nil {
                        result["distance"] = 5
                    }
                    let radius = result["distance"] as! Double
                    let query = PFQuery(className: "Events")
                    query.includeKeys(["organization"])
                    query.whereKey("location", nearGeoPoint: geoLoc, withinMiles: radius) //change 5 to settings
                    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                        var eventNames = [String]()
                        
                        if let results = results {
                            for result in results {
                                let name = String(result["name"])
                                eventNames.append(name)
                            }
                        }
                        completion(eventNames, nil)
                    }
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func eventsFriends(completion: ([String]?, NSError?) -> Void) {
        let query = PFUser.query()!
        query.whereKey("accepted", equalTo: PFUser.currentUser()!.objectId!)
        
        if PFUser.currentUser()!["accepted"] != nil {
            query.whereKey("objectId", containedIn: PFUser.currentUser()?["accepted"] as! [String])
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    for result in results as! [PFUser] {
                        if result["EventIds"] != nil {
                            let tempData = result["EventIds"] as! [String]
                            
                            let query3 = PFQuery(className:"Events")
                            query3.whereKey("objectId", containedIn: tempData)
                            query3.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                var nameEvents = [String]()
                                
                                if let users = objects {
                                    for cool in users {
                                        let name = cool["name"] as! String
                                        nameEvents.append(name)
                                    }
                                }
                                completion(nameEvents, nil)
                            })
                        }
                    }
                } else {
                    completion(nil, nil)
                }
            }
        } else {
            completion(nil, nil)
        }
    }
    
    func allEvents(completion: ([PFObject]?, NSError?) -> Void) {
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let users = objects {
                for object in users {
                    let tempIds = object["EventIds"]
                    let queryEvents = PFQuery(className: "Events")
                    query?.includeKeys(["organization"])
                    if (tempIds != nil) {
                        queryEvents.whereKey("objectId", containedIn: tempIds as! [AnyObject])
                        queryEvents.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                            completion(results, nil)
                        }
                    } else {
                        completion(nil, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        })
    }
    
    func eventsInvitedPeopleNames(completion: ([String]?, NSError?) -> Void) {
        let query = PFQuery(className: "Events")
        query.includeKeys(["organization"])
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results  {
                    if let EventInvites = result["InvitedPeople"] as? [String] {
                        var userNames = [String]()
                        let name = result["name"] as! String
                        if EventInvites.contains((PFUser.currentUser()?.objectId)!) {
                            userNames.append(name)
                        }
                        completion(userNames, nil)
                    } else {
                        completion(nil, nil)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func createEvent(newEvent: PFObject, completion: (success: Bool, errorMessage: String?) -> Void) {
        if String(newEvent["name"]) == "" || String(newEvent["address"]) == "" || String(newEvent["city"]) == "" || String(newEvent["state"]) == "" || String(newEvent["theme"]) == "" {
            message = NSLocalizedString("Pleaseentervalidcredentials", comment: "Pleaseentervalidcredentials")
            completion(success: false, errorMessage: message)
        } else {
            newEvent.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    completion(success: true, errorMessage: nil)
                } else {
                    self.message = NSLocalizedString("Couldnotcreateevent.Pleasetryagainlater", comment: "Couldnotcreateevent.Pleasetryagainlater")
                    completion(success: true, errorMessage: self.message)
                }
            }
        }
    }
    
    func eventsInOrganization(organization: PFObject, completion: ([PFObject]?, NSError?) -> Void) {
        let query = PFQuery(className: "Events")
        query.includeKeys(["organization"])
        query.whereKey("OrgId", equalTo: organization.objectId!)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            completion(results, error)
        }
    }
    
    // MARK: - Users
    
    func friendsWithUser(user: PFUser, completion: ([PFUser]?, NSError?) -> Void) {
        if user["accepted"] != nil {
            let query = PFUser.query()!
            query.whereKey("accepted", equalTo: user.objectId!)
            query.whereKey("objectId", containedIn: user["accepted"] as! [String])
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                let friends = results as! [PFUser]
                completion(friends, error)
            }
        } else {
            completion(nil, nil)
        }
    }
    
    func inviteUsers(completion: ([PFUser]?, NSError?) -> Void) {
        let query = PFUser.query()
        query?.whereKey("accepted", equalTo: (PFUser.currentUser()?.objectId)!)
        
        if PFUser.currentUser()!["accepeted"] != nil {
            query!.whereKey("objectId", notContainedIn: PFUser.currentUser()?["accepted"] as! [String])
        }
        if PFUser.currentUser()!["rejected"] != nil {
            query!.whereKey("objectId", notContainedIn: PFUser.currentUser()!["rejected"] as! [String])
        }
        
        query!.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let users = results as? [PFUser] {
                completion(users, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func usersInOrganization(organization: PFObject, completion: ([PFUser]?, NSError?) -> Void) {
        if organization["memberIds"] != nil {
            let memberIds = organization["memberIds"] as! [String]
            
            let query = PFUser.query()
            query!.whereKey("objectId", containedIn:memberIds)
            query!.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let users = results as? [PFUser] {
                    completion(users, nil)
                } else {
                    completion(nil, error)
                }
            }
        } else {
            completion([PFUser](), nil)
        }
    }
    
    func usersByArrayId(arrayId: [String], completion: ([PFUser]?, NSError?) -> Void) {
        let query = PFUser.query()
        query!.whereKey("objectId", containedIn:arrayId)
        query!.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let users = results as? [PFUser] {
                completion(users, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Organizations
    
    func organizationInvites(completion: ([PFObject]?, NSError?) -> Void) {
        let query = PFQuery(className: "Organizations")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results  {
                    if let temp = result["memberIds"] as? [String] {
                        if let temp2 = result["RejectedMemberIds"] as? [String] {
                            if (temp.contains((PFUser.currentUser()?.objectId)!) == false ) {
                                if (temp2.contains((PFUser.currentUser()?.objectId)!) == false ) {
                                    var organizationInvites = [String]()
                                    var organizations = [PFObject]()
                                    
                                    if result["memberInvitesIds"] != nil {
                                        organizationInvites = result["memberInviteIds"] as! [String]
                                    }
                                    
                                    if (organizationInvites.contains((PFUser.currentUser()?.objectId)!)) {
                                        organizations.append(result)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func creteOrganization(organization: PFObject, completion: (success: Bool, errorMessage: String?) -> Void) {
        if String(organization["name"]) == "" || String(organization["address"]) == "" || String(organization["city"]) == "" || String(organization["state"]) == "" || String(organization["GreekLife"]) == "" || String(organization["info"]) == "" {
            message = NSLocalizedString("Pleaseentervalidcredentials", comment: "Pleaseentervalidcredentials")
            completion(success: false, errorMessage: message)
            return
        }
        
        organization.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                completion(success: true, errorMessage: nil)
            } else {
                self.message = NSLocalizedString("Pleasetryagainlater", comment: "Pleasetryagainlater")
                completion(success: false, errorMessage: self.message)
            }
        }
    }
}
