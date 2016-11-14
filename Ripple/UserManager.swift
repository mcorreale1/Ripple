//
//  UserManager.swift
//  Ripple
//
//  Created by evgeny on 11.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import Firebase

enum TypeFollowingSection: String {
    case Friends = "Friends"
    case Organizations = "Organizations"
}

typealias FollowingRequestDetails = (fromUser: PFUser, requestID: String)

class UserManager: NSObject {
    
    func currentUser() -> PFUser {
        return PFUser.currentUser()!
    }
    
    var userPassword :String{
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "keyUserPassword")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let password = NSUserDefaults.standardUserDefaults().objectForKey("keyUserPassword") ?? ""
            return password as! String
        }
    }
    
    var launchedBefore: Bool{
        set{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            let launched = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
            return launched
        }
    }
    
    var radiusSearch: Float{
        set{
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: "radiusSearch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            let radiusSearch = NSUserDefaults.standardUserDefaults().floatForKey("radiusSearch")
            return radiusSearch
        }
    }
    
    func goOnEvent(event: PFObject, completion: (success: Bool) -> Void) {
        let user = currentUser()
        var events = user["events"] as? [PFObject]
        
        if events == nil {
            events = [PFObject]()
        }
        if !events!.contains(event) {
            events!.append(event)
        }
        //проверка на инвайты
        InvitationManager().invateThisEventDelete(event)
        user["events"] = events
        user.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func addEventInBlackList(event: PFObject, completion: (success: Bool) -> Void) {
        let user = currentUser()
        var eventsBlackList = user["eventsBlackList"] as? [PFObject]
        
        if eventsBlackList == nil {
            eventsBlackList = [PFObject]()
        }
        if !eventsBlackList!.contains(event) {
            eventsBlackList!.append(event)
        }
        //проверка на инвайты
        InvitationManager().invateThisEventDelete(event)
        user["eventsBlackList"] = eventsBlackList
        user.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    
    func unGoOnEvent(event: PFObject, completion: (success: Bool) -> Void)  {
        let user = currentUser()
        var events = user["events"] as? [PFObject]
        
        if events == nil {
            events = [PFObject]()
        }
        
        if let foundIndex = events!.indexOf(event){
            events?.removeAtIndex(foundIndex)
            user["events"] = events
            user.saveInBackgroundWithBlock { (success, error) in
                completion(success: success)}
        }
    }
    
    func alreadyGoOnEvent(event: PFObject) -> Bool {
        let events = currentUser()["events"] as! [PFObject]
        let searchPredicate = NSPredicate(format: "objectId == %@", event.objectId!)
        let array = (events as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        return array.count > 0
    }
    func followingUser(user: PFUser, completion: ([PFUser]) -> Void) {
        if var friendsUser = user["friends"] as? [PFUser] {
            if friendsUser.count > 0 {
                for friend in friendsUser {
                    do {
                        //FIXME: make asynchronous
                        try friend.fetchIfNeeded()
                    } catch {
                        if let indexObject = friendsUser.indexOf(friend)
                        {
                            friendsUser.removeAtIndex(indexObject)
                        }
                        print("Error fetch friend")
                    }
                }
                completion(friendsUser)
            }
        }
    }

    func followingForUser(user: PFUser, completion:([Dictionary<String, AnyObject>]) -> Void) {
        var following = [Dictionary<String, AnyObject>]()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            OrganizationManager().organizationForUser(user, completion: { (org1) in
                var org = org1
                if org.count > 0 {
                    // need sorting orgs
                    org.sortInPlace { (org1: PFObject, org2: PFObject) -> Bool in
                        let name1 = org1["name"] as? String
                        let name2 = org2["name"] as? String
                        return name1?.lowercaseString < name2?.lowercaseString
                    }
                    let organizations = ["title" : TypeFollowingSection.Organizations.rawValue,
                                         "items" : org]
                    following.append(organizations as! Dictionary<String, AnyObject>)
                }
                            if var friendsUser = user["friends"] as? [PFObject] {
                                if friendsUser.count > 0 {
                                    for friend in friendsUser {
                                        do {
                                            try friend.fetchIfNeeded() as! PFUser
                                        } catch {
                                            if let indexObject = friendsUser.indexOf(friend)
                                            {
                                                friendsUser.removeAtIndex(indexObject)
                                            }
                                            print("Error fetch friend")
                                        }
                                    }
                                    // need sorting friends
                                    friendsUser.sortInPlace { (friendds1: PFObject, friendds2: PFObject) -> Bool in
                                        let name1 = friendds1["fullName"] as? String
                                        let name2 = friendds2["fullName"] as? String
                                        return name1?.lowercaseString < name2?.lowercaseString
                                    }
                                    let friends = ["title" : TypeFollowingSection.Friends.rawValue,
                                                   "items" : friendsUser]
                                    following.append(friends as! Dictionary<String, AnyObject>)
                                }
                            }
                dispatch_async(dispatch_get_main_queue()) {
                    completion(following)
                }
            })
        }
    }
    
    func alreadyFollowOnUser(user: PFUser) -> Bool {
        let friends = currentUser()["friends"] as! [PFObject]
        let searchPredicate = NSPredicate(format: "objectId == %@", user.objectId!)
        let array = (friends as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        return array.count > 0
    }
    
    func followUser(user: PFUser, fromUser userFollower: PFUser? = PFUser.currentUser(), withCompletion completion: ((success: Bool) -> Void)?) {
        guard let follower = userFollower else {
            completion?(success: false)
            return
        }
        
        if var friends = follower["friends"] as? [PFObject] {
            friends.append(user)
            follower["friends"] = friends
            follower.saveInBackgroundWithBlock({ (success, error) in
                if(error == nil) {
                    completion?(success: true)
                } else {
                    print(error)
                    completion?(success: false)
                }
            })
        } else {
            completion?(success: false)
        }
    }
    
    func followingRequests(withCompletion completion: ((requests: [FollowingRequestDetails]?, error: NSError?) -> Void)?) {
        let query = PFQuery(className: "FollowingRequest")
        query.whereKey("toUser", equalTo: PFUser.currentUser()!)
        query.whereKey("isConfirmed", equalTo: false)
        query.includeKey("fromUser")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let err = error {
                completion?(requests: nil, error: err)
                return
            }
            
            var requestInfoArr: [FollowingRequestDetails] = []
            
            for obj in objects! {
                let requestDetails = (fromUser: obj["fromUser"] as! PFUser, requestID: obj.objectId!)
                requestInfoArr.append(requestDetails)
            }
            
            completion?(requests: requestInfoArr, error: nil)
        }
    }
    
    func unfollow(user: PFUser, object: PFObject, completion: (success: Bool) -> Void) {
        var followings = user["friends"] as! [PFObject]
        
        if let foundIndex = followings.indexOf(object) {
            followings.removeAtIndex(foundIndex)
            user["friends"] = followings
            user.saveInBackgroundWithBlock({ (result, error) in
                if !result {
                    print(error?.description)
                }
                completion(success: result)
            })
        } else {
            completion(success: false)
        }
    }
    
    func allUnfollowUsers(completion: ([PFUser]?, NSError?) -> Void) {
        let query = PFUser.query()!
        var friendIds = [String]()
        
        for friend in UserManager().currentUser()["friends"] as! [PFObject] {
            friendIds.append(friend.objectId!)
        }
        friendIds.append(UserManager().currentUser().objectId!)
        query.whereKey("objectId", notContainedIn: friendIds)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let friends = results as? [PFUser] {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    for friend in friends {
                        do {
                            try friend.fetchIfNeeded()
                        } catch {
                            print("Error fetch friend")
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(friends, error)
                    }
                })
            } else {
                completion(nil, error)
            }
        }
    }
    
    func followingOnUser(user: PFUser, completion: (success: Bool) -> Void) {
        if let isPrivateUser = user["isPrivate"] as? Bool {
            if !isPrivateUser {
                followUser(user, withCompletion: completion)
            } else {
                sendFollowingRequest(to: user, completion: completion)
            }
        } else {
            InvitationManager().sendInvitationOnFollow(user, completion: { (success) in
                completion(success: success)
            })
        }
    }
    
    func declineFollowingRequest(withID requestID: String, withCompletion completion: ((success: Bool) -> Void)?) {
        let query = PFQuery(className: "FollowingRequest")
        query.whereKey("objectId", equalTo: requestID)
        
        query.getFirstObjectInBackgroundWithBlock { [weak self] (obj, error) in
            
            guard self != nil else {
                return
            }
            
            if nil != error {
                completion?(success: false)
                return
            }
            if let obj = obj {
                obj.deleteInBackgroundWithBlock({ (success, error) in
                    completion?(success: success)
                })
            } else {
                completion?(success: true)
            }
        }
    }
    
    func confirmFollowingRequest(withID requestID: String, withCompletion completion: ((success: Bool) -> Void)?) {
        let query = PFQuery(className: "FollowingRequest")
        query.whereKey("objectId", equalTo: requestID)
        
        query.getFirstObjectInBackgroundWithBlock { [weak self] (obj, error) in
            
            guard self != nil else {
                return
            }
            
            if nil != error {
                completion?(success: false)
                return
            }
            
            obj!["isConfirmed"] = true
            
            obj!.saveInBackgroundWithBlock({ (success, error) in
                completion?(success: success)
            })
        }
    }
    
    func followUsersWithConfirmedRequest(withCompletion completion: (() -> Void)?) {
        guard let currentUser = PFUser.currentUser() else {
            return
        }
        
        let query = PFQuery(className: "FollowingRequest")
        query.whereKey("isConfirmed", equalTo: true)
        query.whereKey("fromUser", equalTo: currentUser)
        
        query.findObjectsInBackgroundWithBlock { [weak self] (objects, error) in
            if error != nil || objects == nil {
                return
            }
            
            var requestsProcessed = 0
            let followingCompletion = { (success: Bool) in
                requestsProcessed += 1
                
                if requestsProcessed >= objects!.count {
                    PFObject.deleteAllInBackground(objects, block: { (success, error) in
                        completion?()
                    })
                }
            }
            
            for obj in objects! {
                let toUser = obj["toUser"] as! PFUser
                self!.followUser(toUser, withCompletion: followingCompletion)
            }
        }
    }
    
    func sendFollowingRequest(to user: PFUser, completion: ((success: Bool) -> Void)?) {
        guard let currentUser = PFUser.currentUser() else {
            completion?(success: false)
            return
        }
        
        func addRequest() {
            let acl = PFACL(user: user)
            acl.setReadAccess(true, forUser: user)
            acl.setWriteAccess(true, forUser: user)
            acl.setReadAccess(true, forUser: currentUser)
            acl.setWriteAccess(true, forUser: currentUser)
            
            let request = PFObject(className: "FollowingRequest")
            request.ACL = acl
            request["fromUser"] = currentUser
            request["toUser"] = user
            request["isConfirmed"] = false
            
            request.saveInBackgroundWithBlock { (saved, error) in
                completion?(success: saved)
            }
        }
        
        let query = PFQuery(className: "FollowingRequest")
        query.whereKey("fromUser", equalTo: currentUser)
        query.whereKey("toUser", equalTo: user)
        
        query.getFirstObjectInBackgroundWithBlock { (obj, error) in
            if nil != error && error!.code != 101 {
                completion?(success: false)
                return
            }
            
            if obj != nil {
                completion?(success: true)
                return
            } else {
                addRequest()
            }
        }
    }
    
    func followingUsers(user: PFUser, completion:([PFUser]) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let friends = user["friends"] as! [PFUser]
            for friend in friends {
                do {
                    try friend.fetchIfNeeded()
                } catch {
                    print("Error fetch friend")
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(friends)
            }
        }
    }
    
    func getUser(userIds: [String], organization: PFObject, completion:([PFUser]) -> Void){
        let query = PFUser.query()!
        
        if organization.objectId != nil {
            query.whereKey("organizations", notContainedIn: [organization])
        }
        query.whereKey("objectId", notContainedIn: userIds)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (result, error) in
            if error == nil {
               completion(result as! [PFUser])
            } else {
                print("Error: ", error)
                completion([PFUser]())
            }
        }
    }
    
    func getInvitationOrganization(organization: PFObject, completion:([PFUser]) -> Void) {
        var userIds =  [String]()
        
        if organization.objectId == nil {
            UserManager().getUser(userIds, organization: organization, completion: { (result) in
                var user = result
                user.sortInPlace { (friendds1: PFObject, friendds2: PFObject) -> Bool in
                    let name1 = friendds1["fullName"] as? String
                    let name2 = friendds2["fullName"] as? String
                    return name1?.lowercaseString < name2?.lowercaseString
                }
                completion(user)
            })
            return
        }
        
        let query = PFQuery(className: "Invitation")
        query.whereKey("organization", equalTo: organization)
        query.whereKey("fromUser", equalTo: currentUser())
        query.includeKey("toUser")
        
        if organization["members"] != nil {
            for user in (organization["members"] as?  [String])! {
                userIds.append(user)
            }
        }
        query.findObjectsInBackgroundWithBlock {(results, error)   in
            if error == nil {
                if results != nil {
                    for result in results! {
                        if let invatationPeople = result["toUser"] as? PFUser {
                            userIds.append(invatationPeople.objectId ?? "")
                        }
                    }
                }
                
                UserManager().getUser(userIds, organization: organization, completion: { (result) in
                    var user = result
                    user.sortInPlace { (friendds1: PFObject, friendds2: PFObject) -> Bool in
                        let name1 = friendds1["fullName"] as? String
                        let name2 = friendds2["fullName"] as? String
                        return name1?.lowercaseString < name2?.lowercaseString
                    }
                    completion(user)
                })
            } else {
                print("Error: ", error)
                completion([PFUser]())
            }
        }
    }
    
    func getUserGoingEvent(userIds: [String], event: PFObject, completion:([PFUser]) -> Void){
        let query = PFUser.query()!
        query.whereKey("events", notContainedIn: [event])
        query.whereKey("objectId", notContainedIn: userIds)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (result, error) in
            if error == nil {
                completion(result as! [PFUser])
            } else {
                print("Error: ", error)
                completion([PFUser]())
            }
        }
    }
    
    func getUserEvent(event: PFObject, completion:([PFUser]) -> Void) {
        let query = PFQuery(className: "Invitation")
        query.whereKey("event", equalTo: event)
        query.whereKey("fromUser", equalTo: currentUser())
        query.includeKey("toUser")
        var userIds =  [String]()
        query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
            if error == nil {
                for result in results! as[PFObject] {
                    if let invatationPeople = result["toUser"] as? PFUser {
                        userIds.append(invatationPeople.objectId ?? "")
                    }
                }
                UserManager().getUserGoingEvent(userIds, event: event, completion: { (result) in
                    var user = result
                    user.sortInPlace { (friendds1: PFObject, friendds2: PFObject) -> Bool in
                        let name1 = friendds1["fullName"] as? String
                        let name2 = friendds2["fullName"] as? String
                        return name1?.lowercaseString < name2?.lowercaseString
                    }
                    completion(user)
                })
            } else {
                print("Error: ", error)
                completion([PFUser]())
            }
        }

    }
    
    
}
