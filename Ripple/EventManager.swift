//
//  EventManager.swift
//  Ripple
//
//  Created by evgeny on 27.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import Firebase

enum TypeEventsSection: String {
    case Today = "Today"
    case ThisWeek = "This Week"
    case Future = "Future"
}

class EventManager: NSObject {

    //let countUsersForPulsing = 10
    static var sharedInstance = EventManager()
    
    func eventPlansForUser(user: PFUser, isMe: Bool, completion:(plan: [Dictionary<String, AnyObject>]) -> Void)  {
        var eventsIds = [String]()
        
        if let eventArray = user["events"] as? [PFObject] {
            for event in eventArray {
                if let eventId = event.objectId {
                    eventsIds.append(eventId)
                }
            }
        }
        let query = PFQuery(className: "Events")
        query.includeKeys(["picture", "organization"])
        query.whereKey("objectId", containedIn: eventsIds)
        
        query.findObjectsInBackgroundWithBlock {(events, error) in
            var plan = [Dictionary<String, AnyObject>]()
            
            if events != nil {
                var todayEvents = EventManager().eventsInDay(NSDate(), events: events!, showPrivate: isMe)
                
                if todayEvents.count > 0 {
                    todayEvents.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                        let date1 = event1["startDate"] as? NSDate
                        let date2 = event2["startDate"] as? NSDate
                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                    }
                    let section = ["title" : TypeEventsSection.Today.rawValue,
                                   "events" : todayEvents]
                    
                    plan.append(section as! Dictionary<String, AnyObject>)
                }
                var eventsThisWeek = EventManager().eventsThisWeek(events!, showPrivate: isMe)
                
                if eventsThisWeek.count > 0 {
                    eventsThisWeek.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                        let date1 = event1["startDate"] as? NSDate
                        let date2 = event2["startDate"] as? NSDate
                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                    }
                    let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                                   "events" : eventsThisWeek]
                    
                    plan.append(section as! Dictionary<String, AnyObject>)
                }
                var eventsFuture = EventManager().eventsFuture(events!, showPrivate: isMe)
                
                if eventsFuture.count > 0 {
                    eventsFuture.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                        let date1 = event1["startDate"] as? NSDate
                        let date2 = event2["startDate"] as? NSDate
                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                    }
                    let section = ["title" : TypeEventsSection.Future.rawValue,
                                   "events" : eventsFuture]
                    
                    plan.append(section as! Dictionary<String, AnyObject>)
                }
            }
            completion(plan: plan)
        }
    }
    
    func eventOrganization(organization: PFObject, completion:(events: [PFObject]) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if var eventArray = organization["events"] as? [PFObject] {
                for event in eventArray {
                    do {
                        try event.fetchIfNeeded()
                    } catch {
                        print("Error fetch event")
                        if let indexEvent = eventArray.indexOf(event) {
                            eventArray.removeAtIndex(indexEvent)
                        }
                    }
                }
                let searchPredicate = NSPredicate(format: "startDate >= %@", NSDate())
                var array = (eventArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
                let ar = array as! [PFObject]
                let user = UserManager().currentUser()
                let eventUser = user["events"] as? [PFObject]
                var events = [PFObject]()
                for event in eventArray {
                    let e = event as PFObject
                    if eventUser!.contains(e) {
                        events.append(e)
                    } else {
                        if e["isPrivate"] as! Bool == false {
                            events.append(e)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completion(events: events)
                }
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(events: [PFObject]())
            }
        })
    }
    
   
    func followingEvents(user: PFObject, completion:(events: [Dictionary<String, AnyObject>]) -> Void) {
        let query = PFQuery(className: "Organizations")
        query.whereKey("members", equalTo: UserManager().currentUser().objectId!)
        query.includeKeys(["events"])
        
        query.findObjectsInBackgroundWithBlock { (result, error) in
            var events = [PFObject]()
            if result != nil {
                
                if let organizations = result {
                    for organization in organizations {
                        var withoutEvents: [PFObject] = UserManager().currentUser()["events"] as! [PFObject]
                        let eventsBlackList = UserManager().currentUser()["eventsBlackList"] as! [PFObject]
                        withoutEvents += eventsBlackList
                        
                        if var eventsOrg = organization["events"] as? [PFObject] {
                            for event in withoutEvents {
                                if let indexObj = eventsOrg.indexOf(event) {
                                    eventsOrg.removeAtIndex(indexObj)
                                }
                            }
                            events += eventsOrg
                        }
                    }
                }
            }
            var plan = [Dictionary<String, AnyObject>]()
            let todayEvents = self.eventsInDay(NSDate(), events: events, showPrivate: true)
            
            if todayEvents.count > 0 {
                let section = ["title" : TypeEventsSection.Today.rawValue,
                                "events" : todayEvents]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            
            let eventsThisWeek = self.eventsThisWeek(events, showPrivate: true)
            
            if eventsThisWeek.count > 0 {
                let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                    "events" : eventsThisWeek]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            
            let eventsFuture = self.eventsFuture(events, showPrivate: true)
            if eventsFuture.count > 0 {
                let section = ["title" : TypeEventsSection.Future.rawValue,
                    "events" : eventsFuture]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
            completion(events: plan)
        }
    }
    
    func eventInformation(event: PFObject) -> [Dictionary<String, AnyObject>] {
        var information = [Dictionary<String, AnyObject>]()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE\nLLLL, dd"
        let dayEventString = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
        
        information.append(["icon" : "calander_icon_event",
                            "value" : dayEventString,
                            "needShowAccessory" : true])
        
        let dayEventEndString = dateFormatter.stringFromDate(event["endDate"] as! NSDate)
        
        information.append(["icon" : "calander_icon_event",
            "value" : dayEventEndString,
            "needShowAccessory" : true])
        
        dateFormatter.dateFormat = "h:mm a"
        let startTimeString = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
        let endTimeString = dateFormatter.stringFromDate(event["endDate"] as! NSDate)
        
        information.append(["icon" : "clock_icon_event",
                            "value" : startTimeString + " - " + endTimeString,
                            "needShowAccessory" : true])
        
        information.append(["icon" : "map_icon_event",
                            "value" : event["address"],
                            "needShowAccessory" : true])
        
        let isPrivateEvent = event["isPrivate"] as! Bool
        
        information.append(["icon" : "lock_icon_event",
                            "value" : (isPrivateEvent ? "Private" : "Public"),
                            "needShowAccessory" : false])
        
        information.append(["icon" : "money_icon_event",
                            "value" : event["cost"],
                            "needShowAccessory" : false])
        
        return information
    }
    
    func eventParticipants(event: PFObject, completion: ([PFUser]?, NSError?, PFObject?) -> Void) {
        let query = PFUser.query()!
        query.whereKey("events", containedIn: [event])
        query.findObjectsInBackgroundWithBlock { (results, error) in
            if results != nil {
                let users = results as! [PFUser]
                completion(users, error, event)
            } else {
                completion(nil, error, event)
            }
        }
    }
    
    func allEventsForUser(user: PFUser, completion: ([PFObject]) -> Void) {
        var eventsIds = [String]()
        
        if let eventArray = user["events"] as? [PFObject] {
            for event in eventArray {
                if let eventId = event.objectId {
                    eventsIds.append(eventId)
                }
            }
        }
        
        let query = PFQuery(className: "Events")
        query.includeKeys(["picture", "organization"])
        query.whereKey("objectId", containedIn: eventsIds)
        
        query.findObjectsInBackgroundWithBlock { (events, error) in
            if events != nil {
                completion(events!)
            } else {
                completion([PFObject]())
            }
        }
    }
    
    func eventsInDay(day: NSDate, events: [PFObject], showPrivate: Bool) -> [PFObject] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheDay: NSDate? = nil
        var endOfDay: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.Weekday, startDate: &startOfTheDay, interval: &timeInterval, forDate: day)
        endOfDay = startOfTheDay?.dateByAddingTimeInterval(timeInterval - 1)
        
        let predicateFormat = showPrivate ? "(startDate >= %@) AND (startDate <= %@)" :
                                            "(startDate >= %@) AND (startDate <= %@) AND (isPrivate = false)"
        
        let searchPredicate = NSPredicate(format: predicateFormat, startOfTheDay!, endOfDay!)
        var array = (events as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFObject]
        
        array.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
            let date1 = event1["startDate"] as? NSDate
            let date2 = event2["startDate"] as? NSDate
            return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
        }
        
        return array
    }
    
    func allEvents(completion: ([PFObject]) -> Void) {
        let query = PFQuery(className: "Events")
        query.includeKeys(["organization"])
        query.whereKey("startDate", greaterThan: NSDate())
        query.whereKey("isPrivate", equalTo: false);
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if result != nil {
                completion(result!)
            } else {
                completion([PFObject]())
            }
        })
    }

    func createEvent(organization: PFObject, event: PFObject, name: String, start: NSDate, end: NSDate, isPrivate: Bool, cost: Float, picture: UIImage, description: String, address: String, coordinate: CLLocationCoordinate2D, completion: (success: Bool, event: PFObject?) -> Void) {
        event["name"] = name
        event["startDate"] = start
        event["endDate"] = end
        event["isPrivate"] = isPrivate
        event["cost"] = cost
        event["address"] = address
        event["latitude"] = coordinate.latitude
        event["longitude"] = coordinate.longitude
        event["description"] = description
        event["organization"] = organization
        uploadImage(picture) { [weak self] (imageURL, storagePath, error) in
            guard error == nil else {
                //self.showAlert("Error".localized(), message: "Failed to upload avatar".localized())
                completion(success: false, event: nil)
                return
            }
            
            guard let url = imageURL else {
                //self.showAlert("Error".localized(), message: "Image URL is lost".localized())
                completion(success: false, event: nil)
                return
            }
            
            let eventPicture = PFObject(className: "Pictures")
            //let imageData = UIImageJPEGRepresentation(picture, 0.5)
            //let imageFile = PFFile(name: name, data: imageData!)
            eventPicture["imageURL"] = imageURL?.absoluteString
            eventPicture["storagePath"] = storagePath
            
            eventPicture.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    event["picture"] = eventPicture
                    event.saveInBackgroundWithBlock({ (success, error) in
                        if success {
                            if var events = organization["events"] as? [PFObject] {
                                if !events.contains(event) {
                                    events.append(event)
                                }
                                organization["events"] = events
                            } else {
                                organization["events"] = [event]
                            }
                            organization.saveInBackground()
                            UserManager().goOnEvent(event, completion: { (success) in
                                if success == false{
                                    print("Error add user")
                                }
                            })
                            OrganizationManager().addEvent(organization, event: event, completion: { (success) in
                                if success == false{
                                    print("Error add org")
                                }
                            })
                            completion(success: success, event: event)
                        } else {
                            completion(success: success, event: nil)
                        }
                    })
                } else {
                    completion(success: success, event: nil)
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, withCompletion completion: ((imageURL: NSURL?, storagePath: String?, error: NSError?) -> Void)?) {
        let filename = String.unique()
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imagePath = "eventImage/\(filename).jpg"
        let imagePathRef = storageRef.child(imagePath)
        
        let uploadTask = imagePathRef.putData(imageData, metadata: nil) { (metaData, error) in
            if let err = error {
                completion?(imageURL: nil, storagePath: nil, error: err)
            } else {
                let downloadURL = metaData!.downloadURL()
                completion?(imageURL: downloadURL, storagePath: imagePath, error: nil)
            }
        }
        
        uploadTask.resume()
    }
    
    func pulsingEvents(countUserForPulsing: Int = 10, isPulsingRequest: Bool = false, completion: ([Dictionary<String, AnyObject>]) -> Void) {
        let eventsBlackList = UserManager().currentUser()["eventsBlackList"] as! [PFObject]
        var objectIdEventsBlackList: [String] = []
        for event in eventsBlackList {
            objectIdEventsBlackList.append(event.objectId!)
        }
        let query = PFQuery(className: "Events")
        query.includeKeys(["organization"])
        query.whereKey("startDate", greaterThan: NSDate())
        query.whereKey("isPrivate", equalTo: false)
        if !isPulsingRequest {
            query.whereKey("objectId", notContainedIn: objectIdEventsBlackList)
        }
        var pulsingEvents = [Dictionary<String, AnyObject>]()
        
        query.findObjectsInBackgroundWithBlock({[weak self] (result, error) in
            var arrayPulsingEvents = [PFObject]()
            
            if result != nil {
                var countEvents = 0
                
                if result!.count < 1 {
                    completion(pulsingEvents)
                    return
                }
                for event in result! {
                    self?.eventParticipants(event, completion: { (users, error, event) in
                        countEvents += 1
                        if users?.count > countUserForPulsing {
                            arrayPulsingEvents.append(event!)
                        }
                        if countEvents == result!.count {
                            if var todayEvents = self?.eventsInDay(NSDate(), events: arrayPulsingEvents, showPrivate: false) {
                                if todayEvents.count > 0 {
                                    todayEvents.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                                        let date1 = event1["startDate"] as? NSDate
                                        let date2 = event2["startDate"] as? NSDate
                                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                                    }
                                    let section = ["title" : TypeEventsSection.Today.rawValue,
                                                   "events" : todayEvents]
                                    pulsingEvents.append(section as! Dictionary<String, AnyObject>)
                                }
                            }
                            if var eventsThisWeek = self?.eventsThisWeek(arrayPulsingEvents, showPrivate: false) {
                                if eventsThisWeek.count > 0 {
                                    eventsThisWeek.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                                        let date1 = event1["startDate"] as? NSDate
                                        let date2 = event2["startDate"] as? NSDate
                                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                                    }
                                    let section = ["title" : TypeEventsSection.ThisWeek.rawValue,
                                                   "events" : eventsThisWeek]
                                    pulsingEvents.append(section as! Dictionary<String, AnyObject>)
                                }
                            }
                            if var eventsFuture = self?.eventsFuture(arrayPulsingEvents, showPrivate: false) {
                                if eventsFuture.count > 0 {
                                    eventsFuture.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                                        let date1 = event1["startDate"] as? NSDate
                                        let date2 = event2["startDate"] as? NSDate
                                        return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                                    }
                                    let section = ["title" : TypeEventsSection.Future.rawValue,
                                                   "events" : eventsFuture]
                                    pulsingEvents.append(section as! Dictionary<String, AnyObject>)
                                }
                            }
                            completion(pulsingEvents)
                        }
                    })
                }
            } else {
                completion(pulsingEvents)
            }
        })
    }
    
    func eventsThisWeek(events: [PFObject], showPrivate: Bool) -> [PFObject] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheWeek: NSDate? = nil
        var endOfWeek: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfTheWeek, interval: &timeInterval, forDate: NSDate())
        endOfWeek = startOfTheWeek?.dateByAddingTimeInterval(timeInterval - 1)
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 1
        let tomorrow = calendar.dateByAddingComponents(dateComponents, toDate: NSDate(), options: NSCalendarOptions())
        let predicateFormat = showPrivate ? "(startDate >= %@) AND (startDate <= %@)" :
                                            "(startDate >= %@) AND (startDate <= %@) AND (isPrivate = false)"
        let searchPredicate = NSPredicate(format: predicateFormat, tomorrow!.resetTime(), endOfWeek!)
        var array = (events as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFObject]
        
        array.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
            let date1 = event1["startDate"] as? NSDate
            let date2 = event2["startDate"] as? NSDate
            return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
        }
        
        return array
    }
    
    func eventsFuture(events: [PFObject], showPrivate: Bool) -> [PFObject] {
        let calendar = NSCalendar.currentCalendar()
        var startOfTheWeek: NSDate? = nil
        var endOfWeek: NSDate? = nil
        var timeInterval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfTheWeek, interval: &timeInterval, forDate: NSDate())
        endOfWeek = startOfTheWeek?.dateByAddingTimeInterval(timeInterval - 1)
        
        let predicateFormat = showPrivate ? "startDate > %@" :
                                            "(startDate > %@) AND (isPrivate = false)"
        let searchPredicate = NSPredicate(format: predicateFormat, endOfWeek!)
        var array = (events as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFObject]
        
        array.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
            let date1 = event1["startDate"] as? NSDate
            let date2 = event2["startDate"] as? NSDate
            return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
        }
        
        return array
    }
    
    func deleteEvent(event: PFObject, completion: (succes: Bool) -> Void) {
        event.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if !success {
                print("Error, \(error?.description)")
            }
            completion(succes: success)
        }
    }
}
