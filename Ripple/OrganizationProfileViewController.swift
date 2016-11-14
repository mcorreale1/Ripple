//
//  OrganizationProfile1.swift
//  Ripple
//
//  Created by Adam Gluck on 2/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORLocalizationSystem
import ORCommonCode_Swift
import ORCommonUI_Swift

class OrganizationProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var organizationDescriptionTextView: UITextView!
    
    
    @IBOutlet weak var profilePictureButton: ProfilePictureButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBOutlet weak var bottonLCDescrTextView: NSLayoutConstraint!
    
    var events = [PFObject]()
    var members = [PFUser]()
    
    var isNewOrg: Bool = true
    var organizationPicture: UIImage?
    
    var organization: PFObject?
    var organizationName = ""
    var organizattionDescription = ""
    
    var titleMessage :String = ""
    var message :String = ""
    
    var isEventCreate = false
    let titleColor = UIColor.init(red: 46/255, green:49/255, blue: 146/255, alpha: 1)
    var alertController = UIAlertController()
    
    let maxLengthOrganizationDescription = 251
    deinit {
        or_removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrganizationProfileViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrganizationProfileViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        or_addObserver(self, selector: #selector(onEventIsCreate), name: PulseNotification.PulseNotificationIsEveentCreate.rawValue)
        prepareViews()
        prepareData()
        prepareTableView()
        prepareFunctionality()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.whiteColor()
        let titleColor = UIColor.init(red: 46/255, green:49/255, blue: 146/255, alpha: 1)
        nav?.tintColor = titleColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        doneProfileTouched(self)
        self.view.endEditing(true)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.init(red: 46/255, green:49/255, blue: 146/255, alpha: 1)
        prepareData()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if isEventCreate {
            isEventCreate = false
            EventManager().eventOrganization(organization!) {[weak self] (events) in
                self?.events = events
                self?.events.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                    let date1 = event1["startDate"] as? NSDate
                    let date2 = event2["startDate"] as? NSDate
                    return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                }
                
                self?.tableView.reloadData()
            }
        }
    }

    func showEmptyOrganizationAlert(msg: String, completion: (() -> Void)? = nil) {
        titleMessage = NSLocalizedString("Error", comment: "Error")
        message = msg
//
        showAlert(self.titleMessage, message: self.message, completion: completion)
    }
    
    func checkFieldsAndShowAlertIfNeeded() -> Bool {
        let alertCompletionBlock = {
            self.editProfileTouched(self)
        }
        
        if organizationName.isEmpty {
            showEmptyOrganizationAlert(NSLocalizedString("The organization was not created. Please, enter organization name", comment: "The organization was not created. Please, enter organization name"), completion: alertCompletionBlock)
            return false
        }
        if organizattionDescription.isEmpty {
            self.titleMessage = NSLocalizedString("Error", comment: "Error")
            showEmptyOrganizationAlert(NSLocalizedString("The organization was not created. Please, enter organization description", comment: "The organization was not created. Please, enter organization name"), completion: setFieldEnable)
            return false
        }
        
        if self.organizationPicture == nil {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
            navigationItem.rightBarButtonItem = editButton

            let userAlert = UIAlertController(title: "The organization was not created. Please, upload profile images and press done", message:  "", preferredStyle: UIAlertControllerStyle.Alert)
            userAlert.addAction(UIAlertAction(title: "Upload", style: .Default, handler: { (action) -> Void in
                self.onChangeProfilePicturetouchUp(self)
            }))
            self.presentViewController(userAlert, animated: true, completion: nil)
            
            return false
        }
 
        return true
    }

    func prepareFunctionality()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
    }
    
    func prepareData() {
        EventManager().eventOrganization(organization!) {[weak self] (events) in
            self?.events = events
            self?.events.sortInPlace { (event1: PFObject, event2: PFObject) -> Bool in
                let date1 = event1["startDate"] as? NSDate
                let date2 = event2["startDate"] as? NSDate
                return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
            }

            self?.tableView.reloadData()
        }
        
        OrganizationManager().membersInOrganizations(organization!) { [weak self] (result) in
            if result != nil {
                self?.members = result!
                self?.members.sortInPlace { (user1: PFObject, user2: PFObject) -> Bool in
                    let name1 = user1["fullName"] as? String
                    let name2 = user2["fullName"] as? String
                    return name1?.lowercaseString < name2?.lowercaseString
                }
                self?.memberCountLabel.text = String(result!.count) + " " + NSLocalizedString("Members", comment: "Members")
                if var members = self?.organization!["members"] as? [String] {
                    if let userId = PFUser.currentUser()?.objectId {
                        if !members.contains(userId) {
                            members.append(userId)
                            self?.organization!["members"] = members
                        }
                    }
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Notifications
    
    func onEventIsCreate() {
        isEventCreate = true
    }
    
    func prepareViews() {
        memberCountLabel.text = ""
        
        if let name = organization!["name"] as? String {
            organizationName = name
        }
        
        if let info = organization!["info"] as? String {
            organizattionDescription = info
        }
        
        title = organization!["name"] as? String
        
        organizationDescriptionTextView.hidden = true

        followButton.hidden = (isMyOrganization() || isAdmin())
        let nameIconFollowButton = OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: organization!) == .None ? "follow_button_profile" : "unfollow_button_profile"
        followButton.setImage(UIImage(named: nameIconFollowButton), forState: .Normal)

        title = organization!["name"] as? String
        
        self.navigationController?.navigationBar.tintColor = UIColor.init(red: 46/255, green:49/255, blue: 146/255, alpha: 1)
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
        navigationItem.rightBarButtonItem = editButton
        
        if !(isMyOrganization() || isAdmin()) {
            navigationItem.rightBarButtonItem = nil
        }
        let picture = organization?["picture"] as? PFObject
        
        PictureManager().loadPicture(picture, inButton: profilePictureButton)
        self.organizationPicture = picture == nil ? nil : profilePictureButton.backgroundImageForState(.Normal)
        
        eventsButton.titleLabel?.text = NSLocalizedString("Events", comment: "Events")
        membersButton.titleLabel?.text = NSLocalizedString("Members", comment: "Members")
        aboutButton.titleLabel?.text = NSLocalizedString("About", comment: "About")
        
        // set organization description
        if (organization!["info"] as? String) == "" {
            organizationDescriptionTextView.placeholder = "What are the details of your organization?"
        } else {
            organizationDescriptionTextView.text = organization!["info"] as? String
        }
        organizationDescriptionTextView.hidden = false
        organizationDescriptionTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        if (organization!["info"] as? String) != "" {
            organizationDescriptionTextView.text = organization!["info"] as? String
        }
        if !isMyOrganization() && !isAdmin(){
            let rightButton = UIBarButtonItem(image: UIImage(named: "report_button"), style: .Plain, target: self, action: #selector(sendReport))
            rightButton.tintColor = titleColor
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        
        let nibActionCell = UINib(nibName: "ActionTableViewCell", bundle: nil)
        tableView.registerNib(nibActionCell, forCellReuseIdentifier: "ActionTableViewCell")
    }
    
    // MARK: - Actions
    
    @IBAction func changeOrganizationSectionTouched(sender: UIButton) {
        self.view.endEditing(true)
        
        if ((organization!["name"] as? String) == "" || (organization!["info"] as? String) == "" || (organizationPicture == nil && isNewOrg)) && isMyOrganization() {
            showAlert("Error", message: "Please, make sure you've written the name, the description of the organization and press Done")
            return
        }
        eventsButton.selected = false
        membersButton.selected = false
        aboutButton.selected = false
        sender.selected = true
        tableView.hidden = false
        organizationDescriptionTextView.hidden = true
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.reloadData()
        if tableView.cellForRowAtIndexPath(indexPath) != nil {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    @IBAction func showAboutTouched(sender: UIButton) {
        eventsButton.selected = false
        membersButton.selected = false
        aboutButton.selected = true
        tableView.hidden = true
        organizationDescriptionTextView.hidden = false
        organizationDescriptionTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        if (organization!["info"] as? String) != "" {
            organizationDescriptionTextView.text = organization!["info"] as? String
        }
    }
    
    @IBAction func followToOrganizationTouched(sender: AnyObject) {
        if OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: organization!) == .Member {
            //UserManager().unfollow(UserManager().currentUser(), typeFollowing: .Organizations, object: organization!, completion: {[weak self] (success) in
            OrganizationManager().unfollowingUserOnOrganization(organization!, user: UserManager().currentUser(), completion: {[weak self] (success) in
                if success {
                    self?.followButton.setImage(UIImage(named: "follow_button_profile"), forState: .Normal)
                }
            })
        }
        else {
            OrganizationManager().followingOnOrganization(organization!, completion: {[weak self] (success) in
                if success {
                    self?.followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)
                }
                })
        }
    }
    
    func removeUserFromOrganization(indexObject: NSIndexPath) {
        
        if isMyOrganization() || isAdmin() {
            let user = members[indexObject.row - 1]
            //tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
            OrganizationManager().unfollowingUserOnOrganization(organization!, user: user, completion: { [weak self] (success) -> Void in
                if let sself = self {
                    if success {
                        if let objectIndex = sself.members.indexOf(user) {
                            sself.members.removeAtIndex(objectIndex)
                        }
                        
                        sself.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                        sself.tableView.reloadData()
                    } else {
                        sself.tableView.reloadData()
                        sself.showAlert("Error", message: "User remove failed. Please try again later")
                    }
                }
            })
        }
    }

    func removeEventFromOrganization(indexObject: NSIndexPath) {
        let event = events[indexObject.row -  ((isAdmin() || isMyOrganization()) ? 1 : 0)]
        OrganizationManager().deleteEvent(organization!, event: event, completion: {[weak self] success in
            if success {
                InvitationManager().deleteInvitationsByEvent(event, complition: {[weak self] (success) in
                    if success {
                        EventManager().deleteEvent(event, completion: {[weak self] (succes) in
                            if success {
                                print("Event delete completion")
                                if let indexObj = self?.events.indexOf(event) {
                                    self?.events.removeAtIndex(indexObj)
                                }
                                self?.tableView.beginUpdates()
                                self!.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                                self?.tableView.endUpdates()
                                self!.tableView.reloadData()
                                self!.prepareData()
                            }
                            })
                    }
                    })
            }
            self!.tableView.reloadData()
        })
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventsButton.selected {
            return (isMyOrganization() || isAdmin()) ? events.count + 1 : events.count
        }
        if membersButton.selected {
            return members.count + 1
        }
        return 0//showingEvents ? events.count : aboutOrganizationData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if eventsButton.selected {
            if isMyOrganization() || isAdmin()
            {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                    cell.titleLabel.text = NSLocalizedString("AddEvents", comment: "AddEvents")
                    return cell
                }
                if indexPath.row > 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
                    let event = events[indexPath.row - 1]
                    
                    cell.eventNameLabel.text = event["name"] as? String
                    cell.eventOrganizationNameLabel.text = title
                    cell.eventDescriptionLabel.text = event["description"] as? String
                    let picture = event["picture"] as? PFObject
                    PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd MMM"
                    cell.eventDateLabel.text = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
                    
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
                let event = events[indexPath.row]
                
                cell.eventNameLabel.text = event["name"] as? String
                cell.eventOrganizationNameLabel.text = title
                cell.eventDescriptionLabel.text = event["description"] as? String
                let picture = event["picture"] as? PFObject
                PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                cell.eventDateLabel.text = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
                
                return cell
            }
        }
        
        if membersButton.selected {
            var user: PFUser = PFUser()
            
            if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                    cell.titleLabel.text = NSLocalizedString("AddMembers", comment: "AddMembers")
                    return cell
            }
            user = members[indexPath.row - 1]
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
            
            if let picture = user["picture"] as? PFObject {
                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
            }
            cell.titleLabel.text = user["fullName"] as? String
            cell.descriptionLabel.text = ""
            return cell
        }
        
        return UITableViewCell()
    }
    // MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let sumLength = text.characters.count + textView.text.characters.count
        return sumLength < maxLengthOrganizationDescription || text.characters.count < 1
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        organizattionDescription = organizationDescriptionTextView.text
        organization!["info"] = organizattionDescription
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if eventsButton.selected {
            if indexPath.row == events.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                let height = cell.frame.height
                //return cell.frame.height
                return EventTableViewCell.kCellHeight
            } else {
                return EventTableViewCell.kCellHeight
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        return cell.frame.height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if eventsButton.selected && events.count > 0 && indexPath.row > 0 {
            if isMyOrganization() || isAdmin() {
                let event = events[indexPath.row - 1]
                if (isMyOrganization() || isAdmin()){
                    showEditVentViewController(organization, event: event)
                }
                else{
                        showEventDescriptionViewController(event)   
                }
            } else {
                let event = events[indexPath.row]
                showEventDescriptionViewController(event)
            }
        } else if membersButton.selected && members.count > 0 && indexPath.row > 0{
            let user = members[indexPath.row - 1]
            showProfileViewController(user)
        } else if membersButton.selected {
            showInviteUsersViewController(organization, event: nil)
        } else if eventsButton.selected {
            if isMyOrganization() || isAdmin(){
                showCreateEventViewController(organization)
            } else {
                let event = events[indexPath.row]
                showEventDescriptionViewController(event)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (isMyOrganization() || isAdmin()) && (indexPath.row != 0 || indexPath.section != 0) {
            if membersButton.selected {
                let user = members[indexPath.row - 1]
                return !userIsLeaderOrganization(user.objectId)
            }
            return true
        }
        
        return false
    }
    
     func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if eventsButton.selected {
            if isAdmin() || isMyOrganization() {
                let eventDeleteAction = UITableViewRowAction(style: .Default, title: "Remove") {[weak self] action, indexPath in
                    self?.removeEventFromOrganization(indexPath)
                }
                return [eventDeleteAction]
            }
        } else if membersButton.selected {
            var actions = [UITableViewRowAction]()
            let user = members[indexPath.row - 1]
            
            var removeButton = UITableViewRowAction()
            removeButton = UITableViewRowAction(style: .Default, title: "Remove\nMember") {[weak self] action, indexPath in
                self?.removeUserFromOrganization(indexPath)
            }
            
            actions.append(removeButton)
            var actionAdmin = UITableViewRowAction()
            
            if userIsAdminOrganization(user.objectId) && !userIsLeaderOrganization(user.objectId) {
                actionAdmin = UITableViewRowAction(style: .Default, title: "Remove\nan\nAdministrator") {[weak self] action, indexPath in
                    self?.removeUserFromAdmins(user)
                }
            } else {
                actionAdmin = UITableViewRowAction(style: .Normal, title: "Make\nan\nAdministrator") {[weak self] action, indexPath in
                    self?.addUserInAdmins(user)
                }
            }
            
            actions.append(actionAdmin)
            return actions
        }
        return nil
    }
    
    // MARK: - Helper
    
    private func isMyOrganization() -> Bool {
        return OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: organization!) == .Founder
    }
    
    private func isAdmin() -> Bool {
        return OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: organization!) == .Admin
    }
    
    private func addUserInAdmins(user: PFUser) {
        if user.objectId == nil {
            tableView.reloadData()
            return
        }
        
        OrganizationManager().addAdminOrganization(self.organization!, user: user, completion: {[weak self] succes in
            if succes {
                self?.tableView.reloadData()
            }
        })
    }
    
    private func removeUserFromAdmins(user: PFUser) {
        if user.objectId == nil {
            tableView.reloadData()
            return
        }
        
        OrganizationManager().removeAdminOrganization(self.organization!, user: user, completion: {[weak self] succes in
            if succes {
                self?.tableView.reloadData()
            }
        })
    }
    
    func userIsAdminOrganization(userId: String?) -> Bool {
        if userId != nil {
            if let admins = organization!["admins"] as? [String] {
                return admins.contains(userId!)
            }
        }
        
        return false
    }
    
    func userIsLeaderOrganization(userId: String?) -> Bool {
        if userId != nil {
            if let leaderId = organization!["leaderId"] as? String {
                return leaderId == userId
            }
        }
        return false
    }
    
    func editProfileTouched(sender: AnyObject) {
        self.view.endEditing(true)
        setFieldEnable()
        titleMessage = NSLocalizedString("Organization Name", comment: "Organization Name")
        message = NSLocalizedString("Please, enter organization name", comment: "Please, enter organization name")
        showAlertController()
    }
    
    func setFieldEnable() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneProfileTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton
        
        
        if isMyOrganization() || isAdmin() {
            profilePictureButton.enabled = true
            organizationDescriptionTextView.editable = true
        }
        if (organization!["name"] as? String) == "" || (organization!["info"] as? String) == ""{
            showAboutTouched(aboutButton)
        }
    }
    
    func showAlertController() {
        alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Organization Name", comment: "Organization Name")
            textField.returnKeyType = UIReturnKeyType.Done
            textField.delegate = self
        }
        
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in
            if (self.organization!["name"] as? String) == "Organization name" {
                self.navigationController?.popViewControllerAnimated(true)
            }
            self.title = self.organization!["name"] as? String
        }
        
        titleMessage = NSLocalizedString("OK", comment: "OK")
        let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {
            [weak self] (result : UIAlertAction) -> Void in
            self!.organizationName = (self!.alertController.textFields?.first?.text)!
            if self!.organizationName.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
                self?.showAlertController()
            } else {
                self!.organization!["name"] = self!.organizationName
                self?.title = self!.organization!["name"] as? String
            }
            self!.view.frame.origin.y = 0
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func doneProfileTouched(sender: AnyObject) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        organizattionDescription = organizationDescriptionTextView.text
        organizationDescriptionTextView.editable = false
        organization!["info"] = organizattionDescription
        if ( organization!["events"] == nil){
            organization!["events"] = "[]"
        }
        if ( organization!["members"]) == nil{
            organization!["members"] = "[]"
        }

        navigationItem.rightBarButtonItem?.enabled = false

        if (checkFieldsAndShowAlertIfNeeded() == true) {
            saveOrganizationName()
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    func saveOrganizationName() {
        self.organization!["name"] = organizationName
        self.organization?.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if !success {
                self.showAlert("Error", message: "Change organization name failed")
                print(error?.description)
            } else {
                if (self.isMyOrganization() || self.isAdmin()) && self.isNewOrg {
                    self.isNewOrg = false
                    self.organization?.ACL?.publicWriteAccess = true
                    OrganizationManager().followingOnOrganization(self.organization!, completion: { succes in
                        if success {
                            if (self.organizationPicture != nil) {
                                self.refreshAvatarWithSaveOnServ(with: self.organizationPicture!)
                            }
                        } else {
                            return
                        }
                    })
                }
                
                //self.isNewOrg = false
            }
        }
    }
    
    
    @IBAction func onChangeProfilePicturetouchUp(sender: AnyObject) {
        if isMyOrganization() || isAdmin() {
            pickImage()
        }
    }
    
    func updateAvatar(withNewAvatarURL avatarURL: NSURL, storagePath: String, completion: ((updated: Bool, error: NSError?) -> Void)?) {
        //guard let organizationID = organization!["objectId"] else {
        guard let organizationID = organization?.objectId else {
            print("Unable to change avatar. User is not logged in")
            return
        }
    
        func changeImageURL(forPicture picture: PFObject) {
            picture["imageURL"] = avatarURL.absoluteString
            picture["storagePath"] = storagePath
            
            var objectsToSave: [PFObject] = [picture]
            
            if organization!["picture"] == nil {
                organization!["picture"] = picture
                objectsToSave.append(organization!)
            }
            
            PFObject.saveAllInBackground(objectsToSave) { (saved, error) in
                if let err = error {
                    completion?(updated: false, error: err)
                } else {
                    completion?(updated: saved, error: nil)
                }
            }
        }
        
        let profilePicQuery = PFQuery(className: "Pictures")
        profilePicQuery.whereKey("userId", equalTo: organizationID)
        profilePicQuery.getFirstObjectInBackgroundWithBlock { [weak self] (result, error) -> Void in
            var picture = result
            
            if picture != nil {
                if let imagePath = picture!["storagePath"] as? String {
                    self!.deleteImage(withStoragePath: imagePath, completion: nil)
                }
            } else {
                picture = PFObject(className: "Pictures")
                picture!["userId"] = organizationID
                picture!["owner"] = self!.organization
            }
            
            changeImageURL(forPicture: picture!)
        }
    }
    
    func refreshAvatarImage(withImage image: UIImage) {
        self.profilePictureButton.setBackgroundImage(image, forState: .Normal)
        self.organizationPicture = image
        
        if !isNewOrg {
            refreshAvatarWithSaveOnServ(with: image)
        }
    }
    
    func refreshAvatarWithSaveOnServ(with image: UIImage) {
        showActivityIndicator()
        
        //gunna have to change this if orgs are not users
        
        let onAvatarUpdateFinished = { [weak self] (updated: Bool, error: NSError?) in
            self!.hideActivityIndicator()
            
            if let err = error {
                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                
                self!.showAlert(self!.titleMessage.localized(), message: err.localizedDescription)
                self!.hideActivityIndicator()
            } else {
                self!.profilePictureButton.setBackgroundImage(image, forState: .Normal)
            }
        }
        
        uploadImage(image) { [weak self] (imageURL, storagePath, error) in
            guard error == nil else {
                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                self!.message = NSLocalizedString("Failed to upload avatar", comment: "Failed to upload avatar")
                self!.showAlert(self!.titleMessage, message: self!.message + ". Please try again later")
                
                self!.hideActivityIndicator()
                
                return
            }
            self!.isNewOrg = false
            
            guard let url = imageURL else {
                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                self!.message = NSLocalizedString("Image URL is lost", comment: "Image URL is lost")
                
                self!.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
                self!
                    .hideActivityIndicator()
                
                return
            }
            
            self!.updateAvatar(withNewAvatarURL: url, storagePath: storagePath!, completion: onAvatarUpdateFinished)
        }
    }
    
    func showAlertPopView(title: String, message: String) {
        let userAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        userAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popViewControllerAnimated(true)
        }))
        self.presentViewController(userAlert, animated: true, completion: nil)
    }
    
    func sendReport() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        let spamAction: UIAlertAction = UIAlertAction(title: "It’s Spam", style: .Default) { action -> Void in
            self.showAlert("Success", message: "")
            self.presentViewController(self.alertController, animated: true, completion: nil)
        }
        actionSheetController.addAction(spamAction)
        let inappropriateAction: UIAlertAction = UIAlertAction(title: "It’s Inappropriate", style: .Default) { action -> Void in
            ReportManager().sendReportInOrganization(UserManager().currentUser(), organization: self.organization!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                self!.showAlert("Success", message: "")
                })
        }
        actionSheetController.addAction(inappropriateAction)

        self.presentViewController(actionSheetController, animated: true, completion: nil)

    }
    
    override func cropVCDidFinishCrop(withImage image: UIImage?) {
        guard let img = image else {
            self.titleMessage = NSLocalizedString("Fail", comment: "Fail")
            self.message = NSLocalizedString("Failed to crop image!", comment: "Failed to crop image!")
            showAlert(self.titleMessage, message: self.message)
            return
        }
        
        refreshAvatarImage(withImage: img)
    }
    
    // MARK: - ImagePickerDelegate
    
    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { [weak self] in
            let mediaItem = info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]
            
            guard let image: UIImage = mediaItem as? UIImage else {
                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                self!.message = NSLocalizedString("Image is lost", comment: "Image is lost")
                self!.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
                return;
            }
            
            self!.showImageEditScreen(withImage: image, frameType: .Circle, maxSize: CGSize(width: 320.0, height: 320.0))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.view.frame.origin.y = -80
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let heighTabBar = tabBarController != nil ? tabBarController!.tabBar.height : 0
        if let userInfo = sender.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                bottonLCDescrTextView.constant = frame.size.height - heighTabBar - 80
                
                if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                    UIView.animateWithDuration(NSTimeInterval(duration), animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            bottonLCDescrTextView.constant = 0
            
            if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                UIView.animateWithDuration(NSTimeInterval(duration), animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
        self.view.frame.origin.y = 0
    }

    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
