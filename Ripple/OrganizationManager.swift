//
//  OrganizationManager.swift
//  Ripple
//
//  Created by evgeny on 27.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

enum TypeRoleUserInOrganization: String {
    case Founder = "Founder"
    case Member = "Member"
    case None = "None"
    case Admin = "Admin"
    case Follower = "Follower"
}

class OrganizationManager: NSObject {

    func organizationForUser(user: Users, completion:[Organizations] -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "members like '%\(user.objectId)%'"
        let options = QueryOptions()
        options.related = ["picture"]
        query.queryOptions = options
        
        Organizations().dataStore().find(query, response: { (collection) in
            var organizations = collection.data as? [Organizations] ?? [Organizations]()
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    organizations.appendContentsOf(otherPageCollection?.data as? [Organizations] ?? [Organizations]())
                } else {
                    completion(organizations)
                }
            })
        }, error: { (fault) in
            completion([Organizations]())
        })
    }
    
    func roleInOrganization(user: Users, organization: Organizations) -> TypeRoleUserInOrganization {
        if organization.leaderId == nil {
            organization.leaderId = user.objectId
            organization.save({ (entity, error) in
                if entity == nil {
                    print("Error, save leaderId")
                }
            })
        }
        

        if organization.leaderId == user.objectId {
            return .Founder
        }
        
        if organization.admins!.toBackendlessArray().contains(user.objectId) {
            return .Admin
        }
        
        if organization.members!.toBackendlessArray().contains(user.objectId) {
            return .Member
        }
        
        for organization in user.organizations {
            if organization.objectId == organization.objectId {
                return .Follower
            }
        }
        
        return .None
    }
    
    func membersInOrganizations(organization: Organizations, completion: ([Users]?) -> Void) {
        guard organization.objectId != nil else {
            completion(nil)
            return
        }
        
        let query = BackendlessDataQuery()
        query.whereClause = BackendlessDataQuery().getFieldInArraySQLQuery(field: "objectId", array: organization.members!.toBackendlessArray())
        let options = QueryOptions()
        options.related = ["picture"]
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageCollection?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users)
                }
            })
        }, error: { (fault) in
            completion(nil)
        })
    }
    
    //what does this do? supposed to grab all unfollowed organizations, compare it to loadunfollowusers in usermanager.swift to fix
    func allUnfollowOrganizations(collection: BackendlessCollection?, completion: ([Organizations]?, BackendlessCollection?, NSError?) -> Void) {
        if collection != nil {
            collection?.nextPageAsync({ (backendlessCollection) in
                let organizations = backendlessCollection.data as? [Organizations] ?? [Organizations]()
                completion(organizations, backendlessCollection, nil)
            }, error: { (fault) in
                completion([Organizations](), nil, ErrorHelper().convertFaultToNSError(fault))
            })
            
            return
        }
        
        var userOrgIds = [String]()
        for org in UserManager().currentUser().organizations {
            userOrgIds.append(org.objectId)
        }
        
        let query = BackendlessDataQuery()
        query.whereClause = BackendlessDataQuery().getFieldInArraySQLQuery(field: "objectId", array: userOrgIds, notModifier: true)
        let options = QueryOptions()
        options.related = ["picture"]
        options.sortBy = ["name"]
        options.pageSize = 30
        query.queryOptions = options
        
        Organizations().dataStore().find(query, response: { (collection) in
            let organizations = collection.data as? [Organizations] ?? [Organizations]()
            completion(organizations, collection, nil)
        }, error: { (fault) in
            completion(nil, nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }

    func searchUnfollowOrganizations(searchString: String, completion: ([Organizations]?, NSError?) -> Void) {
        searchOrgs(searchString, completion: completion)
        let query = BackendlessDataQuery()
        query.whereClause = "'\(UserManager().currentUser().objectId)' not in members and name LIKE '%" + searchString + "%'"
        let options = QueryOptions()
        options.related = ["picture"]
        options.sortBy = ["name"]
        query.queryOptions = options
        print("Test HERE")
        
        Organizations().dataStore().find(query, response: { (collection) in
            var organizations = collection.data as? [Organizations] ?? [Organizations]()
            print("Org manager result: \(organizations.debugDescription)")
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    organizations.appendContentsOf(otherPageCollection?.data as? [Organizations] ?? [Organizations]())
                } else {
                    completion(organizations, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func searchOrgs(searchString:String, completion: ([Organizations]?, NSError?) -> Void) {
        // --REMOVE
        // var userOrgIds = [String]()
        print("searching orgs")
        print(UserManager().currentUser().organizations.count)
        for org in UserManager().currentUser().organizations {
            print("User org name \(org.name)")
        }
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        query.whereClause = "name LIKE '%\(searchString)%'"
        options.sortBy = ["name"]
        options.related = ["picture"]
        query.queryOptions = options
        Organizations().dataStore().find(query, response: { (collection) in
            var orgs = collection.data as? [Organizations] ?? [Organizations]()
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    orgs.appendContentsOf(otherPageCollection?.data as? [Organizations] ?? [Organizations]())
                } else {
                    completion(orgs, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    
                
    
//        var org = Organizations().dataStore().findFirst() as? [Organizations] ?? [Organizations]()
//        print("Org data :\(org.description))")
        
    }
    
    func joinOrganization(organization: Organizations, completion: (Bool) -> Void) {
        let user = UserManager().currentUser()
        var members = organization.members!.toBackendlessArray()
        
        var needToAdd = true
        for member in members {
            if member == user.objectId {
                needToAdd = false
            }
        }
        
        if needToAdd {
            members.append(user.objectId)
            organization.members = String().fromBackendlessArray(members)
            
            organization.save { (savedEntity, error) in
                if savedEntity != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        InvitationManager().invateThisOrganizationDelete(organization)
    }
    
    func unfollowingUserOnOrganization(organization: Organizations, user: Users, completion: (Organizations?, NSError?) -> Void) {
        var members = organization.members!.toBackendlessArray()
        
        if let indexObject = members.indexOf(user.objectId) {
            members.removeAtIndex(indexObject)
        }
        
        organization.members = String().fromBackendlessArray(members)
        organization.save({ (entity, error) in
            completion(entity as? Organizations, error)
        })
    }
    
    func addEvent(organization: Organizations, event: RippleEvent, completion: (Organizations?, NSError?) -> Void) {
        var events = organization.events
        
        var contains = false
        for ev in events {
            if ev.objectId == event.objectId {
                contains = true
            }
        }
        
        if !contains {
            events.append(event)
        }
        
        organization.events = events
        organization.save({ (entity, error) in
            completion(entity as? Organizations, error)
        })
    }
    
    func addAdminOrganization(organization: Organizations, user: Users, completion: (Organizations?, NSError?) -> Void) {
        var admins = organization.admins!.toBackendlessArray()
        
        if !admins.contains(user.objectId) {
            admins.append(user.objectId)
        }
        
        //        let acl = organization.ACL  TODO ACL
        //        acl?.setWriteAccess(true, forUser: user)
        //        organization.ACL = acl
        
        organization.admins = String().fromBackendlessArray(admins)
        organization.save({ (entity, error) in
            completion(entity as? Organizations, error)
        })
    }
    
    func removeAdminOrganization(organization: Organizations, user: Users, completion: (Bool) -> Void) {
        var admins = organization.admins!.toBackendlessArray()
        
        if admins.count == 0 {
            completion(true)
            return
        }
        
        if let indexAdmin = admins.indexOf(user.objectId) {
            admins.removeAtIndex(indexAdmin)
        }
        
        organization.admins = String().fromBackendlessArray(admins)
        
        // TODO ACL
//        if user.objectId != (organization["leaderId"] as? String) {
//            let acl = organization.ACL
//            acl?.setWriteAccess(false, forUser: user)
//            organization.ACL = acl
//        }
        
        organization.save({ (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func fetch(org: Organizations, completion: (Organizations?, NSError?) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "objectId = '\(org.objectId)'"
        let options = QueryOptions()
        options.related = ["events", "members"]
        query.queryOptions = options
        
        Organizations().dataStore().find(query, response: { (collection) in
            completion(collection.data?.first as? Organizations, nil)
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func fetchMany(ids: [String], completion: ([Organizations]?, NSError?) -> Void) {
        guard ids.count > 0 else {
            completion([Organizations](), nil)
            return
        }
        
        let query = BackendlessDataQuery()
        query.whereClause = query.getFieldInArraySQLQuery(field: "objectId", array: ids)
        let options = QueryOptions()
        options.related = ["picture"]
        options.sortBy(["name"])
        query.queryOptions = options
        
        Organizations().dataStore().find(query, response: { (collection) in
            var organizations = collection.data as? [Organizations] ?? [Organizations]()
            collection.loadOtherPages({ (otherPageCollection) -> Void in
                if otherPageCollection != nil {
                    organizations.appendContentsOf(otherPageCollection?.data as? [Organizations] ?? [Organizations]())
                } else {
                    completion(organizations, nil)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
}
