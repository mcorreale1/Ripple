//
//  WhatsPulsingViewController.swift
//  Ripple
//
//  Created by evgeny on 09.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORLocalizationSystem
import CoreLocation

class WhatsPulsingViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var noEventLabel: UITextView!
    
    
    var followingPlan = [Dictionary<String, AnyObject>]()
    var allEventsPlan = [Dictionary<String, AnyObject>]()
    var sortedByGeolocationAllEventsPlan = [Dictionary<String, AnyObject>]()
    
    var following = [PFObject]()
    var pulsing = [PFObject]()
    var allEvents = [PFObject]()
    var filterEvents = [PFObject]()
    var allOrganizations = [PFObject]()
    var allEventsSortedByGoing = [PFObject]()
    
    var filteredFollowing = [PFObject]()
    var filteredPulsing = [PFObject]()
    var filteredAllEvents = [PFObject]()
    var filteredGeologicEvents = [PFObject]()
    
    var geoFilteredFollowing = [PFObject]()
    var geoFilteredPulsing = [PFObject]()
    var geoFilteredAllEvents = [PFObject]()
    
    let trashButtonColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
    let acceptButtonColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)

    var locationManager: CLLocationManager!
    var userLocation:CLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        prepareLocationManager()
        prepareTableView()
        self.navigationItem.title = NSLocalizedString("What's Pulsing", comment: "What's Pulsing")
        let title1 = NSLocalizedString("Following", comment: "Following")
        let title2 = NSLocalizedString("Pulsing", comment: "Pulsing")
        let title3 = "Nearby"
        
        segmentedControl.setTitle(title1, forSegmentAtIndex: 0)
        segmentedControl.setTitle(title2, forSegmentAtIndex: 1)
        segmentedControl.setTitle(title3, forSegmentAtIndex: 2)
        UserManager().radiusSearch = 50.0
    }
    
    func prepaireView() {
        noEventLabel.hidden = true
        noEventLabel.text = ""
        noEventLabel.sizeToFit()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sortedGeolocationAllEvents()
        //self.sortedByHighestPeopleGoing()
        tableView.reloadData()
    }
    

    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
    }
    
    func prepareData() {
        self.showActivityIndicator()
        
        EventManager.sharedInstance.pulsingEvents(0) {[weak self] (result) in
            self?.allEventsPlan = result
            self?.sortedGeolocationAllEvents()
            self?.tableView.reloadData()
            self?.scrollTableViewAtFirstCell()
        }
        
        EventManager().followingEvents(UserManager().currentUser()) {[weak self] (events) in
            self?.hideActivityIndicator()
            self?.followingPlan = events
            self?.following = (self?.updateEvents(events))!
            self?.tableView.reloadData()
            self?.scrollTableViewAtFirstCell()
        }
    }
    
    func prepareLocationManager() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func isLocationEvents(event: PFObject) -> Bool {
        let eventLocation = CLLocation(latitude: event["latitude"] as! CLLocationDegrees, longitude: event["longitude"] as! CLLocationDegrees)
        
        if (eventLocation.distanceFromLocation(userLocation) as Double) < (Double(UserManager().radiusSearch) * 1609.34) {
            return true
        }
        
        return false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
    }
    
    private func sortedGeolocationAllEvents() {
        var tmpEvents = [PFObject]()
        var plan = [Dictionary<String, AnyObject>]()
        
        for sectionObject in allEventsPlan {
            tmpEvents.removeAll()
            let events = sectionObject["events"] as! [PFObject]
            for event in events {
                if isLocationEvents(event) && !tmpEvents.contains(event) {
                    tmpEvents.append(event)
                }
            }
            if tmpEvents.count > 0 {
                let section = ["title" : sectionObject["title"],
                               "events" : tmpEvents]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
        }
        sortedByGeolocationAllEventsPlan = plan
        sortedByHighestPeopleGoing()
        tableView.reloadData()
    }
    
    private func updateEvents(plan: [Dictionary<String, AnyObject>], withLocale: Bool? = false) -> [PFObject] {
        var resultEvents = [PFObject]()
        for sectionObject in plan {
            let events = sectionObject["events"]
            for event in events as! [PFObject] {
                if !(resultEvents.contains(event))  && (!withLocale! || isLocationEvents(event)){
                    resultEvents.append(event)
                }
            }
        }
        return resultEvents
    }
    
    private func sortedByHighestPeopleGoing() {
        let allEvents = updateEvents(sortedByGeolocationAllEventsPlan, withLocale: true)
        var sortedEvents = [Dictionary<String, AnyObject>]()
        var count = 0
        for event in allEvents {
            EventManager().eventParticipants(event, completion: {[weak self] (users, error, events) in
                if let sself = self {
                    if error != nil {
                        print("Error, \(error!.description)")
                        return
                    }
                    count += 1
                    if users != nil {
                        let countPeopleEvent = ["event" : event, "peopleGoing" : users!.count]
                        sortedEvents.append(countPeopleEvent)
                        if sortedEvents.count > 1 {
                            sortedEvents.sortInPlace({ (event1, event2) -> Bool in
                                let countPeopleGoing1 = event1["peopleGoing"] as? Int
                                let countPeopleGoing2 = event2["peopleGoing"] as? Int
                                return countPeopleGoing1 > countPeopleGoing2
                            })
                        }
                    }
                    if count == allEvents.count {
                        sself.allEventsSortedByGoing.removeAll()
                        for sortedEvent in sortedEvents {
                            sself.allEventsSortedByGoing.append(sortedEvent["event"] as! PFObject)
                            sself.tableView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - Helpers
    
    private func scrollTableViewAtFirstCell() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        if tableView.cellForRowAtIndexPath(indexPath) != nil {
            tableView.scrollToRowAtIndexPath(indexPath,atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredFollowing = (following as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFUser]
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            if pulsing.count > 0 {
                filteredPulsing = (pulsing as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFUser]
            } else {
                filteredPulsing = (allEventsSortedByGoing as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFUser]
            }
        }
        if segmentedControl.selectedSegmentIndex == 2 {
            //filteredAllEvents = (allEvents as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFUser]
            filteredGeologicEvents = (sortedByGeolocationAllEventsPlan as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [PFUser]
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchBar.text != "" {
            return 1
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if followingPlan.count == 0 {
                setNoEventLabel()
            } else {resetNoEventLabel()}
            return followingPlan.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if sortedByGeolocationAllEventsPlan.count == 0 {
                setNoEventLabel()
            } else {
                resetNoEventLabel()
                return 1
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if sortedByGeolocationAllEventsPlan.count == 0 {
                setNoEventLabel()
            } else {resetNoEventLabel()}
            return sortedByGeolocationAllEventsPlan.count
        }
        return 0
    }
    
    func setNoEventLabel() {
        noEventLabel.hidden = false
        noEventLabel.text = "No events posted in your area. Get things pulsing! Email jettiinc123@gmail.com to become a paid rep."
        noEventLabel.sizeToFit()
        tableView.backgroundColor = UIColor.whiteColor()
    }
    
    func resetNoEventLabel() {
        noEventLabel.text = ""
        noEventLabel.hidden = true
        noEventLabel.sizeToFit()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.text != "" {
            if segmentedControl.selectedSegmentIndex == 0 {
                return filteredFollowing.count
            } else if segmentedControl.selectedSegmentIndex == 1 {
                return filteredPulsing.count
            } else if segmentedControl.selectedSegmentIndex == 2 {
                return filteredGeologicEvents.count
            }
        }
        
        var sectionData = Dictionary<String, AnyObject>()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            sectionData = followingPlan[section]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return allEventsSortedByGoing.count > 10 ? 10 : allEventsSortedByGoing.count
        } else if segmentedControl.selectedSegmentIndex == 2 {
            sectionData = sortedByGeolocationAllEventsPlan[section]
        }
        
        let events = sectionData["events"] as! [PFObject]
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
        var sectionData = Dictionary<String, AnyObject>()
        
        var event: PFObject?
        var dateFormat = "dd MMM h:mm a"
        
        
        if searchBar.text == "" && !(segmentedControl.selectedSegmentIndex == 1) {
            if segmentedControl.selectedSegmentIndex == 0 {
                sectionData = followingPlan[indexPath.section]
            } else if segmentedControl.selectedSegmentIndex == 2 {
                sectionData = sortedByGeolocationAllEventsPlan[indexPath.section]
            }
            switch sectionData["title"] as! String {
            case TypeEventsSection.Today.rawValue:
                dateFormat = "h:mm a"
            case TypeEventsSection.ThisWeek.rawValue:
                dateFormat = "EEEE"
            default:
                dateFormat = "dd MMM h:mm a"
            }
            let events = sectionData["events"] as! [PFObject]
            event = events[indexPath.row]
        } else if searchBar.text != "" {
            if segmentedControl.selectedSegmentIndex == 0 {
                event = filteredFollowing[indexPath.row]
            } else if segmentedControl.selectedSegmentIndex == 1 {
                event = filteredPulsing[indexPath.row]
            } else if segmentedControl.selectedSegmentIndex == 2 {
                event = filteredGeologicEvents[indexPath.row]
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            event = allEventsSortedByGoing[indexPath.row]
            dateFormat = "dd MMM h:mm a"
        }
        
        cell.eventNameLabel.text = event!["name"] as? String
        cell.eventDescriptionLabel.text = event!["description"] as? String
        if let organization = event?["organization"] as? PFObject {
            cell.eventOrganizationNameLabel.text = organization["name"] as? String
        } else {
            cell.eventOrganizationNameLabel.text = ""
        }
        let picture = event!["picture"] as? PFObject
        PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
        cell.eventPictureImageView.cornerRadius = cell.eventPictureImageView.frame.width / 2

        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        cell.eventDateLabel.text = dateFormatter.stringFromDate(event!["startDate"] as! NSDate)
        
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate
 
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
 
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var rowActions: [UITableViewRowAction] = []
        
        let trashButton = UITableViewRowAction(style: .Normal, title: "Trash") {[weak self] action, indexPath in
            self?.trashObjectTouched(indexPath)
        }
        trashButton.backgroundColor = trashButtonColor
        rowActions.append(trashButton)
        
        let acceptButton = UITableViewRowAction(style: .Normal, title: "Add\nto\nPlans") {[weak self] action, indexPath in
            self?.addToPlansObjectTouched(indexPath)
        }
        acceptButton.backgroundColor = acceptButtonColor
        let userEvents = UserManager().currentUser()["events"] as! [PFObject]
        if segmentedControl.selectedSegmentIndex == 1 {
            if !userEvents.contains(allEventsSortedByGoing[indexPath.row]) {
                rowActions.append(acceptButton)
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[indexPath.section]
            let sectionEvents = sectionData["events"] as! [PFObject]
            if !userEvents.contains(sectionEvents[indexPath.row]) {
                rowActions.append(acceptButton)
            }
        }
        
        return rowActions
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchBar.text != "" {
            return UIView()
        }
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
        var sectionData = Dictionary<String, AnyObject>()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            sectionData = followingPlan[section]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return UIView()
        } else if segmentedControl.selectedSegmentIndex == 2 {
            sectionData = sortedByGeolocationAllEventsPlan[section]
        }
        
        header.titleHeader.text = sectionData["title"] as? String
        return header
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return searchBar.text == "" ? 9 : 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchBar.text == "" {
            if segmentedControl.selectedSegmentIndex == 1 {
                return 0
            }
            return 32
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EventTableViewCell.kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let sectionData = followingPlan[indexPath.section]
            let events = sectionData["events"] as! [PFObject]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            let event = allEventsSortedByGoing[indexPath.row]
            showEventDescriptionViewController(event)

        }
        if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[indexPath.section]
            let events = sectionData["events"] as! [PFObject]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
        }
    }
    
    
    // MARK: - Actions
    
    func addToPlansObjectTouched(objectIndex: NSIndexPath) {
        //var sectionData: Dictionary<String,AnyObject>
        var event: PFObject = PFObject(className: "Events")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let sectionData = followingPlan[objectIndex.section]
            let events = sectionData["events"] as! [PFObject]
            event = events[objectIndex.row]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            event = allEventsSortedByGoing[objectIndex.row]
        } else if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[objectIndex.section]
            let events = sectionData["events"] as! [PFObject]
            event = events[objectIndex.row]
        }
        
            //let event = events[objectIndex.row]
            let isPrivate = event["isPrivate"] as? Bool
            
            if isPrivate == false {
                UserManager().goOnEvent(event, completion: {[weak self] (success) in
                    if success {
                        self?.tableView.reloadData()
                    }
                })
            }
    }
    
    func trashObjectTouched(objectIndex: NSIndexPath){
        var event: PFObject = PFObject(className: "Events")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            var sectionData = followingPlan[objectIndex.section]
            var events = sectionData["events"] as! [PFObject]
            event = events[objectIndex.row]
            events.removeAtIndex(objectIndex.row)
            sectionData["events"] = events
            followingPlan[objectIndex.section] = sectionData
            
            if let indexEvent = allEventsSortedByGoing.indexOf(event) {
                allEventsSortedByGoing.removeAtIndex(indexEvent)
            }
            
            var newSortedByGeolocationAllEventsPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in sortedByGeolocationAllEventsPlan {
                var events = sectionData["events"] as! [PFObject]
                if let indexEv = events.indexOf(event) {
                    events.removeAtIndex(indexEv)
                }
                var newSectionData = sectionData
                newSectionData["events"] = events
                newSortedByGeolocationAllEventsPlan.append(sectionData)
            }
            sortedByGeolocationAllEventsPlan = newSortedByGeolocationAllEventsPlan
            //self.tableView.reloadData()

        }
        
        if segmentedControl.selectedSegmentIndex == 1 {
            event = allEventsSortedByGoing[objectIndex.row]
            allEventsSortedByGoing.removeAtIndex(objectIndex.row)
            
            var newSortedByGeolocationAllEventsPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in sortedByGeolocationAllEventsPlan {
                var events = sectionData["events"] as! [PFObject]
                if let indexEv = events.indexOf(event) {
                    events.removeAtIndex(indexEv)
                }
                var newSectionData = sectionData
                newSectionData["events"] = events
                newSortedByGeolocationAllEventsPlan.append(sectionData)
            }
            sortedByGeolocationAllEventsPlan = newSortedByGeolocationAllEventsPlan
            
            var newFollowingPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in followingPlan {
                var events = sectionData["events"] as! [PFObject]
                if let indexEv = events.indexOf(event) {
                    events.removeAtIndex(indexEv)
                }
                var newSectionData = sectionData
                newSectionData["events"] = events
                newFollowingPlan.append(sectionData)
            }
            followingPlan = newFollowingPlan
            //self.tableView.reloadData()
            
        }
        
        if segmentedControl.selectedSegmentIndex == 2 {
            var sectionData = sortedByGeolocationAllEventsPlan[objectIndex.section]
            var events = sectionData["events"] as! [PFObject]
            event = events[objectIndex.row]
            events.removeAtIndex(objectIndex.row)
            sectionData["events"] = events
            sortedByGeolocationAllEventsPlan[objectIndex.section] = sectionData
            //self.tableView.reloadData()
            
            var newFollowingPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in followingPlan {
                var events = sectionData["events"] as! [PFObject]
                if let indexEv = events.indexOf(event) {
                    events.removeAtIndex(indexEv)
                }
                var newSectionData = sectionData
                newSectionData["events"] = events
                newFollowingPlan.append(sectionData)
            }
            followingPlan = newFollowingPlan
            if let indexEvent = allEventsSortedByGoing.indexOf(event) {
                allEventsSortedByGoing.removeAtIndex(indexEvent)
            }
        }
        tableView.reloadData()
        UserManager().addEventInBlackList(event) {[weak self] (success) in
            //self?.tableView.deleteRowsAtIndexPaths([objectIndex], withRowAnimation: .Left)
        }
    }
    
    @IBAction func segmentedControlValueChaged(sender: AnyObject) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}
