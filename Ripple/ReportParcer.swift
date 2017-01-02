//
//  ReportParcer.swift
//  Ripple
//
//  Created by nikitaivanov on 08/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class ReportParcer : NSObject {
    
    func fetchCoreDataEntity(fromReport report: Reports, withContext context: NSManagedObjectContext) -> CDReport? {
        var cdReport = CDReport.MR_findFirstByAttribute(Constants.EntityParcing.serverIDAttribute, withValue: report.objectId, inContext: context)
        
        if cdReport == nil {
            cdReport = CDReport.MR_createEntityInContext(context)
            
            if (cdReport == nil) {
                return nil
            }
            
            cdReport!.serverID = report.objectId
        }
        
        cdReport!.type = report.type?.rawValue
        
        if report.event != nil {
            cdReport!.event = EventParcer().fetchCoreDataEntity(fromEvent: report.event!, withContext: context)
        }
        
        if report.fromUser != nil {
            cdReport!.fromUser = UserParcer().fetchCoreDataEntity(fromUser: report.fromUser!, withContext: context)
        }
        
        if report.toUser != nil {
            cdReport!.toUser = UserParcer().fetchCoreDataEntity(fromUser: report.toUser!, withContext: context)
        }
        
        if report.organization != nil {
            cdReport!.organization = OrganizationParcer().fetchCoreDataEntity(fromOrganization: report.organization!, withContext: context)
        }
        
        return cdReport
    }
    
    func fetchBackendlessEntity(fromCDReport cdReport: CDReport) -> Reports {
        let report = Reports()
        report.objectId = cdReport.serverID
        
        if let type = cdReport.type {
            report.type = Reports.typeReport(rawValue: type)
        }
        
        if let fromCDUser = cdReport.fromUser {
            report.fromUser = UserParcer().fetchBackendlessEntity(fromCDUser: fromCDUser)
        }
        
        if let toCDUser = cdReport.toUser {
            report.toUser = UserParcer().fetchBackendlessEntity(fromCDUser: toCDUser)
        }
        
        if let cdOrganization = cdReport.organization {
            report.organization = OrganizationParcer().fetchBackendlessEntity(fromCDOrganization: cdOrganization)
        }
        
        if let cdEvent = cdReport.event {
            report.event = EventParcer().fetchBackendlessEntity(fromCDEvent: cdEvent)
        }
        
        return report
    }
    
}
