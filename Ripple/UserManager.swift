//
//  UserManager.swift
//  Ripple
//
//  Created by evgeny on 11.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import FBSDKLoginKit

enum TypeFollowingSection: String {
    case Friends = "Friends"
    case Organizations = "Organizations"
}

typealias FollowingRequestDetails = (fromUser: Users, requestID: String)

class UserManager: NSObject {
    
    //keeps track of currently logged in user
    private static var me: Users? = nil
    
    // Returns the Current User from either this class, or sets it from backendless
    // If no current user is set at all, returns a default user class to set current user to
    func currentUser() -> Users {
        if UserManager.me != nil {
            return UserManager.me!
        } else if Backendless.sharedInstance().userService.currentUser != nil {
            return Users.userFromBackendlessUser(Backendless.sharedInstance().userService.currentUser)
        } else {
            return Users()
        }
    }
    
    /*  Initiates the "me" variable
     *  After getting info, calls (completion) function
     */
    func initMe(completion: (Bool) -> Void) {
        UserManager.me = Users.userFromBackendlessUser(Backendless.sharedInstance().userService.currentUser)
        guard let currentUser = UserManager.me else {
            print("currentUser failed to unwrap")
            completion(false)
            return
        }
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["friends", "events", "eventsBlackList", "organizations", "picture"]
        query.queryOptions = queryOptions
        print("Current user: \(currentUser.name) objId: \(currentUser.objectId)")
        query.whereClause = "objectId = '\(currentUser.objectId)'"
        Backendless.sharedInstance().userService.findById(currentUser.objectId, response: {(bUser) in
            if(bUser != nil && bUser.objectId == currentUser.objectId) {
                print("Found bUser")
                UserManager.me?.populateFromBackendlessUser(bUser)
                completion(true)
            } else {
                completion(false)
            }
        }, error: { (fault) in
            print("Fault in initMe: \(fault)")
            completion(false)
        })
    }
    
    /*
     *  All setters call .syncronize() after setting to ensure entire app is up to date
     */
    
    var userPassword :String{
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "keyUserPassword")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let password = NSUserDefaults.standardUserDefaults().objectForKey("keyUserPassword") ?? ""
            return password as! String
        }
    }
    
    var launchedBefore: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let launched = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
            return launched
        }
    }
    
    var seenInvitationsBefore: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "seenInvitationsBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let launched = NSUserDefaults.standardUserDefaults().boolForKey("seenInvitationsBefore")
            return launched
        }
    }

    
    var radiusSearch: Float {
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: "radiusSearch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let radiusSearch = NSUserDefaults.standardUserDefaults().floatForKey("radiusSearch")
            return radiusSearch
        }
    }
    
    func goOnEvent(event: RippleEvent, completion: (Bool) -> Void) {
        var contains = false
        for ev in currentUser().events {
            if ev.objectId == event.objectId {
                contains = true
            }
        }
        if !contains {
            currentUser().events.append(event)
        }
        
        //Check for invites
        InvitationManager().invateThisEventDelete(event)
        currentUser().save( { (success, _) in
            completion(success)
        })
    }
    
    func addEventInBlackList(event: RippleEvent, completion: (Bool) -> Void) {
        let user = currentUser()
        var eventsBlackList = user.eventsBlackList
        
        if !eventsBlackList.contains(event) {
            eventsBlackList.append(event)
        }
        
        //check for invites
        InvitationManager().invateThisEventDelete(event)
        user.eventsBlackList = eventsBlackList
        user.save( { (success, _) in
            completion(success)
        })
    }
    
    //Removes the user from Going to an event
    func unGoOnEvent(event: RippleEvent, completion: (Bool) -> Void)  {
        // hate this part
        Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).findID(currentUser().objectId, relationsDepth: 2, response: { (cUser) in
            let fullCurrentUser = cUser as! BackendlessUser
            
            var events = fullCurrentUser.getProperty("events") as! [BackendlessEntity]
            var removedIndex = -1
            for (index, ev) in events.enumerate() {
                if ev.objectId == event.objectId {
                    events.removeAtIndex(index)
                    removedIndex = index
                    break
                }
            }
            
            if removedIndex > -1 {
                fullCurrentUser.setProperty("events", object: events)
                
                Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).save(fullCurrentUser, response: { (savedUser) in
                    UserManager().currentUser().events.removeAtIndex(removedIndex)
                    completion(true)
                }, error: { (fault) in
                    completion(false)
                })
            } else {
                completion(true)
            }
            
        }) { (fault) in
              completion(false)
        }
    }
    
    //Checks if user is already going to an event
    func alreadyGoOnEvent(event: RippleEvent) -> Bool {
        let events = currentUser().events
        for userEvent in events {
            if userEvent.objectId == event.objectId {
                return true
            }
        }
        return false
    }
    
    /*
     *  Returns a dictionary of orgs and users the requested user is following
     *  After populating list, it calls the completion function on it with no return value
    */
    func followingForUser(user: Users, completion:([Dictionary<String, AnyObject>]) -> Void) {
        var following = [Dictionary<String, AnyObject>]()
        
        var orgIds = [String]()
        for org in user.organizations {
            if org.leaderId != user.objectId {
                orgIds.append(org.objectId)
            }
        }
        
        OrganizationManager().fetchMany(orgIds) { (orgs, error) in
            if error == nil && orgs!.count > 0 {
                let organizations = ["title" : TypeFollowingSection.Organizations.rawValue,
                                     "items" : orgs!]
                following.append(organizations as! Dictionary<String, AnyObject>)
            }
            
            var friendIds = [String]()
            if(user.objectId != UserManager().currentUser().objectId) {
                self.followingUsersForProfile(user) { (friends, error) in
                    if(error == nil && friends != nil) {
                        for friend in friends! {
                            user.friends.append(friend)
                            friendIds.append(friend.objectId)
                        }
                        UserManager().fetchMany(friendIds, completion: { (users, error) in
                            if error == nil && users!.count > 0 {
                                let friends = ["title" : TypeFollowingSection.Friends.rawValue,
                                    "items" : users!]
                                following.append(friends as! Dictionary<String, AnyObject>)
                            }
                            
                            completion(following)
                        })
                    } else {
                        completion(following)
                    }
                }
            } else {
                print("user friend count: \(user.friends.count)")
                for friend in user.friends {
                    friendIds.append(friend.objectId)
                }
            
                UserManager().fetchMany(friendIds, completion: { (users, error) in
                    if error == nil && users!.count > 0 {
                        let friends = ["title" : TypeFollowingSection.Friends.rawValue,
                                        "items" : users!]
                    following.append(friends as! Dictionary<String, AnyObject>)
                    }
                    completion(following)
                })
            }
        }
    }
    
    //Checks if Current user is already following the user
    func alreadyFollowOnUser(user: Users) -> Bool {
        let friends = currentUser().friends
        for friend in friends {
            if friend.objectId == user.objectId {
                return true
            }
        }
        return false
    }
    
    /*  Called when the current user follows a user
     *  Adds to users friends list if not there already
     *  Calls completion with a pass/fail parameter on following user
    */
    func followUser(user: Users, fromUser userFollower: Users? = UserManager().currentUser(), withCompletion completion: (Bool) -> Void) {
        guard let follower = userFollower else {
            completion(false)
            return
        }
        
        var friends = follower.friends
        var needToAdd = true
        for friend in friends {
            if friend.objectId == user.objectId {
                needToAdd = false
            }
        }
        
        if needToAdd {
            friends.append(user)
        }
        
        follower.friends = friends
        follower.save( { (success, error) in
            if (error == nil) {
                completion(true)
            } else {
                print(error)
                completion(false)
            }
        })
    }
    
    func followOnOrganization(organization: Organizations, completion: (Bool) -> Void) {
        
        var organizations = currentUser().organizations
        organizations.append(organization)
        
        currentUser().organizations = organizations
        currentUser().save( { (success, error) in
            if(error == nil) {
                completion(true)
            } else {
                print("Error:\(error)")
                completion(false)
            }
        })
    }
    
    //Unfollows an organization
    func unfollowOnOrganization(organization: Organizations, withCompletion completion: (Bool) -> Void) {
        
        // TODO make it(and unfollow() and ungo()) func with generic type sometime
        Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).findID(currentUser().objectId, relationsDepth: 2, response: { (cUser) in
            let fullCurrentUser = cUser as! BackendlessUser
            
            var organizations = fullCurrentUser.getProperty("organizations") as! [BackendlessEntity]
            var removedIndex = -1
            for (index, org) in organizations.enumerate() {
                if org.objectId == organization.objectId {
                    organizations.removeAtIndex(index)
                    removedIndex = index
                    break
                }
            }
            
            if removedIndex > -1 {
                fullCurrentUser.setProperty("organizations", object: organizations)
                
                Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).save(fullCurrentUser, response: { (savedUser) in
                    var organizations = UserManager().currentUser().organizations
                    if organizations.count > removedIndex {
                        organizations.removeAtIndex(removedIndex)
                        UserManager().currentUser().organizations = organizations
                    }
                    
                    completion(true)
                    }, error: { (fault) in
                        print("error in saving: \(fault)")
                        completion(false)
                })
            } else {
                print("no index")
                completion(false)
            }
            
        }) { (fault) in
            print("fault in getting current user:\(fault)")
            completion(false)
        }
        
        return
        if let index = currentUser().organizations.indexOf({return $0.objectId == organization.objectId}) {
            currentUser().organizations.removeAtIndex(index)
            print("current user orgs: \(currentUser().organizations.description)")
            if let newUser = Backendless.sharedInstance().userService.update(currentUser()) {
                print("saved newUser \(newUser.name)")
                print("new user orgs: \(newUser.getProperty("organizations"))")
                completion(true)
            } else {
                print("User not found")
                completion(false)
            }
        } else {print("cant find org to remove")
            completion(false)
        }
        
        return
        
        
        if let user = Users().dataStore().findID(currentUser().objectId) as? BackendlessUser {
            let currUser = Users()
            currUser.populateFromBackendlessUser(user, friends: false)
            if let index = currUser.organizations.indexOf({return $0.objectId == organization.objectId}) {
                currUser.organizations.removeAtIndex(index)
                currUser.save(){ (success, error) in
                    if(success) {
                        print("Successfully removed")
                        UserManager().currentUser().organizations = currUser.organizations
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                print("cant find org to remove")
                completion(false)
            }
        } else {
            print("User not found")
            completion(false)
        }
        return
//        if var user = Users().dataStore().findID(currentUser().objectId) as? BackendlessUser {
//            let localUser = Users().populateFromBackendlessUser(user, friends: false)
//            if let index = localUser.indexOf({return $0.objectId == organization.objectId}) {
//
//        }
        var orgs = UserManager().currentUser().organizations
        if let index = orgs.indexOf({return $0.objectId == organization.objectId}) {
            print("Found org to unfollow")
            orgs.removeAtIndex(index)
            UserManager().currentUser().organizations = orgs
            UserManager().currentUser().save() { (success, error) in
                if(success) {
                    print("successfully removed org from following")
                    completion(true)
                } else {
                    print("Error unfollowing: \(error)")
                    completion(false)
                }
            }
//            
//            Backendless.sharedInstance().userService.update(UserManager().currentUser(), response: { (backEndUser) in
//                print("successfully removed org from following")
//                completion(true)
//            }, error: { (fault) in
//                    print("User update fault in unfollowOrg: \(fault)")
//                completion(false)
//            })
        } else {
            print("Failed to find org to unfollow")
            completion(false)
        }

    }
    // Gets the list of following requests to current user, then runs the 
    // completion function on that list. If fails, runs completion with error
    func followingRequests(withCompletion completion: ([FollowingRequestDetails]?, NSError?) -> Void) {
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["fromUser"]
        query.queryOptions = options
        query.whereClause = "toUser.objectId = '\(currentUser().objectId)' and isConfirmed = 'false'"
        
        FollowingRequest().dataStore().find(query, response: { (collection) in
            var requests = collection.data as? [FollowingRequest] ?? [FollowingRequest]()
            
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    requests.appendContentsOf(otherPageEvents?.data as? [FollowingRequest] ?? [FollowingRequest]())
                } else {
                    var requestInfoArr = [FollowingRequestDetails]()
                    for request in requests {
                        let requestDetails = FollowingRequestDetails(fromUser: request.fromUser!, requestID: request.objectId)
                        requestInfoArr.append(requestDetails)
                    }
                    completion(requestInfoArr, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    // Removes a user from Current Users follow list
    func unfollow(user: Users, completion: (Bool) -> Void) {
        Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).findID(currentUser().objectId, relationsDepth: 2, response: { (cUser) in
            let fullCurrentUser = cUser as! BackendlessUser
            
            var friends = fullCurrentUser.getProperty("friends") as! [BackendlessUser]
            var removedIndex = -1
            for (index, frind) in friends.enumerate() {
                if frind.objectId == user.objectId {
                    friends.removeAtIndex(index)
                    removedIndex = index
                    break
                }
            }
            
            if removedIndex > -1 {
                fullCurrentUser.setProperty("friends", object: friends)
                
                Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass()).save(fullCurrentUser, response: { (savedUser) in
                    var friends = UserManager().currentUser().friends
                    
                    if friends.count > removedIndex {
                        friends.removeAtIndex(removedIndex)
                        UserManager().currentUser().friends = friends
                    }
                    
                    completion(true)
                }, error: { (fault) in
                    completion(false)
                })
            } else {
                completion(false)
            }
            
        }) { (fault) in
            completion(false)
        }
    }
    
    // Loads a list of 30 users that are not being followed
    // runs completion on these users
    func loadUnfollowUsers(collection: BackendlessCollection?, completion: ([Users]?, BackendlessCollection?, NSError?) -> Void) {
        if collection != nil {
            collection?.nextPageAsync({ (backendlessCollection) in
                let users = UserManager().backendlessUsersToLocalUsers(backendlessCollection.data as? [BackendlessUser] ?? [BackendlessUser]())
                completion(users, backendlessCollection, nil)
            }, error: { (fault) in
                completion([Users](), nil, nil)
            })
            
            return
        }
        
        var friendIds = [String]()
        let userFriends = currentUser().friends
        
        for friend in userFriends {
            friendIds.append(friend.objectId)
        }
        
        friendIds.append(currentUser().objectId)
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["picture"]
        query.whereClause = query.getFieldInArraySQLQuery(field: "objectid", array: friendIds, notModifier: true)
        options.pageSize = 30
        options.sortBy(["name"])
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            let users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            completion(users, collection, nil)
        }, error: { (fault) in
            completion(nil, nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    //Searches for users then runs completion on it
    func searchUsers(searchString: String, completion: ([Users]?, NSError?) -> Void) {
        var friendIds = [String]()
        let userFriends = currentUser().friends
        for friend in userFriends {
            friendIds.append(friend.objectId)
        }
        friendIds.append(currentUser().objectId)
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["organizations", "friends", "events", "picture"]
        query.queryOptions = options
        query.whereClause = "objectId not in ( '" + friendIds.joinWithSeparator("', '") + "') and name LIKE '%" + searchString + "%'"
        let queryOptions = QueryOptions()
        queryOptions.sortBy(["name"])
         queryOptions.related = ["picture"]
        query.queryOptions = queryOptions
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    // Used to follow a user
    // Follows is user is public, sends request if user is private
    func followingOnUser(user: Users, completion: (Bool) -> Void) {
        if !user.isPrivate {
            followUser(user, withCompletion: completion)
        } else {
            sendFollowingRequest(to: user, completion: completion)
        }
    }
    
    //Declines following requrest
    func declineFollowingRequest(withID requestID: String, withCompletion completion: (Bool) -> Void) {
        FollowingRequest().dataStore().removeID(requestID, response: { (_) in
            completion(true)
        }, error:  { (_) in
            completion(false)
        })
    }
    
    //Confirms following request
    func confirmFollowingRequest(withID requestID: String, withCompletion completion: (Bool) -> Void) {
        FollowingRequest().dataStore().findID(requestID, response: { (request) in
            if let followingRequest = request as? FollowingRequest {
                followingRequest.isConfirmed = true
                
                Backendless.sharedInstance().data.of(FollowingRequest.ofClass()).save(followingRequest, response: { (_) in
                    completion(true)
                }, error:  { (_) in
                    completion(false)
                })
                
            } else {
                completion(false)
            }
        }, error:  { (_) in
            completion(false)
        })
    }
    
    //Follows user after confirming request
    func followUsersWithConfirmedRequest(withCompletion completion: () -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "isConfirmed = 'true' and fromUser.objectId = '\(currentUser().objectId)'"
        let options = QueryOptions()
        options.related = ["toUser"]
        query.queryOptions = options
        
        FollowingRequest().dataStore().find(query, response: { (collection) in
            var requests = collection.data as? [FollowingRequest] ?? [FollowingRequest]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    requests.appendContentsOf(otherPageEvents?.data as? [FollowingRequest] ?? [FollowingRequest]())
                } else {
                    var requestsProcessed = 0
                    var requestIds = [String]()
                    
                    for request in requests {
                        requestIds.append(request.objectId)
                        
                        UserManager().followUser(request.toUser!, withCompletion: { (success) in
                            requestsProcessed += 1
                            
                            if requestsProcessed >= requests.count {
                                let queryForDelete = BackendlessDataQuery()
                                queryForDelete.whereClause = "objectId in ( '" + requestIds.joinWithSeparator("', '") + "' )"
                                
                                FollowingRequest().dataStore().removeAll(queryForDelete, response: { (_) in
                                    completion()
                                }, error: { (_) in
                                    completion()
                                })
                            }
                        })
                    }
                }
            })
        }, error: { (fault) in
            
        })
    }
    
    func sendFollowingRequest(to user: Users, completion: (Bool) -> Void) {
        
        func addRequest() {
            // need to check permissions first
            let request = FollowingRequest()
            request.fromUser = currentUser()
            request.toUser = user
            request.isConfirmed = false
            
            
            FollowingRequest().dataStore().save(request, response: { (_) in
                completion(true)
            }, error:  { (_) in
                completion(false)
            })
        }
        
        let query = BackendlessDataQuery()
        query.whereClause = "fromUser.objectId = '\(currentUser().objectId)' and toUser.objectId = '\(user.objectId)'"
        let options = QueryOptions()
        options.pageSize = 1
        
        FollowingRequest().dataStore().find(query, response: { (collection) in
            let requests = collection.data as? [FollowingRequest] ?? [FollowingRequest]()
            if requests.count > 0 {
                completion(true)
            } else {
                addRequest()
            }
        }, error: { (_) in
            completion(false)
        })
    }
    
    func followingUsers(user: Users, completion:([Users]) -> Void) {
        completion(user.friends)
    }
    
    func followingUsersForProfile(user: Users, completion:([Users]?, NSError?) -> Void) {
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        query.whereClause = "name = '\(user.name!)'"
        options.related = ["friends"]
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageCollection?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    var userFriends = [Users]()
                    if(users.count == 0) {
                        completion(userFriends, nil)
                    } else {
                        for friend in users[0].friends {
                            print("friend \(friend.name)")
                            userFriends.append(friend)
                        }
                        completion(userFriends, nil)
                    }
                }
            })
            }, error: { (fault) in
                completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
        
    }
    
    func findUsersByFullName(name: String, completion: ([Users]?, NSError?) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "name = '\(name)'"
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func findUsersToInviteToOrganization(organization: Organizations, searchString:String, completion: ([Users], NSError?) -> Void) {
        var ignoreUsersIds = [String]()
        if let membersOf = organization.getMembersOfUsers() {
            for user in membersOf {
                ignoreUsersIds.append(user.objectId)
            }
        }
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["toUser"]
        query.queryOptions = options
        query.whereClause = "organization.objectId = '\(organization.objectId)' and fromUser.objectId = '\(currentUser().objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invitations = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invitations.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invitation in invitations {
                        if let invatationPeople = invitation.toUser {
                            ignoreUsersIds.append(invatationPeople.objectId)
                        }
                    }
                    UserManager().getUsersWithIgnoreList(ignoreUsersIds, searchString: searchString, completion: completion)
                }
            })
        }, error:  { (fault) in
            completion([Users](), ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func getUsersWithIgnoreList(ignores: [String], searchString:String, completion: ([Users], NSError?) -> Void) {
        let query = BackendlessDataQuery()
        let notInQuery = BackendlessDataQuery().getFieldInArraySQLQuery(field: "objectId", array: ignores, notModifier: true)
        query.whereClause = "name LIKE '%" + searchString + "%'"
        if(notInQuery != "") {
            query.whereClause = query.whereClause + " and \(notInQuery)"
        }
        let queryOptions = QueryOptions()
        queryOptions.related = ["picture"]
        queryOptions.sortBy(["name"])
        query.queryOptions = queryOptions
        print("org where clause: \(query.whereClause)")
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users, nil)
                }
            })
        }, error: { (fault) in
            completion([Users](), ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func getUsersToInviteToEvent(event: RippleEvent, searchString:String, completion:([Users], NSError?) -> Void) {
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["toUser"]
        query.queryOptions = options
        query.whereClause = "event.objectId = '\(event.objectId)' and fromUser.objectId = '\(currentUser().objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invitations = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invitations.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    var ignoreIds =  [String]()
                    for invitation in invitations {
                        if let invitedUser = invitation.toUser {
                            ignoreIds.append(invitedUser.objectId)
                        }
                    }
                    
                    UserManager().getUsersWithIgnoreListAndNotGoingOnEvent(ignoreIds, searchString: searchString, event: event, completion: completion)
                }
            })
        }, error:  { (fault) in
            completion([Users](), ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func getUsersWithIgnoreListAndNotGoingOnEvent(ignoteIds: [String], searchString:String, event: RippleEvent, completion:([Users], NSError?) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "name LIKE '%" + searchString + "%'"
        let notInIgnoreQuery = query.getFieldInArraySQLQuery(field: "objectId", array: ignoteIds, notModifier: true)
        if notInIgnoreQuery != "" {
            query.whereClause = query.whereClause + " and \(notInIgnoreQuery)"
        }
        print("whereClause: \(query.whereClause)")
        let options = QueryOptions()
        options.related = ["picture", "events"]
        options.sortBy(["name"])
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    for user in users {
                        for ev in user.events {
                            if ev.objectId == event.objectId {
                                if let index = users.indexOf(user) {
                                    users.removeAtIndex(index)
                                }
                                break
                            }
                        }
                    }
                    completion(users, nil)
                }
            })
        }, error: { (fault) in
            completion([Users](), ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func fetchMany(ids: [String], completion: ([Users]?, NSError?) -> Void) {
        guard ids.count > 0 else {
            completion([Users](), nil)
            return
        }
        
        let query = BackendlessDataQuery()
        query.whereClause = query.getFieldInArraySQLQuery(field: "objectId", array: ids)
        let options = QueryOptions()
        options.related = ["events", "eventsBlackList", "organizations", "picture"]
        options.sortBy(["name"])
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            print("Users \(users.description)")
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageCollection?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func getUserByIdSync(id: String) -> Users? {
        return Users.userFromBackendlessUser(Users().dataStore().findID(id) as! BackendlessUser)
    }
    
    func sortUsersByFullName(inout users: [Users]) {
        users.sortInPlace { (user1: Users, user2: Users) -> Bool in
            let name1 = user1.name
            let name2 = user2.name
            return name1?.lowercaseString < name2?.lowercaseString
        }
    }
    //Converts backendless user types to local, core data user types
    func backendlessUsersToLocalUsers(bUsers: [BackendlessUser], friends:Bool = true) -> [Users] {
        var users = [Users]()
        var num = 0
        for bUser in bUsers {
            users.append(Users.userFromBackendlessUser(bUser, friends: friends))
            num = num + 1
        }
        return users
    }
}
