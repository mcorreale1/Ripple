//
//  MyEvent.swift
//  Ripple
//
//  Created by Adam Gluck on 2/10/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class EventDescriptionViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var event: RippleEvent?
    var org: Organizations?
    var participants: [Users]?
    let titleColor = UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameOrganizationLabel: UILabel!
    @IBOutlet weak var countGoingButton: UIButton!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var viewOrgButton: UIButton!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startDay: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var goingText :String = ""
    var okText  :String = ""
    var goText  :String = ""
    var cancelText  :String = ""
   
    var tempEventInformation = [Dictionary<String, AnyObject>]()
    var eventInformationTable = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goingText = NSLocalizedString("Going", comment: "Going")
        tempEventInformation = EventManager().eventInformation(event!)
        tempEventInformation.removeAtIndex(0)
        tempEventInformation.removeAtIndex(0)
        eventInformationTable = tempEventInformation
        self.countGoingButton.setTitle(nil, forState: .Normal)
        EventManager().eventParticipants(event!) {(users, error, event) in
            let title = String(users?.count ?? 0) + " " + (self.goingText ?? "")
            self.countGoingButton.setTitle(title, forState: .Normal)
            self.participants = users
        }
        if goButton.titleLabel?.text == "" {
            goButton.titleLabel?.text = "Go"
        }
        goText = NSLocalizedString("Go", comment: "Go")
        prepareTableView()
        self.org = event!.organization
        //tableView.allowsSelection = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //eventPictureImageView.layer.cornerRadius = eventPictureImageView.bounds.height / 2
        //hostedByLabel.text = NSLocalizedString("Hosted by", comment: "Hosted by")
        goingText = NSLocalizedString("Going", comment: "Going")
        okText = NSLocalizedString("Ok", comment: "Ok")
        goText = NSLocalizedString("Go", comment: "Go")
        cancelText = NSLocalizedString("Cancel", comment: "Cancel")

        prepareViews()
    }
    
    func monthNumberToName() -> String {
        let value = event!.startDate?.monthNumber()
        var name = ""
        if value == "01"
        {
            name = "Jan"
        }
        if value == "02"
        {
         name = "Feb"
        }
        if value == "03"
        {
            name = "Mar"
        }
        if value == "04"
        {
            name = "Apr"
        }
        if value == "05"
        {
            name = "May"
        }
        if value == "06"
        {
            name = "Jun"
        }
        if value == "07"
        {
            name = "Jul"
        }
        if value == "08"
        {
            name = "Aug"
        }
        if value == "09"
        {
            name = "Sep"
        }
        if value == "10"
        {
            name = "Oct"
        }
        if value == "11"
        {
            name = "Nov"
        }
        if value == "12"
        {
            name = "Dec"
        }
        return name
    }
    
    // MARK: - Helpers
    
    func prepareViews() {
        title = event?.name ?? ""
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        
        self.eventDescriptionLabel.numberOfLines = 0;
        self.eventDescriptionLabel.text = event!.descr
        self.startDay.text = event?.startDate?.day()
        self.startDate.text = monthNumberToName()
        self.eventDescriptionLabel.sizeToFit()
        self.nameOrganizationLabel.text = event!.organization?.name!
        self.nameOrganizationLabel.sizeToFit()
        self.eventNameLabel.text = event!.name!
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "report_button"), style: .Plain, target: self, action: #selector(sendReport))
        rightButton.tintColor = titleColor
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventDetailTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventDetailCell")
        
        if(UserManager().alreadyGoOnEvent(event!) == true){
            self.goButton.setTitle(self.goingText, forState: UIControlState.Normal)
        } else{
            self.goButton.setTitle(self.goText, forState: UIControlState.Normal)
        }
    }
    
    func prepareNotification() {
        if (event!.startDate!.isGreaterOrEqualThen(NSDate())) {
            let localNotification = UILocalNotification()
            localNotification.fireDate = event!.startDate
            localNotification.alertTitle = event!.name
            localNotification.alertBody = "\(event!.name) is starting right now!"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        if (goButton.titleLabel == "Go") {
            UIApplication.sharedApplication().cancelLocalNotification(localNotification)
        }
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if ( application.applicationState == UIApplicationState.Active){
            print("Active")
            self.redirectToPage()
            // App is foreground and notification is recieved,
            // Show a alert.
        }
        else if( application.applicationState == UIApplicationState.Background){
            print("Background")
            self.redirectToPage()
            // App is in background and notification is received,
            // You can fetch required data here don't do anything with UI.
        }
        else if( application.applicationState == UIApplicationState.Inactive){
            print("Inactive")
            self.redirectToPage()
            // App came in foreground by used clicking on notification,
            // Use userinfo for redirecting to specific view controller.
        }
    }

    
    func redirectToPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let eventDescriptionController = storyboard.instantiateViewControllerWithIdentifier("EventDescriptionViewController") as! EventDescriptionViewController
        eventDescriptionController.event = event
        navigationController?.showViewController(eventDescriptionController, sender: self)
    }
    
    func sendReport() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        //Fix editing events
        let userRole:TypeRoleUserInOrganization = OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: org!)
        if(userRole == .Admin || userRole == .Founder) {
            let editAction:UIAlertAction = UIAlertAction(title: "Edit Event", style: .Default) { action -> Void in
                self.showEditEventViewController(self.org, event: self.event!)
            }
            //actionSheetController.addAction(editAction)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        let spamAction: UIAlertAction = UIAlertAction(title: "It’s Spam", style: .Default) { action -> Void in
            ReportManager().sendReportOnFollow(UserManager().currentUser(), completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                self?.showAlert("Success", message: "")
                })
        }
        actionSheetController.addAction(spamAction)
        let inappropriateAction: UIAlertAction = UIAlertAction(title: "It’s Inappropriate", style: .Default) { action -> Void in
            ReportManager().sendReportOnFollow(UserManager().currentUser(), completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                self?.showAlert("Success", message: "")
                })
        }
        actionSheetController.addAction(inappropriateAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventInformationTable.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventDetailCell") as! EventDetailTableViewCell
        let partInformation = eventInformationTable[indexPath.row]
        
        cell.iconImageView.image = UIImage(named: partInformation["icon"] as! String)
        let needShowAccessory = partInformation["needShowAccessory"] as! Bool
        cell.needShowAccessory(needShowAccessory)
        var value = partInformation["value"] as? String
        if value == nil {
            let buffer = partInformation["value"] as? Int
            value = String(buffer!) + " $"
        }
        cell.nameDetailLabel.text = value
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            var titleMessage = NSLocalizedString("Address", comment: "Address")
            let message = NSLocalizedString("Would you like to see it on map?", comment: "Would you like to see it on map?")
            let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
            titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
            let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in }
            titleMessage = NSLocalizedString("OK", comment: "OK")
            let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
                if self != nil && self?.event != nil {
                    self?.showAddressViewController(self!.event!)
                } else {
                    return
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoparticipants" {
            let destinationController = segue.destinationViewController as! EventParticipantsViewController
            destinationController.participants = participants
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func viewOrgButtonTouched(sender: AnyObject) {
        showOrganizationProfileViewController(event!.organization, isNewOrg: false, fromInvite: false)
    }

    @IBAction func settingsTouched(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsEventScreen", sender: self)
    }
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func goToEventTouch(sender: AnyObject) {
        var title: String
        var message: String
        if goButton.titleLabel!.text == goText {
            title = NSLocalizedString("This event will now be added to your Calendar and Plans", comment: "This event will now be added to your Calendar and Plans")
            message = NSLocalizedString("To remove this event from your schedule, just press the 'Going' button", comment: "To remove this event from your schedule, just press the 'Going' button")
        } else {
            title = NSLocalizedString("Are you sure you want to remove this event from your Calendar and Plans?", comment: "Are you sure you want to remove this event from your Calendar and Plans?")
            message = ""
        }
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: okText, style: .Default, handler: { (action: UIAlertAction!) in
            self.showActivityIndicator()
            
            if self.goButton.titleLabel!.text == self.goText {
                UserManager().goOnEvent(self.event!, completion: { (success) in
                    self.hideActivityIndicator()
                    
                    if success {
                        self.participants!.append(UserManager().currentUser())
                        let title = String(max(self.participants!.count, 0)) + " " + (self.goingText ?? "")
                        self.countGoingButton.setTitle(title, forState: .Normal)

                        self.goButton.setTitle(self.goingText, forState: UIControlState.Normal)
                        self.prepareNotification()
                    }
                })
            } else {
                UserManager().unGoOnEvent(self.event!, completion: { (success) in
                    self.hideActivityIndicator()
                    
                    if success {
                        let title = String(max(self.participants!.count - 1, 0)) + " " + (self.goingText ?? "")
                        self.countGoingButton.setTitle(title, forState: .Normal)
                        
                        self.goButton.setTitle(self.goText, forState: UIControlState.Normal)
                    }
                })
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: self.cancelText, style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
}
