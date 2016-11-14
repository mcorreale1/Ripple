//
//  ScheduleViewController.swift
//  Ripple
//
//  Created by evgeny on 04.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import JTCalendar
import Parse
import ORLocalizationSystem

class ScheduleViewController: BaseViewController, JTCalendarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let calendarManager = JTCalendarManager()
    let todayColor = UIColor.init(red: 216/255, green: 92/255, blue: 94/255, alpha: 1)
    let trashButtonColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
    let acceptButtonColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
    
    var allEvents = [PFObject]()
    var selectedDate = NSDate()
    var invitations = [PFObject]()
    var followingRequests: [FollowingRequestDetails] = []
    
    let showEventsInDayId = "showEventsInDay"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCalndar()
        prepareTableView()
        let titleInvitations = NSLocalizedString("Invitations", comment: "Invitations")
        let titleCalendar = NSLocalizedString("Calendar", comment: "Calendar")
        segmentControl.setTitle(titleInvitations, forSegmentAtIndex: 0)
        segmentControl.setTitle(titleCalendar, forSegmentAtIndex: 1)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareData()
    }
    
    // MARK: - Helpers

    func prepareCalndar() {
        calendarManager.delegate = self
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(NSDate())
    }
    
    func prepareData() {
        showActivityIndicator()
        EventManager().allEventsForUser(UserManager().currentUser()) {[weak self] (events) in
            self?.hideActivityIndicator()
            self?.allEvents = events
            self?.calendarManager.reload()
        }
        
        UserManager().followingRequests { [weak self] (requests: [FollowingRequestDetails]?, error: NSError?) in
            if error != nil {
                return
            }
            
            self?.followingRequests = requests!
            
            self?.tableView.dataSource = self
            self?.tableView.delegate = self
            self?.tableView.reloadData()
        }
        
        InvitationManager().invitations {[weak self] (result) in
            self?.invitations = result!
            self?.tableView.reloadData()
        }
    }
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
    }
    
    // MARK: - JTCalendarDelegate
    
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        let dayJTView = dayView as! JTCalendarDayView
        
        if calendarManager.dateHelper.date(NSDate(), isTheSameDayThan: dayJTView.date) {
            dayJTView.circleView.hidden = false
            dayJTView.circleView.backgroundColor = todayColor
            dayJTView.dotView.backgroundColor = UIColor.whiteColor()
            dayJTView.textLabel.textColor = UIColor.whiteColor()
        } else {
            dayJTView.circleView.hidden = true
            dayJTView.dotView.backgroundColor = todayColor
            
            if calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayJTView.date) {
                dayJTView.textLabel.textColor = UIColor.blackColor()
            } else {
                dayJTView.textLabel.textColor = UIColor.lightGrayColor()
            }
        }
        
        dayJTView.dotView.hidden = EventManager().eventsInDay(dayJTView.date, events: allEvents, showPrivate: true).count < 1
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        let dayJTView = dayView as! JTCalendarDayView
        selectedDate = dayJTView.date
        performSegueWithIdentifier(showEventsInDayId, sender: self)
    }
    
    func calendar(calendar: JTCalendarManager!, prepareMenuItemView menuItemView: UIView!, date: NSDate!) {
        if let label = menuItemView as? UILabel {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "LLLL yyyy"
            label.textAlignment = .Left
            label.text = dateFormatter.stringFromDate(date)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? invitations.count : followingRequests.count
    }
    
    func followingRequestCell(forIndexPath indexPath: NSIndexPath, inTableView tableView: UITableView) -> UITableViewCell {
        let requestDetails = followingRequests[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        let fromUser =  requestDetails.fromUser
        cell.titleLabel.text = fromUser["fullName"] as? String
        cell.descriptionLabel.text = "wants to follow you on Pulse"
        if let picture = fromUser["picture"] as? PFObject {
            PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
        } else {
            cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
        }
        cell.pictureImageView.cornerRadius = cell.pictureImageView.frame.width / 2
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            return followingRequestCell(forIndexPath: indexPath, inTableView: tableView)
        }
        
        let invitation = invitations[indexPath.row]
        
        if let typeInvitation = invitation["type"] as? String {
            switch typeInvitation {
            case TypeInvitation.User.rawValue:
                let user = invitation["fromUser"] as! PFObject
                let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
                cell.titleLabel.text = user["fullName"] as? String
                cell.descriptionLabel.text = "Has sent you follow request"
                if let picture = user["picture"] as? PFObject {
                    PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
                } else {
                    cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                return cell
            case TypeInvitation.Event.rawValue:
                let event = invitation["event"] as! PFObject
                let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
                cell.eventNameLabel.text = event["name"] as? String
                cell.eventDescriptionLabel.text = event["description"] as? String
                let organization = event["organization"] as? PFObject
                cell.eventOrganizationNameLabel.text =  organization!["name"] as? String
                if let picture = event["picture"] as? PFObject {
                    PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
                } else {
                    cell.eventPictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                let dateFormat = "dd MMM h:mm a"
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = dateFormat
                cell.eventDateLabel.text = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
                cell.accessoryImageView.hidden = true
                return cell
            case TypeInvitation.Organization.rawValue:
                let organization = invitation["organization"] as! PFObject
                let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
                cell.titleLabel.text = organization["name"] as? String
                cell.descriptionLabel.text = organization["info"] as? String
                if let picture = organization["picture"] as? PFObject {
                    PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
                } else {
                    cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM h:mm a"
                cell.dateLabel.textAlignment = .Left
                
                cell.dateLabel.text = dateFormatter.stringFromDate(invitation.createdAt!)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let trashButton = UITableViewRowAction(style: .Normal, title: "Trash") {[weak self] action, indexPath in
            
            let title = "Are you sure?"
            let message = ""
            let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
                self?.trashInvitationTouched(indexPath)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Remove and Report", style: .Default   , handler: { (action: UIAlertAction!) in
                self?.trashInvitationTouched(indexPath)
                //Block
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default   , handler: { (action: UIAlertAction!) in
            }))
            
            self!.presentViewController(refreshAlert, animated: true, completion: nil)
        }
        trashButton.backgroundColor = trashButtonColor
        
        var titleAcceptButton = "Join"
        
        if indexPath.section == 1 {
            titleAcceptButton = "Accept"
        } else {
            let invitation = invitations[indexPath.row]
            let typeInvitation = invitation["type"] as! String
            
            if typeInvitation == TypeInvitation.Event.rawValue {
                titleAcceptButton = "Going"
            } else if typeInvitation == TypeInvitation.User.rawValue {
                titleAcceptButton = "Accept"
            }
        }
        
        let acceptButton = UITableViewRowAction(style: .Normal, title: titleAcceptButton) {[weak self] action, indexPath in
            self?.acceptInvitationTouched(indexPath)
        }
        acceptButton.backgroundColor = acceptButtonColor
        return [trashButton, acceptButton]
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 60
        }
        
        let invitation = invitations[indexPath.row]
        
        if invitation["type"] as! String == "Event" {
            return EventTableViewCell.kCellHeight
        }
        return FollowingTableViewCell.kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section != 1 else {
            return
        }
        let invitation = invitations[indexPath.row]
        
        if invitation["type"] as? String != nil {
            switch invitation["type"] as! String {
            case "Event":
                let event = invitation["event"] as? PFObject
                if event != nil {
                    event!.fetchIfNeededInBackgroundWithBlock({ (result, error) in
                        if(error == nil) {
                            self.showEventDescriptionViewController(result!)
                        } else {
                            print(error)
                        }
                    })
                }
            case "Organization":
                let organisation = invitation["organization"] as? PFObject
                if organisation != nil {
                    organisation!.fetchIfNeededInBackgroundWithBlock({ (result, error) in
                        if(error == nil) {
                            self.showOrganizationProfileViewController(result!, isNewOrg: false)
                        } else {
                            print(error)
                        }
                    })
                }
            default:
                break
            }
        }
    }
    // MARK: - Actions
    
    func trashInvitationTouched(indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let requestDetails = followingRequests[indexPath.row]
            
            userManager.declineFollowingRequest(withID: requestDetails.requestID, withCompletion: { (success) in
                if success {
                    self.followingRequests.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    self.tableView.reloadData()
                } else {
                    self.showAlert("Fail".localized(), message: "Failed to accept following request. Please try later.")
                }
            })
            return
        }
        
        let invitation = invitations[indexPath.row]
        showActivityIndicator()
        InvitationManager().trashInvitation(invitation) {[weak self] (success) in
            self?.hideActivityIndicator()
            if success {
                self?.invitations.removeAtIndex(indexPath.row)
                self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                self?.tableView.reloadData()
            }
        }
    }
    
    let userManager: UserManager = {
        return UserManager()
    }()
    
    func acceptInvitationTouched(indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let requestDetails = followingRequests[indexPath.row]
            
            userManager.confirmFollowingRequest(withID: requestDetails.requestID, withCompletion: { [weak self] (success) in
                if success {
                    self?.showAlert("Success".localized(), message: "You have new follower now!".localized())
                    self?.followingRequests.removeAtIndex(indexPath.row)
                    self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                } else {
                    self?.showAlert("Fail".localized(), message: "Failed to accept following request. Please try later.")
                }
            })
            return
        }
        
        let invitation = invitations[indexPath.row]
        showActivityIndicator()
        InvitationManager().acceptInvitation(invitation) {[weak self] (success) in
            self?.hideActivityIndicator()
            if success {
                self?.invitations.removeAtIndex(indexPath.row)
                self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                for inv in (self?.invitations)! {
                    if (invitation["type"] as! String) == "Organization" && (inv["type"] as! String) == "Organization"{
                        if (inv["organization"] as! PFObject) == invitation["organization"] as! PFObject {
                            if let indexObj = self?.invitations.indexOf(inv) {
                                self?.invitations.removeAtIndex(indexObj)
                            }
                        }
                    } else if (invitation["type"] as! String) == "Event"  && (inv["type"] as! String) == "Event" {
                        if (inv["event"] as! PFObject) == invitation["event"] as! PFObject {
                            if let indexObj = self?.invitations.indexOf(inv) {
                                self?.invitations.removeAtIndex(indexObj)
                            }
                        }

                    }
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func valueSegmentedControleChanged(sender: UISegmentedControl) {
        prepareData()
        tableView.hidden = sender.selectedSegmentIndex == 1
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showEventsInDayId {
            let destinationViewController = segue.destinationViewController as! EventsInDayViewController
            destinationViewController.events = EventManager().eventsInDay(selectedDate, events: allEvents, showPrivate: true)
        }
    }
}
