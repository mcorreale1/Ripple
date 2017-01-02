//
//  EventManager.swift
//  Ripple
//
//  Created by evgeny on 27.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

enum TypeEventsSection: String {
    case Today = "Today"
    case ThisWeek = "This Week"
    case Future = "Future"
}

class EventManager: NSObject {
    
    private struct EventParticipants {
        var event: RippleEvent
        var participantsCount: Int
    }

    static var sharedInstance = EventManager()
    
    func eventPlansForUser(user: Users, isMe: Bool, completion:([Dictionary<String, AnyObject>]) -> Void)  {
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["events", "events.picture", "events.organization"]
        query.queryOptions = options
        query.whereClause = "objectId = '\(user.objectId)'"
        
        Users().dataStore().find(query, response: { (collection) in
            let fetchedUser = Users.userFromBackendlessUser(collection.data![0] as! BackendlessUser)
            let events = fetchedUser.events
            
            var plan = [Dictionary<String, AnyObject>]()
            
            let todayEvents = EventManager().eventsInDay(NSDate(), events: events, showPrivate: isMe)
            if todayEvents.count > 0 {
                let section = ["title" : TypeEventsSection.Today.rawValue,
                    "events" : todayEvents]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            
            let eventsThisWeek = EventManager().eventsThisWeek(events, showPrivate: isMe)
            if eventsThisWeek.count > 0 {
                let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                    "events" : eventsThisWeek]
                
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            
            let eventsFuture = EventManager().eventsFuture(events, showPrivate: isMe)
            if eventsFuture.count > 0 {
                let section = ["title" : TypeEventsSection.Future.rawValue,
                    "events" : eventsFuture]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            
            completion(plan)
        }, error: { (fault) in
            completion([])
        })
    }
    
    func eventOrganization(organization: Organizations, completion:([RippleEvent]) -> Void) {
        guard organization.objectId != nil else {
            completion([RippleEvent]())
            return
        }
        
        let queryOptions = QueryOptions()
        queryOptions.related = ["events", "events.picture"]
        let query = BackendlessDataQuery()
        query.whereClause = "objectId = '\(organization.objectId)'"
        query.queryOptions = queryOptions

        Organizations().dataStore().find(query, response: { (collection) in
            let fetchedOrg = collection.data[0] as! Organizations
            
            var futureEvents = [RippleEvent]()
            for event in fetchedOrg.events {
                if event.startDate!.isGreaterOrEqualThen(NSDate()) {
                    futureEvents.append(event)
                }
            }
            
            var userEventIds = [String]()
            for uEvent in UserManager().currentUser().events {
                userEventIds.append(uEvent.objectId)
            }
            
            var events = [RippleEvent]()
            for event in fetchedOrg.events {
                if userEventIds.contains(event.objectId) {
                    events.append(event)
                } else {
                    if !event.isPrivate {
                        events.append(event)
                    }
                }
            }
            
            completion(events)
            
        }, error: { (fault) in
            completion([RippleEvent]())
        })
    }
    
   
    func followingEvents(completion:([Dictionary<String, AnyObject>]) -> Void) {
        guard UserManager().currentUser().organizations.count > 0 else {
            completion([Dictionary<String, AnyObject>]())
            return
        }
        
        var userOrgIds = [String]()
        for org in UserManager().currentUser().organizations {
            userOrgIds.append(org.objectId)
        }
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["events", "events.organization", "events.picture"]
        query.queryOptions = options
        query.whereClause = query.getFieldInArraySQLQuery(field: "objectid", array: userOrgIds)
        
        var plan = [Dictionary<String, AnyObject>]()
        Organizations().dataStore().find(query, response: { (collection) in
            var events = [RippleEvent]()
            var organizations = collection.data as? [Organizations] ?? [Organizations]()
            
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    organizations.appendContentsOf(otherPageEvents?.data as? [Organizations] ?? [Organizations]())
                } else {
                    for organization in organizations {
                        var withoutEvents = UserManager().currentUser().events
                        let eventsBlackList = UserManager().currentUser().eventsBlackList
                        withoutEvents.appendContentsOf(eventsBlackList)
                        
                        var eventsOrg = organization.events
                        for event in withoutEvents {
                            if let indexObj = eventsOrg.indexOf(event) {
                                eventsOrg.removeAtIndex(indexObj)
                            }
                        }
                        events.appendContentsOf(eventsOrg)
                    }
                    
                    let todayEvents = EventManager().eventsInDay(NSDate(), events: events, showPrivate: true)
                    if todayEvents.count > 0 {
                        let section = ["title" : TypeEventsSection.Today.rawValue,
                            "events" : todayEvents]
                        plan.append(section as! Dictionary<String, AnyObject>)
                    }
                    
                    let eventsThisWeek = EventManager().eventsThisWeek(events, showPrivate: true)
                    if eventsThisWeek.count > 0 {
                        let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                            "events" : eventsThisWeek]
                        plan.append(section as! Dictionary<String, AnyObject>)
                    }
                    
                    let eventsFuture = EventManager().eventsFuture(events, showPrivate: true)
                    if eventsFuture.count > 0 {
                        let section = ["title" : TypeEventsSection.Future.rawValue,
                            "events" : eventsFuture]
                        plan.append(section as! Dictionary<String, AnyObject>)
                    }
                    
                    completion(plan)
                }
            })
        }, error: { (fault) in
            completion(plan)
        })
    }
    
    func eventInformation(event: RippleEvent) -> [Dictionary<String, AnyObject>] {
        var information = [Dictionary<String, AnyObject>]()
        let eventStartDate = event.startDate!
        let eventEndDate = event.endDate!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE\nLLLL, dd"
        let dayEventString = dateFormatter.stringFromDate(eventStartDate)
        
        information.append(["icon" : "calander_icon_event",
                            "value" : dayEventString,
                            "needShowAccessory" : true])
        
        let dayEventEndString = dateFormatter.stringFromDate(eventEndDate)
        
        information.append(["icon" : "calander_icon_event",
            "value" : dayEventEndString,
            "needShowAccessory" : true])
        
        dateFormatter.dateFormat = "h:mm a"
        let startTimeString = dateFormatter.stringFromDate(eventStartDate)
        let endTimeString = dateFormatter.stringFromDate(eventEndDate)
        
        information.append(["icon" : "clock_icon_event",
                            "value" : startTimeString + " - " + endTimeString,
                            "needShowAccessory" : true])
        
        information.append(["icon" : "map_icon_event",
                            "value" : event.address!,
                            "needShowAccessory" : true])
        
        information.append(["icon" : "lock_icon_event",
                            "value" : (event.isPrivate ? "Private" : "Public"),
                            "needShowAccessory" : false])
        
        information.append(["icon" : "money_icon_event",
                            "value" : event.cost,
                            "needShowAccessory" : false])
        
        return information
    }
    
    func eventParticipants(event: RippleEvent, completion: ([Users]?, NSError?, RippleEvent?) -> Void) {
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["picture", "organization"]
        query.queryOptions = options
        query.whereClause = "events.objectid = '\(event.objectId!)'"
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    completion(users, nil, event)
                }
            })
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault), event)
        })
    }
    
    func allEventsForUser(user: Users, completion: ([RippleEvent]) -> Void) {
        var eventsIds = [String]()
        let eventArray = user.events
        for event in eventArray {
            if let eventId = event.objectId {
                eventsIds.append(eventId)
            }
        }
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["picture", "organization"]
        query.queryOptions = options
        query.whereClause = "objectId in ( '" + eventsIds.joinWithSeparator("', '") + "' )"
        
        RippleEvent().dataStore().find(query, response: { (collection) in
            var events = collection.data as? [RippleEvent] ?? [RippleEvent]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    events.appendContentsOf(otherPageEvents?.data as? [RippleEvent] ?? [RippleEvent]())
                } else {
                    completion(events)
                }
            })
        }, error: { (fault) in
            completion([RippleEvent]())
        })
    }
    
    func allEvents(completion: ([RippleEvent]) -> Void) {
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["organization"]
        query.queryOptions = options
        query.whereClause = "startDate > '\(NSDate())' and isPrivate = 'false'"
        
        RippleEvent().dataStore().find(query, response: { (collection) in
            var events = collection.data as? [RippleEvent] ?? [RippleEvent]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    events.appendContentsOf(otherPageEvents?.data as? [RippleEvent] ?? [RippleEvent]())
                } else {
                    completion(events)
                }
            })
        }, error: { (fault) in
            completion([RippleEvent]())
        })
    }

    func createEvent(organization: Organizations, event: RippleEvent, name: String, start: NSDate, end: NSDate, isPrivate: Bool, cost: Double, picture: UIImage, description: String, address: String, coordinate: CLLocationCoordinate2D, completion: (Bool, RippleEvent?) -> Void) {
        event.name = name
        event.startDate = start
        event.endDate = end
        event.isPrivate = isPrivate
        event.cost = cost
        event.address = address
        event.latitude = coordinate.latitude
        event.longitude = coordinate.longitude
        event.descr = description
        event.organization = organization
        
        PictureManager().uploadImage(picture) { (imageURL, storagePath, error) in
            guard error == nil else {
                completion(false, nil)
                return
            }
            
            guard imageURL != nil else {
                completion(false, nil)
                return
            }
            
            let eventPicture = event.picture ?? Pictures()
            eventPicture.imageURL = imageURL
            eventPicture.storagePath = storagePath
            event.picture = eventPicture
            
            event.save({ (entity, error) in
                guard error == nil else {
                    completion(false, nil)
                    return
                }
                
                if let eventEntity = entity as? RippleEvent {
                    UserManager().goOnEvent(eventEntity, completion: { (success) in
                        if success == false{
                            print("Error add user")
                        }
                    })
                    
                    OrganizationManager().addEvent(organization, event: eventEntity, completion: { (entity, error) in
                        if entity == nil {
                            print("Error add org")
                        }
                    })
                    
                    completion(true, eventEntity)
                } else {
                    completion(false, nil)
                }
            })
        }
    }
    
    func updateEvent(event: RippleEvent, organization: Organizations, name: String, start: NSDate, end: NSDate, isPrivate: Bool, cost: Double, picture: UIImage, description: String, address: String, coordinate: CLLocationCoordinate2D, completion: (Bool, RippleEvent?) -> Void) {
        event.name = name
        event.startDate = start
        event.endDate = end
        event.isPrivate = isPrivate
        event.cost = cost
        event.address = address
        event.latitude = coordinate.latitude
        event.longitude = coordinate.longitude
        event.descr = description
        event.organization = organization
        
        PictureManager().uploadImage(picture) { (imageURL, storagePath, error) in
            guard error == nil else {
                completion(false, nil)
                return
            }
            
            guard imageURL != nil else {
                completion(false, nil)
                return
            }
            
            let eventPicture = event.picture ?? Pictures()
            eventPicture.imageURL = imageURL
            eventPicture.storagePath = storagePath
            
            eventPicture.save({ (savedPicture, error) in
                guard error == nil else {
                    completion(false, nil)
                    return
                }
                
                event.picture = savedPicture as? Pictures
                
                event.save({ (entity, error) in
                    guard error == nil else {
                        completion(false, nil)
                        return
                    }
                    
                    completion(true, entity as? RippleEvent)
                })
            })
        }
    }
    
    func pulsingEvents(completion: ([Dictionary<String, AnyObject>]) -> Void) {
        let eventsBlackList = UserManager().currentUser().eventsBlackList
        var objectIdEventsBlackList: [String] = []
        for event in eventsBlackList {
            objectIdEventsBlackList.append(event.objectId!)
        }
        
        let query = BackendlessDataQuery()
        let options = QueryOptions()
        options.related = ["events", "events.organization", "events.picture"]
        
        var whereString = "events is not null and events.startDate > '\(NSDate())' and events.isPrivate = 'false'"
        let notInArray = query.getFieldInArraySQLQuery(field: "events.objectId", array: objectIdEventsBlackList, notModifier: true)
        if notInArray != "" {
            whereString += "and \(notInArray)"
        }
        query.whereClause = whereString
        query.queryOptions = options
        
        Users().dataStore().find(query, response: { (collection) in
            var users = UserManager().backendlessUsersToLocalUsers(collection.data as? [BackendlessUser] ?? [BackendlessUser]())
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    users.appendContentsOf(UserManager().backendlessUsersToLocalUsers(otherPageEvents?.data as? [BackendlessUser] ?? [BackendlessUser]()))
                } else {
                    
                    var eventsParticipantsDict = Dictionary<RippleEvent, Int>()
                    for user in users {
                        for userEvent in user.events {
                            if eventsParticipantsDict[userEvent] == nil {
                                eventsParticipantsDict[userEvent] = 1
                            } else {
                                eventsParticipantsDict[userEvent]! += 1
                            }
                        }
                    }
                    
                    var eventsParticipants = [EventParticipants]()
                    for (event, participantCount) in eventsParticipantsDict {
                        eventsParticipants.append(EventParticipants(event: event, participantsCount: participantCount))
                    }
                    
                    eventsParticipants.sortInPlace({ (ep1, ep2) -> Bool in
                        return ep1.participantsCount > ep2.participantsCount
                    })
                    
                    var pulsingEvents = [RippleEvent]()
                    for ep in eventsParticipants {
                        pulsingEvents.append(ep.event)
                    }
                    
                    var plans = [Dictionary<String, AnyObject>]()
                    
                    let todayEvents = EventManager().eventsInDay(NSDate(), events: pulsingEvents, showPrivate: false)
                    if todayEvents.count > 0 {
                        let section = ["title" : TypeEventsSection.Today.rawValue,
                            "events" : todayEvents]
                        plans.append(section as! Dictionary<String, AnyObject>)
                    }
                    
                    let eventsThisWeek = EventManager().eventsThisWeek(pulsingEvents, showPrivate: false)
                    if eventsThisWeek.count > 0 {
                        let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                            "events" : eventsThisWeek]
                        plans.append(section as! Dictionary<String, AnyObject>)
                    }
                    
                    let eventsFuture = EventManager().eventsFuture(pulsingEvents, showPrivate: false)
                    if eventsFuture.count > 0 {
                        let section = ["title" : TypeEventsSection.Future.rawValue,
                            "events" : eventsFuture]
                        plans.append(section as! Dictionary<String, AnyObject>)
                    }
                    completion(plans)
                }
            })
        }, error: { (fault) in
            completion([Dictionary<String, AnyObject>]())
        })
    }
    
    func deleteEvent(event: RippleEvent, completion: (Bool) -> Void) {
        event.delete { (success) in
            if success {
                InvitationManager().deleteInvitationsByEvent(event, complition: completion)
            } else {
                completion(false)
            }
        }
    }
    
    func eventsInDay(day: NSDate, events: [RippleEvent], showPrivate: Bool) -> [RippleEvent] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheDay: NSDate? = nil
        var endOfDay: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.Weekday, startDate: &startOfTheDay, interval: &timeInterval, forDate: day)
        endOfDay = startOfTheDay?.dateByAddingTimeInterval(timeInterval - 1)
        
        var dayEvents = [RippleEvent]()
        for event in events {
            let startDate = event.startDate!
            if startDate.isGreaterOrEqualThen(startOfTheDay!) && startDate.isLessOrEqualThen(endOfDay!) && (showPrivate ? true : !event.isPrivate) {
                dayEvents.append(event)
            }
        }
        
        sortEventsChronological(&dayEvents)
        
        return dayEvents
    }
    
    func eventsThisWeek(events: [RippleEvent], showPrivate: Bool) -> [RippleEvent] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheWeek: NSDate? = nil
        var endOfWeek: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfTheWeek, interval: &timeInterval, forDate: NSDate())
        endOfWeek = startOfTheWeek?.dateByAddingTimeInterval(timeInterval - 1)
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 1
        let tomorrow = calendar.dateByAddingComponents(dateComponents, toDate: NSDate(), options: NSCalendarOptions())
        
        var eventsInWeek = [RippleEvent]()
        for event in events {
            let startDate = event.startDate!
            if startDate.isGreaterOrEqualThen(tomorrow!.resetTime()) && startDate.isLessOrEqualThen(endOfWeek!) && (showPrivate ? true : !event.isPrivate) {
                eventsInWeek.append(event)
            }
        }
        
        sortEventsChronological(&eventsInWeek)
        
        return eventsInWeek
    }
    
    func eventsFuture(events: [RippleEvent], showPrivate: Bool) -> [RippleEvent] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheWeek: NSDate? = nil
        var endOfWeek: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfTheWeek, interval: &timeInterval, forDate: NSDate())
        endOfWeek = startOfTheWeek?.dateByAddingTimeInterval(timeInterval - 1)
        
        var eventsInFuture = [RippleEvent]()
        for event in events {
            if event.startDate!.isGreaterThen(endOfWeek!) && (showPrivate ? true : !event.isPrivate) {
                eventsInFuture.append(event)
            }
        }
        
        sortEventsChronological(&eventsInFuture)
        
        return eventsInFuture
    }
    
    private func sortEventsChronological(inout events: [RippleEvent]) {
        events.sortInPlace { (event1: RippleEvent, event2: RippleEvent) -> Bool in
            let date1 = event1.startDate
            let date2 = event2.startDate
            return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
        }
    }
}
