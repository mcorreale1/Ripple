//
//  ReportManager.swift
//  Ripple
//
//  Created by PRO on 02.11.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ORCommonCode_Swift

enum TypeReport: String {
    case User = "User"
    case Organization = "Organization"
    case Event = "Event"
    case FollowingRequest = "FollowingRequest"
}

class ReportManager: NSObject {
    
    func reports(completion:([PFObject]?) -> Void) {
        let query = PFQuery(className: "Reports")
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
        let query = PFQuery(className: "Reports")
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
        let query = PFQuery(className: "Reports")
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
    
    func trashReport(report: PFObject, completion: (success: Bool) -> Void) {
        let query = PFQuery(className: "Reports")
        if let typeReport = report["type"] as? String {
            switch typeReport {
            case TypeReport.Organization.rawValue:
                query.whereKey("toUser", equalTo: UserManager().currentUser())
                query.whereKey("organization", equalTo: report["organization"])
            case TypeReport.Event.rawValue:
                query.whereKey("toUser", equalTo: UserManager().currentUser())
                query.whereKey("event", equalTo: report["event"])
            default:
                report["accept"] = false
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
    
    func sendReportInOrganization(user: PFUser, organization: PFObject, completion: (success: Bool) -> Void) {
        let report = createReport()
        report["fromUser"] = UserManager().currentUser()
        report["toUser"] = user
        report["type"] = TypeReport.Organization.rawValue
        report["organization"] = organization
        report.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func sendReportInEvent(user: PFUser, event: PFObject, completion: (success: Bool) -> Void) {
        let report = createReport()
        report["fromUser"] = UserManager().currentUser()
        report["toUser"] = user
        report["type"] = TypeReport.Event.rawValue
        report["event"] = event
        report.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func sendReportOnFollow(user: PFUser, completion: (success: Bool) -> Void) {
        let report = createReport()
        report["fromUser"] = UserManager().currentUser()
        report["toUser"] = user
        report["type"] = TypeReport.User.rawValue
        report.saveInBackgroundWithBlock { (success, error) in
            completion(success: success)
        }
    }
    
    func createReport() -> PFObject {
        let report = PFObject(className: "Reports")
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        report.ACL = acl
        return report;
    }
    
    func deleteReportsByEvent(event: PFObject, complition: (success: Bool) -> Void) {
        let query = PFQuery(className: "Reports")
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
