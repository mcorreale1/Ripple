//
//  EventsInDayViewController.swift
//  Ripple
//
//  Created by evgeny on 04.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import  ORLocalizationSystem

class EventsInDayViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    var events = [PFObject]()
    let eventCellIdentifier = "EventCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: eventCellIdentifier)
        
        if events.count > 0 {
            let event = events.first!
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "LLLL, dd yyyy"
            title = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
        } else {
            let label = UILabel()
            label.text = NSLocalizedString("You have no events for this date", comment: "You have no events for this date")
            label.font = label.font.fontWithSize(17)
            label.sizeToFit()
            label.center.x = (tableView.superview?.center.x)!
            label.center.y = CGFloat(tableView.center.y / 2)
            tableView.addSubview(label)
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(eventCellIdentifier) as! EventTableViewCell
        let event = events[indexPath.row]
        cell.eventNameLabel.text = event["name"] as? String
        cell.eventDescriptionLabel.text = event["description"] as? String
        
        if let organization = event["organization"] as? PFObject {
            cell.eventOrganizationNameLabel.text =  organization["name"] as? String
        }
        
        let picture = event["picture"] as? PFObject
        PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.eventDateLabel.text = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EventTableViewCell.kCellHeight
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        showEventDescriptionViewController(event)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
