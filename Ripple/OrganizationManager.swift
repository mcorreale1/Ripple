//
//  OrganizationManager.swift
//  Ripple
//
//  Created by evgeny on 27.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse

enum TypeRoleUserInOrganization: String {
    case Founder = "Founder"
    case Member = "Member"
    case None = "None"
    case Admin = "Admin"
}

class OrganizationManager: NSObject {

    /*func organizationForUser(user: PFUser, completion:(org: [PFObject]) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            var organizationArray = user["organizations"] as? [PFObject]
            if organizationArray == nil {
                organizationArray = [PFObject]()
            }
            
            for organization in organizationArray! {
                do {
                    try organization.fetchIfNeeded()
                } catch {
                    if let indexObject = organizationArray?.indexOf(organization) {
                        organizationArray?.removeAtIndex(indexObject)
                    }
                    print("Error fetch organization")
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(org: organizationArray!)
            }
        }
    }*/
    
    //func organizationForUser(user: PFUser, completion:(org: [PFObject]?, NSError) -> Void) {
    func organizationForUser(user: PFUser, completion:(org: [PFObject]) -> Void) {
        let query = PFQuery(className: "Organizations")
        query.whereKey("members", containedIn: [user.objectId!])
        query.findObjectsInBackgroundWithBlock { (result, error) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if result != nil {
                    var organizations = result!
                    for organization in organizations {
                        do { try organization.fetchIfNeeded()}
                        catch {
                            if let indexObject = organizations.indexOf(organization) {
                                organizations.removeAtIndex(indexObject)
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(org: organizations)
                        return
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(org: result!)
                        return
                    }
                }
            }
        
        }
    }
    
    func roleInOrganization(user: PFUser, organization: PFObject) -> TypeRoleUserInOrganization {
        let leaderId = organization["leaderId"] as? String
        
        if  leaderId == nil {
            organization["leaderId"] = UserManager().currentUser().objectId
            organization.saveInBackgroundWithBlock { (succes, error) in
                
                if !succes {
                    print("Error, save leaderId")
                }
            }
        }
        
        if (organization["leaderId"] as? String) == user.objectId! {
            return .Founder
        }
        
        if let admins = organization["admins"] as? [String] {
            if admins.contains(UserManager().currentUser().objectId!) {
                return .Admin
            }
        }
        
        var members = organization["members"] as! [String]
        
        if members.contains(UserManager().currentUser().objectId!){
            return .Member
        }
        
        let userOrganizations = user["organizations"] as! [PFObject]
        let searchPredicate = NSPredicate(format: "objectId == %@", organization.objectId!)
        let array = (userOrganizations as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        return array.count > 0 ? .Member : .None
    }
    
    /*func membersInOrganizations(organization: PFObject, completion: ([PFUser]?, NSError?) -> Void) {
        let query = PFUser.query()!
        query.whereKey("organizations", containedIn: [organization])
        query.findObjectsInBackgroundWithBlock { (results, error) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                if results != nil {
                    var users = results as! [PFUser]
                    for user in users {
                        do {
                            try user.fetchIfNeeded()
                        } catch {
                            if let indexObject = users.indexOf(user) {
                                users.removeAtIndex(indexObject)
                            }
                            print("Error fetch user")
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(users, error)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil, error)
                    }
                }
            })
        }
    }*/
    
    func membersInOrganizations(organization: PFObject, completion: (members: [PFUser]?) -> Void) {
        
        if let memberIds = organization["members"] as? [String] {
            let query = PFUser.query()!
            query.whereKey("objectId", containedIn: memberIds)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                completion(members: objects as? [PFUser])
            }
        }
    }
    
    /*func allUnfollowOrganizations(completion: ([PFObject]?, NSError?) -> Void) {
        let query = PFQuery(className: "Organizations")
        var organizationsIds = [String]()
        for organization in UserManager().currentUser()["organizations"] as! [PFObject] {
            organizationsIds.append(organization.objectId!)
        }
        query.whereKey("objectId", notContainedIn: organizationsIds)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            completion(results, error)
        }
    }*/
    
    func allUnfollowOrganizations(completion: ([PFObject]?, NSError?) -> Void) {
        let query = PFQuery(className: "Organizations")
        query.whereKey("members", notContainedIn: [UserManager().currentUser().objectId!])
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            completion(results, error)
        }
    }

    /*func followingOnOrganization(organization: PFObject, completion: (success: Bool) -> Void) {
        if var organizations = UserManager().currentUser()["organizations"] as? [PFObject] {
            organizations.append(organization)
            UserManager().currentUser()["organizations"] = organizations
            UserManager().currentUser().saveInBackgroundWithBlock({ (success, error) in
                completion(success: success)
            })
        } else {
            completion(success: false)
        }
    }*/
    
    func followingOnOrganization(organization: PFObject, completion: (success: Bool) -> Void) {
        /*
        let user = PFUser.currentUser()?.objectId
        var members = organization["members"] as! [String]
        if members.count == 0 {
            members = [String]()
        }
        if !members.contains(user!) {
            members.append(user!)
        }
        organization["members"] = members
        organization.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
 */
        let admin = PFUser.currentUser()
        
        var administrations = organization["members"] as? [String]
    
        if !administrations!.contains(admin!.objectId!) {
            administrations!.append(admin!.objectId!)
        }
        organization["members"] = administrations
        organization.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
        InvitationManager().invateThisOrganizationDelete(organization)

    }
    
    func unfollowingUserOnOrganization(organization: PFObject, user: PFUser, completion: (success: Bool) -> Void) {
        if var memberIds = organization["members"] as? [String] {
            if let indexObject = memberIds.indexOf(user.objectId!) {
                memberIds.removeAtIndex(indexObject)
            }
            organization["members"] = memberIds
            organization.saveInBackgroundWithBlock{
                (success, error) in
                completion(success: success)
            }
        } else {
            completion(success: false)
        }
    }
    
    func addEvent(organization: PFObject, event: PFObject, completion: (success: Bool) -> Void) {
        var events = organization["events"] as? [PFObject]
        
        if events == nil {
            events = [PFObject]()
        }
        if !events!.contains(event) {
            events!.append(event)
        }
        organization["events"] = events
        organization.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func deleteEvent(organization: PFObject, event: PFObject, completion: (success: Bool) -> Void) {
        var events = organization["events"] as? [PFObject]
        
        if events == nil {
            events = [PFObject]()
        }
        if let indexObject = events?.indexOf(event) {
            events?.removeAtIndex(indexObject)
        }
        
        organization["events"] = events
        organization.saveInBackgroundWithBlock { (success, error) in
            if success {
                print("Dele event from organization succes")
            } else {
                print("Erorr, \(error?.description)")
            }
            completion(success: success)
        }
    }
    
    func addAdminOrganization(organization: PFObject, user: PFUser, completion: (success: Bool) -> Void) {
        var administrations = organization["admins"] as? [String]
        
        if administrations == nil {
            administrations = [String]()
        }
        
        if !administrations!.contains(user.objectId!) {
            administrations!.append(user.objectId!)
        }
        organization["admins"] = administrations
        let acl = organization.ACL
        acl?.setWriteAccess(true, forUser: user)
        organization.ACL = acl
        
        organization.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func removeAdminOrganization(organization: PFObject, user: PFUser, completion: (success: Bool) -> Void) {
        var administrations = organization["admins"] as? [String]
        
        if administrations == nil || administrations?.count == 0 {
            completion(success: true)
            return
        }
        
        if let indexAdmin = administrations?.indexOf(user.objectId!) {
            administrations?.removeAtIndex(indexAdmin)
        }
        organization["admins"] = administrations
        
        if user.objectId != (organization["leaderId"] as? String) {
            let acl = organization.ACL
            acl?.setWriteAccess(false, forUser: user)
            organization.ACL = acl
        }
        
        organization.saveInBackgroundWithBlock { (succes, error) in
            completion(success: succes)
        }
    }
}
