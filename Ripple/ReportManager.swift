//
//  ReportManager.swift
//  Ripple
//
//  Created by PRO on 02.11.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import UIKit
import ORCommonCode_Swift

class ReportManager: NSObject {
    
    func reports(completion:([Reports]?) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)'"
        let options = QueryOptions()
        options.related = ["fromUser", "toUser", "organization", "event", "event.organization"]
        
        Reports().dataStore().find(query, response: { (collection) in
            var reports = collection.data as? [Reports] ?? [Reports]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    reports.appendContentsOf(otherPageEvents?.data as? [Reports] ?? [Reports]())
                } else {
                    completion(reports)
                }
            })
        }, error: { (fault) in
            completion([Reports]())
        })
    }
    
    func invateThisEventDelete(event: RippleEvent) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)' and event.objectId = '\(event.objectId)'"
        
        Reports().dataStore().find(query, response: { (collection) in
            var reports = collection.data as? [Reports] ?? [Reports]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    reports.appendContentsOf(otherPageEvents?.data as? [Reports] ?? [Reports]())
                } else {
                    for report in reports {
                        report.delete({ (_) in })
                    }
                }
            })
        }, error: { (_) in })
    }
    
    func invateThisOrganizationDelete(organization: Organizations) {
        let query = BackendlessDataQuery()
        query.whereClause = "toUser.objectId = '\(UserManager().currentUser().objectId)' and organization.objectId = '\(organization.objectId)'"
        
        Reports().dataStore().find(query, response: { (collection) in
            var reports = collection.data as? [Reports] ?? [Reports]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    reports.appendContentsOf(otherPageEvents?.data as? [Reports] ?? [Reports]())
                } else {
                    for report in reports {
                        report.delete({ (_) in })
                    }
                }
            })
        }, error: { (_) in })
    }
    
    func trashReport(report: Reports, completion: (Bool) -> Void) {
        let query = BackendlessDataQuery()
        var queryString = "toUser.objectId = '\(UserManager().currentUser().objectId)'"
        
        if let typeInvitation = report.type {
            switch typeInvitation {
            case .organization:
                queryString += " and organization.objectId = '\(report.organization!.objectId)'"
            case .event:
                queryString += " and event.objectId = '\(report.event!.objectId)'"
            default:
                report.accept = false
            }
        }
        
        query.whereClause = queryString
        
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
        
        completion(true)
    }
    
    func sendReportInOrganization(user: Users, organization: Organizations, completion: (Bool) -> Void) {
        let report = createReport()
        report.fromUser = UserManager().currentUser()
        report.toUser = user
        report.type = Reports.typeReport.organization
        report.organization = organization
        report.save { (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func sendReportInEvent(user: Users, event: RippleEvent, completion: (Bool) -> Void) {
        let report = createReport()
        report.fromUser = UserManager().currentUser()
        report.toUser = user
        report.type = Reports.typeReport.event
        report.event = event
        report.save { (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func sendReportOnFollow(user: Users, completion: (Bool) -> Void) {
        let report = createReport()
        report.fromUser = UserManager().currentUser()
        report.toUser = user
        report.type = Reports.typeReport.user
        report.save { (entity, error) in
            if entity != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func createReport() -> Reports {
        let report = Reports()
        return report;
    }
    
    func deleteReportsByEvent(event: RippleEvent, complition: (Bool) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "event.objectId = '\(event.objectId)'"
        
        Reports().dataStore().find(query, response: { (collection) in
            var invites = collection.data as? [Invitation] ?? [Invitation]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    invites.appendContentsOf(otherPageEvents?.data as? [Invitation] ?? [Invitation]())
                } else {
                    for invite in invites {
                        invite.delete({ (success) in
                            complition(true)
                        })
                    }
                }
            })
        }, error: { (_) in
            complition(false)
        })
    }
}
