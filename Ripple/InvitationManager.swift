//
//  InvitationManager.swift
//  Ripple
//
//  Created by evgeny on 05.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORCommonCode_Swift

class InvitationManager: NSObject {

    func invitations(completion:([Invitation]?) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)' and accept != 'True'"
        let options = QueryOptions()
        options.related = ["user","organization", "organization.picture", "event", "event.organization", "event.picture"]
        query.queryOptions = options
        
        Invitation().dataStore().find(query, response: { (collection) in
            print("invites collection: \(collection)")
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    print("invites: \(invites.description))")
                    var filteredInvites = [Invitation]()
                    for invite in invites {
                        if(invite.type == Invitation.typeInvitation.organization.rawValue) {
                            if(invite.organization != nil) {
                                filteredInvites.append(invite)
                            }
                        } else if (invite.type == Invitation.typeInvitation.event.rawValue) {
                            print("is event invite")
                            if(invite.event != nil) {
                                filteredInvites.append(invite)
                            }
                        }
                    }
                    completion(filteredInvites)
                }
            })
        }, error: { (fault) in
            completion([Invitation]())
        })
    }
    
    func invateThisEventDelete(event: RippleEvent) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)' and event.objectId = '\(event.objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invite in invites {
                        invite.delete({ (_) in })
                    }
                }
            })
        }, error: { (_) in })
    }
    
    func invateThisOrganizationDelete(organization: Organizations) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)' and organization.objectId = '\(organization.objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invite in invites {
                        invite.delete(){ (_) in }
                    }
                }
            })
        }, error: { (_) in })
    }
    
    func trashInvitation(invitation: Invitation, completion: (Bool) -> Void) {
        invitation.delete(completion)
    }
    
    func acceptInvitation(invitation: Invitation, completion: (Bool) -> Void) {
        
        if let typeInvitation = invitation.type {
            switch typeInvitation {
            case Invitation.typeInvitation.organization.rawValue:
                OrganizationManager().joinOrganization(invitation.organization!, completion: { (success) in
                    if(success) {
                        invitation.accept = "True"
                        invitation.save() { (_,_) in }
                        print("Joined org")
                        completion(true)
                    } else {
                        print("failed to join org")
                        completion(false)
                    }
                })
                
                //invitation.delete({ (_) in })
                
            case Invitation.typeInvitation.event.rawValue:
                var events = UserManager().currentUser().events
                
                if let event = invitation.event {
                    events.append(event)
                }
                print("saving event invite")
                
                //UserManager().currentUser().events = events
                //UserManager().currentUser().save { (_, _) in }
                UserManager().currentUser().setProperty(Users.propertyName.events.rawValue, object: events)
                Backendless.sharedInstance().userService.update(UserManager().currentUser(), response: { (backEndUser) in
                    print("user Events: \(UserManager().currentUser().events)")
                    invitation.accept = "True"
                    invitation.save() { (entity,error) in
                        if(error != nil) {
                            print("event invite error")
                        }
                        completion(true)
                    }
                }, error: { (fault) in
                    print("User update fault: \(fault)")
                    completion(false)
                })
                
                //invitation.delete({ (_) in })

            case Invitation.typeInvitation.user.rawValue:
                invitation.accept = "True"
                invitation.save() { (_,_) in }
                completion(true)
                //invitation.save({ (_, _) in })
            default:
                invitation.accept = "True"
            }
        } else {
            completion(false)
        }
    }
    
    func checkSentInvitation(organization: Organizations) {
        let me = UserManager().currentUser()
        
        let query = BackendlessDataQuery()
        query.whereClause = "fromUser.objectId = '\(UserManager().currentUser().objectId)'"
        let options = QueryOptions()
        options.related = ["fromUser", "toUser", "organization", "event"]
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invite in invites {
                        if invite.accept == "True" {
                            let user = invite.toUser!
                            var friends = me.friends
                            friends.append(user)
                            me.friends = friends
                            me.save({ (_, _) in })
                        }
                        invite.delete({ (_) in })
                    }
                }
            })
        }, error: { (_) in })
    }
    
    func sendInvitationInOrganization(user: Users, organization: Organizations, completion: (Bool) -> Void) {
        let invitation = Invitation()
        invitation.fromUser = UserManager().currentUser()
        invitation.toUser = user
        invitation.type = Invitation.typeInvitation.organization.rawValue
        invitation.organization = organization
        invitation.accept = "False"
        invitation.save { (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                print("org invite error: \(error)")
                completion(false)
            }
        }
    }
    
    func sendInvitationOnEvent(user: Users, event: RippleEvent, completion: (Bool) -> Void) {
        let invitation = Invitation()
        invitation.fromUser = UserManager().currentUser()
        invitation.toUser = user
        invitation.type = Invitation.typeInvitation.event.rawValue
        invitation.event = event
        invitation.organization = event.organization
        invitation.accept = "False"
        invitation.save { (entity, error) in
            if entity != nil {
                or_postNotification(PulseNotification.PulseNotificationEventSendInvitations.rawValue)
                completion(true)
            } else {
                print("event invite error: \(error)")
                completion(false)
            }
        }
    }
    
    func sendInvitationOnFollow(user: Users, completion: (Bool) -> Void) {
        let invitation = Invitation()
        invitation.fromUser = UserManager().currentUser()
        invitation.toUser = user
        invitation.type = Invitation.typeInvitation.user.rawValue
        invitation.accept = "False"
        invitation.save { (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func deleteInvitationsByEvent(event: RippleEvent, complition: (Bool) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "event.objectId = '\(event.objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invite in invites {
                        invite.delete({ (success) in })
                    }
                    complition(true)
                }
            })
        }, error: { (_) in
            complition(false)
        })
    }
    
    func isCurrentUserInvitedToOrganization(organization: Organizations, completion: (Bool) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "organization.objectId = '\(organization.objectId)' and toUser.objectId = '\(UserManager().currentUser().objectId)'"
        
        Invitation().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            
            if invites.count > 0  {
                completion(true)
                return
            }
            
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    if invites.count > 0  {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            })
        }, error: { (_) in
            completion(false)
        })
    }
}
