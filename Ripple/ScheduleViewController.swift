//
//  ScheduleViewController.swift
//  Ripple
//
//  Created by evgeny on 04.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import JTCalendar
import ORLocalizationSystem

class ScheduleViewController: BaseViewController, JTCalendarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let calendarManager = JTCalendarManager()
    let todayColor = UIColor.init(red: 97/255, green: 19/255, blue: 255/255, alpha: 1)
    let trashButtonColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
    let acceptButtonColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
    
    var allEvents = [RippleEvent]()
    var selectedDate = NSDate()
    var invitations = [Invitation]()
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
    
    //Prepares the calendar view and sets it to current date
    func prepareCalndar() {
        calendarManager.delegate = self
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(NSDate())
    }
    
    /*
     stores the users events in an array (allEvents) and then reloads
    the calendar so the user can see the events
     
     -also stores the following requests and any invitations the user has
     in the respective arrays
    */
    func prepareData() {
        showActivityIndicator()
        EventManager().allEventsForUser(UserManager().currentUser()) {[weak self] (events) in
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
        
        InvitationManager().invitations { (result) in
            if let invites = result {
                self.invitations = invites
            }
            
            self.tableView.reloadData()
        }
        hideActivityIndicator()
    }
    
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
        tableView.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
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
    
    //Formats the date for people to read easily
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
        cell.titleLabel.text = fromUser.name
        cell.descriptionLabel.text = "wants to follow you on Pulse"
        if let picture = fromUser.picture {
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
        if(invitations.count < indexPath.row) {
            return UITableViewCell()
        }
        let invitation = invitations[indexPath.row]
        
        /* determines which invitation it is and will do something based upon that information */
        
        if let typeInvitation = invitation.type {
            switch typeInvitation {
            case Invitation.typeInvitation.user.rawValue:
                let user = invitation.fromUser!
                let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
                cell.titleLabel.text = user.name
                cell.descriptionLabel.text = "Has sent you follow request"
                if let picture = user.picture {
                    PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
                } else {
                    cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                return cell
            case Invitation.typeInvitation.event.rawValue:
                let event = invitation.event!
                let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
                cell.eventNameLabel.text = event.name
                cell.eventDescriptionLabel.text = event.descr
                let organization = event.organization
                cell.eventOrganizationNameLabel.text = organization!.name
                if let picture = event.picture {
                    PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
                } else {
                    cell.eventPictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                let dateFormat = "dd MMM h:mm a"
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = dateFormat
                cell.eventDateLabel.text = dateFormatter.stringFromDate(event.startDate!)
                return cell
            case Invitation.typeInvitation.organization.rawValue:
                let organization = invitation.organization!
                let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
                cell.titleLabel.text = organization.name
                cell.descriptionLabel.text = organization.info
                if let picture = organization.picture {
                    PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
                } else {
                    cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
                }
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM h:mm a"
                cell.dateLabel.textAlignment = .Left
                
                cell.dateLabel.text = dateFormatter.stringFromDate(invitation.created)
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
    
    //gives the user an option to say yes or no to an invite
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
            let typeInvitation = invitation.type
            
            if typeInvitation == Invitation.typeInvitation.event.rawValue {
                titleAcceptButton = "Going"
            } else if typeInvitation == Invitation.typeInvitation.user.rawValue {
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
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Swipe left to view options"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 1) {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
        header.titleHeader.text = "Swipe left to view options"
        header.titleHeader.numberOfLines = 1
//        let privateUser = selectedUser!.isPrivate
//        if privateUser && !isMe  && !followingUsers.contains(selectedUser!) {
//            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
//            let myString = "This Account is Private."
//            let myAttribute = [ NSFontAttributeName : UIFont.boldSystemFontOfSize(25) ]
//            let myStr = NSMutableAttributedString(string: myString, attributes: myAttribute)
//            let myAttrString1 = NSAttributedString(string: "\n Follow the user to see their Plans, Events and Organizations")
//            myStr.appendAttributedString(myAttrString1)
//            header.titleHeader.attributedText = myStr
//            header.titleHeader.numberOfLines = 3
//            return header
//        }
//        
//        if orgsButton.selected || followingButton.selected && isMe && followingArray.count < 1 {
//            return UIView()
//        }
//        
//        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
//        let sectionData = plansButton.selected ? plans[section] : followingArray[section]
//        header.titleHeader.text = sectionData["title"] as? String
        return header
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
        
        if invitation.type == Invitation.typeInvitation.event.rawValue {
            return EventTableViewCell.kCellHeight
        }
        return FollowingTableViewCell.kCellHeight
    }
    
    //sends the user to the page he was invited too
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section != 1 else {
            return
        }
        let invitation = invitations[indexPath.row]
        
        if let typeInvitation = invitation.type {
            switch typeInvitation {
            case Invitation.typeInvitation.event.rawValue:
                self.showEventDescriptionViewController(invitation.event!)
            case Invitation.typeInvitation.organization.rawValue:
                self.showOrganizationProfileViewController(invitation.organization!, isNewOrg: false, fromInvite: true)
            default:
                break
            }
        }
    }
    
    // MARK: - Actions
    
    //deletes the invitation/following request
    func trashInvitationTouched(indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let requestDetails = followingRequests[indexPath.row]
            
            userManager.declineFollowingRequest(withID: requestDetails.requestID, withCompletion: { (success) in
                if success {
                    self.followingRequests.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    self.tableView.reloadData()
                } else {
                    self.showAlert("Fail".localized(), message: "Failed to decline following request. Please try later.")
                }
            })
            return
        }
        
        //removes invitation from user invitation list
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
    func publishMessageAsPushNotificationSync(message: String, deviceId: String) -> MessageStatus? {
        if(deviceId == " ") {
            return nil
        }
        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-text":"You have receieved a new message from"])
        var error: Fault?
        let messageStatus = Backendless.sharedInstance().messaging.publish("default", message: message,publishOptions:publishOptions,deliveryOptions:deliveryOptions,error: &error)
        if error == nil {
            print("MessageStatus = \(messageStatus.status) ['\(messageStatus.messageId)']")
            return messageStatus
        }
        else {
            print("Server reported an error: \(error)")
            return nil
        }
    }
    
    //accepts the invitation and then removes it from the invitation list
    func acceptInvitationTouched(indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let requestDetails = followingRequests[indexPath.row]
            
            userManager.confirmFollowingRequest(withID: requestDetails.requestID, withCompletion: { [weak self] (success) in
                if success {
                    let user = UserManager().currentUser().name
                    
                    if let deviceID = requestDetails.fromUser.getProperty("deviceID") as? String {
                        self!.publishMessageAsPushNotificationSync(user! + "has requested to follow you", deviceId: deviceID)
                    }
                    self?.showAlert("Success".localized(), message: "You have a new follower!".localized())
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
        InvitationManager().acceptInvitation(invitation) { (success) in
        
            self.hideActivityIndicator()
            if success {
                print("success accepting invite")
                self.invitations.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                for inv in self.invitations {
                    if invitation.type! == Invitation.typeInvitation.organization.rawValue && inv.type == Invitation.typeInvitation.organization.rawValue {
                        if inv.organization == invitation.organization {
                            if let indexObj = self.invitations.indexOf(inv) {
                                self.invitations.removeAtIndex(indexObj)
                            }
                        }
                    } else if invitation.type! == Invitation.typeInvitation.event.rawValue && inv.type == Invitation.typeInvitation.event.rawValue {
                        if inv.event == invitation.event {
                            if let indexObj = self.invitations.indexOf(inv) {
                                self.invitations.removeAtIndex(indexObj)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func valueSegmentedControleChanged(sender: UISegmentedControl) {
        prepareData()
        tableView.hidden = sender.selectedSegmentIndex == 1
        
        if sender.selectedSegmentIndex == 0
        {
            if UserManager().seenInvitationsBefore == false {
                
            let title = "Slide Right to see your options for invitiations"
            let message = ""
            let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
                
            }))
            self.presentViewController(refreshAlert, animated: true, completion: nil)
                UserManager().seenInvitationsBefore = true
        }
       }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showEventsInDayId {
            let destinationViewController = segue.destinationViewController as! EventsInDayViewController
            destinationViewController.events = EventManager().eventsInDay(selectedDate, events: allEvents, showPrivate: true)
        }
    }
}
