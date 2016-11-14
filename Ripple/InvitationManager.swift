//
//  InvitationManager.swift
//  Ripple
//
//  Created by evgeny on 05.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORCommonCode_Swift

enum TypeInvitation: String {
    case User = "User"
    case Organization = "Organization"
    case Event = "Event"
    case FollowingRequest = "FollowingRequest"
}

class InvitationManager: NSObject {

    func invitations(completion:([PFObject]?) -> Void) {
        let query = PFQuery(className: "Invitation")
        query.whereKey("toUser", equalTo: UserManager().currentUser())
        query.includeKeys(["fromUser", "toUser", "organization", "event", "event.organization"])
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if result != nil {
                completion(result)
            } else {
                completion([PFObject]())
            }
        })
    }
    
    func invateThisEventDelete(event: PFObject) {
        let query = PFQuery(className: "Invitation")
        query.whereKey("event", equalTo: event)
        query.whereKey("toUser", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
            if error == nil {
                for result in results! as[PFObject] {
                    result.deleteInBackground()
                }
                
            }
        }
    }
    
    func invateThisOrganizationDelete(organization: PFObject) {
        let query = PFQuery(className: "Invitation")
        query.whereKey("organization", equalTo: organization)
        query.whereKey("toUser", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
            if error == nil {
                for result in results! as[PFObject] {
                    result.deleteInBackground()
                }
                
            }
        }
    }
    
    func trashInvitation(invitation: PFObject, completion: (success: Bool) -> Void) {
        let query = PFQuery(className: "Invitation")
        if let typeInvitation = invitation["type"] as? String {
                switch typeInvitation {
                    case TypeInvitation.Organization.rawValue:
                        query.whereKey("toUser", equalTo: UserManager().currentUser())
                        query.whereKey("organization", equalTo: invitation["organization"])
                    case TypeInvitation.Event.rawValue:
                        query.whereKey("toUser", equalTo: UserManager().currentUser())
                        query.whereKey("event", equalTo: invitation["event"])
                default:
                    invitation["accept"] = false
            }
        }
        query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
            if error == nil {
                for result in results! as[PFObject] {
                    result.deleteInBackground()
                }
                
            }
        }
        completion(success: true)
    }
    
    func acceptInvitation(invitation: PFObject, completion: (success: Bool) -> Void) {
        let user = UserManager().currentUser()
        
        if let typeInvitation = invitation["type"] as? String {
            switch typeInvitation {
            case TypeInvitation.Organization.rawValue:
                OrganizationManager().followingOnOrganization((invitation["organization"] as? PFObject)!, completion: {(succes) -> Void in
                    if !succes {
                        print("Error, no follow to organisation from invite")
                    }
                })
                invitation.deleteEventually()
                let query = PFQuery(className: "Invitation")
                query.whereKey("organization", equalTo: invitation["organization"])
                query.whereKey("toUser", equalTo: UserManager().currentUser())
                query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
                    if error == nil {
                        if let sresult = results {
                            for result in sresult {
                                result.deleteInBackground()
                            }
                        }
                    }
                }
                
            case TypeInvitation.Event.rawValue:
                var events = user["events"] as? [PFObject]
                
                if events == nil {
                    events = [PFObject]()
                }
                if let event = invitation["event"] as? PFObject {
                    events!.append(event)
                }
                user["events"] = events
                invitation.deleteEventually()
                let query = PFQuery(className: "Invitation")
                query.whereKey("event", equalTo: invitation["event"])
                query.whereKey("toUser", equalTo: UserManager().currentUser())
                query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
                    if error == nil {
                        for result in results! as[PFObject] {
                            result.deleteInBackground()
                        }
                        
                    }
                }

                
            case TypeInvitation.User.rawValue:
                invitation["accept"] = true
                invitation.saveInBackground()
            default:
                invitation["accept"] = false
            }
            completion(success: true)
        } else {
            completion(success: false)
        }
        
        user.saveInBackground()
    }
    
    func checkSentInvitation() {
        let query = PFQuery(className: "Invitation")
        let me = UserManager().currentUser()
        query.whereKey("fromUser", equalTo: UserManager().currentUser())
        query.includeKeys(["fromUser", "toUser", "organization", "event"])
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if result != nil {
                for invitation in result! {
                    if let accept = invitation["accept"] as? Bool {
                        if accept {
                            let user = invitation["toUser"] as! PFObject
                            var friends = me["friends"] as? [PFObject]
                            
                            if friends == nil {
                                friends = [PFObject]()
                            }
                            friends!.append(user)
                            me["friends"] = friends!
                            me.saveInBackground()
                        }
                        invitation.deleteEventually()
                    }
                }
            }
        })
    }
    
    func sendInvitationInOrganization(user: PFUser, organization: PFObject, completion: (success: Bool) -> Void) {
        let invitation = createInvitation()
        invitation["fromUser"] = UserManager().currentUser()
        invitation["toUser"] = user
        invitation["type"] = TypeInvitation.Organization.rawValue
        invitation["organization"] = organization
        invitation.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func sendInvitationInEvent(user: PFUser, event: PFObject, completion: (success: Bool) -> Void) {
        let invitation = createInvitation()
        invitation["fromUser"] = UserManager().currentUser()
        invitation["toUser"] = user
        invitation["type"] = TypeInvitation.Event.rawValue
        invitation["event"] = event
        invitation.saveInBackgroundWithBlock { (success, error) in
            or_postNotification(PulseNotification.PulseNotificationEventSendInvitations.rawValue)
            completion(success: success)
        }
    }
    
    func sendInvitationOnFollow(user: PFUser, completion: (success: Bool) -> Void) {
        let invitation = createInvitation()
        invitation["fromUser"] = UserManager().currentUser()
        invitation["toUser"] = user
        invitation["type"] = TypeInvitation.User.rawValue
        invitation.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func createInvitation() -> PFObject {
        let invitation = PFObject(className: "Invitation")
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        invitation.ACL = acl
        return invitation;
    }
    
    func deleteInvitationsByEvent(event: PFObject, complition: (success: Bool) -> Void) {
        let query = PFQuery(className: "Invitation")
        query.whereKey("event", equalTo: event)
        query.findObjectsInBackgroundWithBlock {[weak self] (results, error)   in
            if error == nil {
                if results?.count == 0 {
                    complition(success: true)
                    return
                }
                for result in results! as[PFObject] {
                    result.deleteInBackgroundWithBlock({ (succes, error) in
                        if !succes {
                            print("Error, \(error?.description)")
                        }
                        complition(success: succes)
                        return
                    })
                }
                
            } else {
                complition(success: false)
                return
            }
        }
    }
}
