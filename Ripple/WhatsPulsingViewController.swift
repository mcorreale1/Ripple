//
//  WhatsPulsingViewController.swift
//  Ripple
//
//  Created by evgeny on 09.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import CoreLocation

class WhatsPulsingViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var noEventLabel: UITextView!
    
    // the dictionaries to hold the events
    var followingPlan = [Dictionary<String, AnyObject>]()
    var allEventsPlan = [Dictionary<String, AnyObject>]()
    var sortedByGeolocationAllEventsPlan = [Dictionary<String, AnyObject>]()
    
    var selectedUser: Users?
    
    var following = [RippleEvent]()
    var pulsing = [RippleEvent]()
    var allEvents = [RippleEvent]()
    var filterEvents = [RippleEvent]()
    var allOrganizations = [Organizations]()
    var nearbyEvents = [RippleEvent]()
    
    var filteredFollowing = [RippleEvent]()
    var filteredPulsing = [RippleEvent]()
    var filteredAllEvents = [RippleEvent]()
    var filteredGeologicEvents = [RippleEvent]()
    
    let trashButtonColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
    let acceptButtonColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
    
    let titleColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)

    var locationManager: CLLocationManager!
    var userLocation:CLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading view")
        prepareLocationManager()
        prepareData()
        prepareTableView()
        if selectedUser == nil {
            selectedUser = UserManager().currentUser()
        }
        let title1 = NSLocalizedString("Following", comment: "Following")
        let title2 = NSLocalizedString("Pulsing", comment: "Pulsing")
        let title3 = "Nearby"
        
        segmentedControl.setTitle(title1, forSegmentAtIndex: 0)
        segmentedControl.setTitle(title2, forSegmentAtIndex: 1)
        segmentedControl.setTitle(title3, forSegmentAtIndex: 2)
        UserManager().radiusSearch = 50.0
    }
   
    private func prepareNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let searchbarbutton = UIBarButtonItem(image: UIImage(named: "SearchBar"), style: .Plain, target: self, action: #selector(WhatsPulsingViewController.seguetoSearch(_:)))
        searchbarbutton.tintColor = titleColor
        navigationItem.rightBarButtonItem = searchbarbutton
        navigationController?.navigationBar.tintColor = titleColor
    }

    func seguetoSearch(sender: AnyObject) {
        self.showSearchVIewController()
        //performSegueWithIdentifier("SegueToSearchVC", sender: self)
    }
    
    func prepaireView() {
        noEventLabel.hidden = true
        noEventLabel.text = ""
        noEventLabel.sizeToFit()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.sortedGeolocationAllEvents()
        tableView.reloadData()
        prepareNavigationBar()
        checkDeviceID()
    }
    
    func checkDeviceID() {
        if (UserManager().currentUser().deviceID == " ") {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let deviceID = Backendless.sharedInstance().messagingService.getRegistration().deviceId
                UserManager().currentUser().deviceID = deviceID
                UserManager().currentUser().save() { (success, error) in }
            }
        }
    }
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
        tableView.delegate = self
    }
    
    //why does it hide the activity indicator when loading the following events but not for pulsing events?
    func prepareData() {
        self.showActivityIndicator(allowInteraction: true)
        
        EventManager().pulsingEvents() { (result) in
            self.allEventsPlan = result
            self.sortedGeolocationAllEvents()
            self.tableView.reloadData()
            self.scrollTableViewAtFirstCell()
        }
        
        EventManager().followingEvents() { (events) in
            self.hideActivityIndicator()
            self.followingPlan = events
            self.following = self.updateEvents(events)
            self.tableView.reloadData()
            self.scrollTableViewAtFirstCell()
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
    
    //checks to see if the event is within your radius
    func isLocationEvents(event: RippleEvent) -> Bool {
        let eventLocation = CLLocation(latitude: event.latitude , longitude: event.longitude)
        
        if (eventLocation.distanceFromLocation(userLocation) as Double) < (Double(UserManager().radiusSearch) * 1609.34) {
            return true
        }
        
        return false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
    }
    
    //sorts the events and appends the ones in the radius to then be loaded
    private func sortedGeolocationAllEvents() {
        var tmpEvents = [RippleEvent]()
        var plan = [Dictionary<String, AnyObject>]()
        var pulsingEvents = [RippleEvent]()
        
        for sectionObject in allEventsPlan {
            tmpEvents.removeAll()
            let events = sectionObject["events"] as! [RippleEvent]
            
            for event in events {
                if isLocationEvents(event) && !tmpEvents.contains(event) {
                    tmpEvents.append(event)
                    pulsingEvents.append(event)
                }
            }
            
            tmpEvents.sortInPlace() { (e1, e2) in
                let loc1 = CLLocation(latitude: e1.latitude, longitude: e1.longitude)
                let loc2 = CLLocation(latitude: e2.latitude, longitude: e2.longitude)
                return loc1.distanceFromLocation(locationManager.location!) > loc2.distanceFromLocation(locationManager.location!)
            }
            
            if tmpEvents.count > 0 {
                let section = ["title" : sectionObject["title"],
                               "events" : tmpEvents]
                plan.append(section as! Dictionary<String, AnyObject>)
            }
        }
        
        //have to sort based upon eventmanager().eventparticipants, however i dont want to call the function over and over
        pulsing = pulsingEvents
        sortedByGeolocationAllEventsPlan = plan
        self.nearbyEvents = self.updateEvents(self.sortedByGeolocationAllEventsPlan)
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    // called in viewdidload, used to see what events are happening with orgs followed (seems to be in location radius as well)
    private func updateEvents(plan: [Dictionary<String, AnyObject>], withLocale: Bool? = false) -> [RippleEvent] {
        var resultEvents = [RippleEvent]()
        for sectionObject in plan {
            let events = sectionObject["events"]
            for event in events as! [RippleEvent] {
                if !(resultEvents.contains(event))  && (!withLocale! || isLocationEvents(event)){
                    resultEvents.append(event)
                }
            }
        }
        print("resultsEvents count \(resultEvents.count)")
        return resultEvents
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
            filteredFollowing = (following as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [RippleEvent]
        }
        
        if segmentedControl.selectedSegmentIndex == 1 {
            if pulsing.count > 0 {
                (pulsing as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [RippleEvent]
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 2 {
            filteredGeologicEvents = (pulsing as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [RippleEvent]
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //deprecated
//        if searchBar.text != "" {
//            return 1
//        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if followingPlan.count == 0 {
                setNoEventLabel()
            } else {
                resetNoEventLabel()
            }
            
            return followingPlan.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if pulsing.count == 0 {
                setNoEventLabel()
            } else {
                resetNoEventLabel()
            }
            
            return 1
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if sortedByGeolocationAllEventsPlan.count == 0 {
                setNoEventLabel()
            } else {
                resetNoEventLabel()
            }
            
            return sortedByGeolocationAllEventsPlan.count
        }
        return 0
    }
    
    func setNoEventLabel() {
        noEventLabel.hidden = false
        noEventLabel.text = "No events posted in your area. Get things pulsing! Email info@jettiapps.com to become a paid rep."
        noEventLabel.sizeToFit()
        tableView.backgroundColor = UIColor.init(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
    }
    
    func resetNoEventLabel() {
        noEventLabel.text = ""
        noEventLabel.hidden = true
        noEventLabel.sizeToFit()
    }
    //determines the amount of rows to put in each category, limits pulsing to 10
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //This is where it asks for sections, fix later
        if(section > 0) {
            return 0
        }

        if segmentedControl.selectedSegmentIndex == 0 {
            return (following.count <= 10) ? following.count : 10
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return (pulsing.count <= 10) ? pulsing.count : 10
        } else if segmentedControl.selectedSegmentIndex == 2 {
            return (nearbyEvents.count <= 10) ? nearbyEvents.count : 10
        }
        
        var sectionData = Dictionary<String, AnyObject>()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            sectionData = followingPlan[section]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return pulsing.count > 10 ? 10 : pulsing.count
        } else if segmentedControl.selectedSegmentIndex == 2 {
            sectionData = sortedByGeolocationAllEventsPlan[section]
        }
        
        let events = sectionData["events"] as! [RippleEvent]
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
        var sectionData = Dictionary<String, AnyObject>()
        
        var event: RippleEvent?
        var dateFormat = "dd MMM h:mm a"

        if(segmentedControl.selectedSegmentIndex == 0) {
            if (indexPath.section > 0) {
                return cell
            }
            event = following[indexPath.row]
            
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            event = pulsing[indexPath.row]
        } else {
            event = nearbyEvents[indexPath.row]
        }
        
        
        cell.eventNameLabel.text = event!.name
        cell.eventDescriptionLabel.text = event!.descr
        if let organization = event?.organization {
            cell.eventOrganizationNameLabel.text = organization.name
        } else {
            cell.eventOrganizationNameLabel.text = ""
        }
        let picture = event!.picture
        PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
        cell.eventPictureImageView.cornerRadius = cell.eventPictureImageView.frame.width / 2

        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        cell.eventDateLabel.text = dateFormatter.stringFromDate(event!.startDate!)
        
        return cell
    }
 
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
        let userEvents = UserManager().currentUser().events
        if segmentedControl.selectedSegmentIndex == 1 {
            if !userEvents.contains(pulsing[indexPath.row]) {
                rowActions.append(acceptButton)
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[indexPath.section]
            let sectionEvents = sectionData["events"] as! [RippleEvent]
            if !userEvents.contains(sectionEvents[indexPath.row]) {
                rowActions.append(acceptButton)
            }
        }
        
        return rowActions
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //DEPRECATED
//        if searchBar.text != "" {
//            return UIView()
//        }
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
        print("header title: \(header.titleHeader.text)")
        if(section == 0) {
            header.titleHeader.text = "All Events"
        } else {
            header.titleHeader.text = ""
        }
        return header
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.init(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
        return footer
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //DEPRECATED

            if segmentedControl.selectedSegmentIndex == 1 {
                return 0
            }
            return 32
        }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EventTableViewCell.kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let sectionData = followingPlan[indexPath.section]
            let events = sectionData["events"] as! [RippleEvent]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
        }
        
        if segmentedControl.selectedSegmentIndex == 1 {
            let event = pulsing[indexPath.row]
            showEventDescriptionViewController(event)
        }
        
        if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[indexPath.section]
            let events = sectionData["events"] as! [RippleEvent]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
        }
    }
    
    
    // MARK: - Actions
    
    func addToPlansObjectTouched(objectIndex: NSIndexPath) {
        var event = RippleEvent()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let sectionData = followingPlan[objectIndex.section]
            let events = sectionData["events"] as! [RippleEvent]
            event = events[objectIndex.row]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            event = pulsing[objectIndex.row]
        } else if segmentedControl.selectedSegmentIndex == 2 {
            let sectionData = sortedByGeolocationAllEventsPlan[objectIndex.section]
            let events = sectionData["events"] as! [RippleEvent]
            event = events[objectIndex.row]
        }
            
        if !event.isPrivate {
            UserManager().goOnEvent(event, completion: {[weak self] (success) in
                if success {
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    func trashObjectTouched(objectIndex: NSIndexPath){
        var event = RippleEvent()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            var sectionData = followingPlan[objectIndex.section]
            var events = sectionData["events"] as! [RippleEvent]
            event = events[objectIndex.row]
            events.removeAtIndex(objectIndex.row)
            sectionData["events"] = events
            followingPlan[objectIndex.section] = sectionData
            
            if let indexEvent = pulsing.indexOf(event) {
                pulsing.removeAtIndex(indexEvent)
            }
            
            var newSortedByGeolocationAllEventsPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in sortedByGeolocationAllEventsPlan {
                var events = sectionData["events"] as! [RippleEvent]
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
            event = pulsing[objectIndex.row]
            pulsing.removeAtIndex(objectIndex.row)
            
            var newSortedByGeolocationAllEventsPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in sortedByGeolocationAllEventsPlan {
                var events = sectionData["events"] as! [RippleEvent]
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
                var events = sectionData["events"] as! [RippleEvent]
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
            var events = sectionData["events"] as! [RippleEvent]
            event = events[objectIndex.row]
            events.removeAtIndex(objectIndex.row)
            sectionData["events"] = events
            sortedByGeolocationAllEventsPlan[objectIndex.section] = sectionData
            //self.tableView.reloadData()
            
            var newFollowingPlan: [Dictionary<String, AnyObject>] = []
            for sectionData in followingPlan {
                var events = sectionData["events"] as! [RippleEvent]
                if let indexEv = events.indexOf(event) {
                    events.removeAtIndex(indexEv)
                }
                var newSectionData = sectionData
                newSectionData["events"] = events
                newFollowingPlan.append(sectionData)
            }
            followingPlan = newFollowingPlan
            if let indexEvent = pulsing.indexOf(event) {
                pulsing.removeAtIndex(indexEvent)
            }
        }
        tableView.reloadData()
        UserManager().addEventInBlackList(event) { (success) in }
    }
    @IBAction func segmentedControlValueChaged(sender: AnyObject) {
        tableView.reloadData()
    }
}
