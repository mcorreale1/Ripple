//
//  ProfileViewController.swift
//  Ripple
//
//  Created by evgeny on 11.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORLocalizationSystem
import Firebase
import SDWebImage

class ProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    override var chatSegueIdentifier: String { return "startChatWithUser" }
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureButton: ProfilePictureButton!
    
    @IBOutlet weak var plansButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var orgsButton: UIButton!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var userDescription: UILabel!
    
    var plans = [Dictionary<String, AnyObject>]()
    var organizationArray = [PFObject]()
    var followingArray = [Dictionary<String, AnyObject>]()
    var followingUser = [PFUser]()
    
    var selectedUser: PFUser?
    
    let titleColor = UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)
    
    var lengthEventDescription = 61
    var titleMessage :String = ""
    var message :String = ""
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if selectedUser == nil {
            selectedUser = UserManager().currentUser()
        }
        prepareTableView()
        prepareViews()
        plansButton.titleLabel?.text = NSLocalizedString("Plans", comment: "Plans")
        followButton.titleLabel?.text = NSLocalizedString("Following", comment: "Following")
        orgsButton.titleLabel?.text = NSLocalizedString("Orgs", comment: "Orgs")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        plansButton.selected = true
        followingButton.selected = false
        orgsButton.selected = false
        messageButton.enabled = true
        prepareData()
        self.tableView.reloadData()
        
        //self.profilePictureButton.enabled = (selectedUser!.isEqual(PFUser.currentUser()))
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    // MARK: - Helpers
    
    func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        
        let nibOrganizationCell = UINib(nibName: "OrganizationTableViewCell", bundle: nil)
        tableView.registerNib(nibOrganizationCell, forCellReuseIdentifier: "OrganizationTableViewCell")
        
        let nibActionCell = UINib(nibName: "ActionTableViewCell", bundle: nil)
        tableView.registerNib(nibActionCell, forCellReuseIdentifier: "ActionTableViewCell")
        
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
    }
    
    func prepareViews() {
        title = "" //selectedUser!["fullName"] as? String
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        navigationController?.navigationItem.title = ""
        plansButton.selected = true
        profilePictureButton.enabled = false
        
        
        let picture = selectedUser?["picture"] as? PFObject
        PictureManager().loadPicture(picture, inButton: profilePictureButton)
        
        if (selectedUser!["description"] == nil ) {
            if isMe(){
                self.userDescription.text = "Say something about yourself!"
            } else {
                self.userDescription.text = ""
            }
        } else {
            self.userDescription.text = selectedUser!["description"] as? String
        }
        self.userDescription.sizeToFit()
        self.userDescription.textAlignment = .Center
        navigationItem.title = selectedUser!["fullName"] as? String
        
        if isMe() {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ProfileViewController.editProfileTouched(_:)))
            navigationItem.rightBarButtonItem = editButton
            followButton.hidden = true
            messageButton.hidden = true
        } else {
            let rightButton = UIBarButtonItem(image: UIImage(named: "report_button"), style: .Plain, target: self, action: #selector(sendReport))
            rightButton.tintColor = titleColor
            navigationItem.rightBarButtonItem = rightButton
            let iconFollowButton = UserManager().alreadyFollowOnUser(selectedUser!) ? "unfollow_button_profile" : "follow_button_profile"
            followButton.setImage(UIImage(named: iconFollowButton), forState: .Normal)
        }
    }

    func prepareData() {
        do {try selectedUser?.fetchIfNeeded()}
        catch{}
        let privateUser = selectedUser!["isPrivate"] as! Bool
        UserManager().followingUser(UserManager().currentUser(), completion: {[weak self] (followings) in
            self?.followingUser = followings
            })

        if isMe() || !privateUser || followingUser.contains(selectedUser!) {
            showActivityIndicator()
            EventManager().eventPlansForUser(selectedUser!, isMe: isMe(), completion: {[weak self] (plan) in
                self?.hideActivityIndicator()
                self?.plans = plan
                self?.tableView.reloadData()
            })
            
            OrganizationManager().organizationForUser(selectedUser!, completion: {[weak self] (org) in
                self?.organizationArray = org
                self?.organizationArray.sortInPlace { (org1: PFObject, org2: PFObject) -> Bool in
                    let name1 = org1["name"] as? String
                    let name2 = org2["name"] as? String
                    return name1?.lowercaseString < name2?.lowercaseString
                }
                self?.tableView.reloadData()
            })
            
            UserManager().followingForUser(selectedUser!, completion: {[weak self] (followings) in
                self?.followingArray = followings
                self?.tableView.reloadData()
            })
        }
    }
    
    func isMe() -> Bool {
        return selectedUser?.objectId == UserManager().currentUser().objectId
    }
    
    func sendReport() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        let spamAction: UIAlertAction = UIAlertAction(title: "It’s Spam", style: .Default) { action -> Void in
            ReportManager().sendReportOnFollow(self.selectedUser!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                self!.showAlert("Success", message: "")
            })
        }
        actionSheetController.addAction(spamAction)
        let inappropriateAction: UIAlertAction = UIAlertAction(title: "It’s Inappropriate", style: .Default) { action -> Void in
            ReportManager().sendReportOnFollow(self.selectedUser!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                self!.showAlert("Success", message: "")
                })
        }
        actionSheetController.addAction(inappropriateAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    // MARK: - Internal operations
    
    func updateAvatar(withNewAvatarURL avatarURL: NSURL, storagePath: String, completion: ((updated: Bool, error: NSError?) -> Void)?) {
        let user = PFUser.currentUser()
        guard let userID = user?.objectId else {
            print("Unable to change avatar. User is not logged in")
            return
        }
        
        func changeImageURL(forPicture picture: PFObject) {
            picture["imageURL"] = avatarURL.absoluteString
            picture["storagePath"] = storagePath
            
            var objectsToSave: [PFObject] = [picture]
            user!["picture"] = picture
            objectsToSave.append(user!)
            
            PFObject.saveAllInBackground(objectsToSave) { (saved, error) in
                if let err = error {
                    completion?(updated: false, error: err)
                } else {
                    completion?(updated: saved, error: nil)
                }
            }
        }
        
        let profilePicQuery = PFQuery(className: "Pictures")
        profilePicQuery.whereKey("userId", equalTo: userID)
        profilePicQuery.getFirstObjectInBackgroundWithBlock { [weak self] (result, error) -> Void in
            var picture = result
            
            if picture != nil {
                if let imagePath = picture!["storagePath"] as? String {
                    self!.deleteImage(withStoragePath: imagePath, completion: nil)
                }
            } else {
                picture = PFObject(className: "Pictures")
                picture!["userId"] = userID
                picture!["user"] = user
            }
            
            changeImageURL(forPicture: picture!)
        }
    }
    
    func refreshAvatarImage(withImage image: UIImage) {
        showActivityIndicator()
        
        //gunna have to change this if orgs are not users
        
        let onAvatarUpdateFinished = { [weak self] (updated: Bool, error: NSError?) in
            self?.hideActivityIndicator()
            
            if let err = error {
                self?.titleMessage = NSLocalizedString("Error", comment: "Error")
                
                self?.showAlert(self!.titleMessage.localized(), message: err.localizedDescription)
                self?.hideActivityIndicator()
            } else {
                self?.profilePictureButton.setBackgroundImage(image, forState: .Normal)
            }
        }
        
        uploadImage(image) { [weak self] (imageURL, storagePath, error) in
            guard error == nil else {
                self?.titleMessage = NSLocalizedString("Error", comment: "Error")
                self?.message = NSLocalizedString("Failed to upload avatar", comment: "Failed to upload avatar")
                
                self?.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
                self?.hideActivityIndicator()
                
                return
            }
            
            guard let url = imageURL else {
                self?.titleMessage = NSLocalizedString("Error", comment: "Error")
                self?.message = NSLocalizedString("Image URL is lost", comment: "Image URL is lost")
                
                self?.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
                self?.hideActivityIndicator()
                
                return
            }
            
            self?.updateAvatar(withNewAvatarURL: url, storagePath: storagePath!, completion: onAvatarUpdateFinished)
        }
    }
    

    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let privateUser = selectedUser!["isPrivate"] as! Bool
        print((selectedUser!["isPrivate"] as! Bool) ? "private true" : "private false")
        if privateUser && !isMe() && !followingUser.contains(selectedUser!){
            return 1
        }
        
        if plansButton.selected {
            return plans.count
        } else if followingButton.selected {
            return followingArray.count < 1 && isMe() ? 1 : followingArray.count
        } else if orgsButton.selected {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let privateUser = selectedUser!["isPrivate"] as! Bool
        if privateUser && !isMe() && !followingUser.contains(selectedUser!) {
            return 0
        }
        if plansButton.selected {
            let sectionData = plans[section]
            let events = sectionData["events"] as! [PFObject]
            return events.count
        } else if followingButton.selected {
            if followingArray.count < 1 {
                return isMe() ? 1 : 0
            } else {
                let sectionItem = followingArray[section]
                
                if let following = sectionItem["items"] as? [PFObject] {
                    return following.count + (isMe() && section == 0 ? 1 : 0)
                }
                return 0
            }
        } else if orgsButton.selected {
            if organizationArray.count < 1 {
                return isMe() ? 1 : 0
            }
            else{
                return organizationArray.count + (isMe() ? 1 : 0)
            }
        }

        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if plansButton.selected {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
            let sectionData = plans[indexPath.section]
            let events = sectionData["events"] as! [PFObject]
            let event = events[indexPath.row]
            
            cell.eventNameLabel.text = event["name"] as? String
            
            if let organization = event["organization"] as? PFObject {
                if organization.dataAvailable {
                    cell.eventOrganizationNameLabel.text =  organization["name"] as? String
                }
            }
            
            cell.eventDescriptionLabel.text = event["description"] as? String
            
            let picture = event["picture"] as? PFObject
            PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
            cell.eventPictureImageView.cornerRadius = cell.eventPictureImageView.frame.width / 2
            var dateFormat = "dd MMM h:mm a"
            
            switch sectionData["title"] as! String {
            case TypeEventsSection.Today.rawValue:
                dateFormat = "h:mm a"
            case TypeEventsSection.ThisWeek.rawValue:
                dateFormat = "EEEE"
            default:
                dateFormat = "dd MMM"
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = dateFormat
            cell.eventDateLabel.text = dateFormatter.stringFromDate(event["startDate"] as! NSDate)
            
            return cell
        } else if followingButton.selected {
            if indexPath.row == 0 && indexPath.section == 0 && isMe() {
                let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                cell.titleLabel.text = NSLocalizedString("Find people and organizations!", comment: "Find people and organizations!")
                
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
            let sectionItem = followingArray[indexPath.section]
            let sectionTitle = sectionItem["title"] as! String
            
            if let following = sectionItem["items"] as? [PFObject] {
                let item = isMe() && indexPath.section == 0 ? following[indexPath.row - 1] : following[indexPath.row]
                
                if (sectionTitle == TypeFollowingSection.Friends.rawValue){
                    cell.titleLabel.text = item["fullName"] as? String
                } else {
                    cell.titleLabel.text = item["name"] as? String
                }
                
                cell.descriptionLabel.text = ""
                if let picture = item["picture"] as? PFObject {
                    PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
                } else {
                    cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
                }

            }
            
            return cell
        } else if orgsButton.selected {
            //if indexPath.row == organizationArray.count
            if indexPath.row == 0 && isMe()
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                cell.titleLabel.text = NSLocalizedString("Create Organization", comment: "Create Organization")
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("OrganizationTableViewCell") as! OrganizationTableViewCell
            let organization = isMe() ? organizationArray[indexPath.row - 1] : organizationArray[indexPath.row]
            cell.nameOrganizationLabel.text = organization["name"] as? String
            cell.roleInOrganizationLabel.text = OrganizationManager().roleInOrganization(selectedUser!, organization: organization).rawValue
            if let picture = organization["picture"] as? PFObject {
                PictureManager().loadPicture(picture, inImageView: cell.organizationPictureImageView)
            } else {
                cell.organizationPictureImageView.image = UIImage(named: "user_dafault_picture")
            }

            cell.organizationPictureImageView.cornerRadius = cell.organizationPictureImageView.frame.width / 2
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if followingButton.selected && followingArray.count > 0 {
            self.titleMessage = NSLocalizedString("Unfollow", comment: "Unfollow")
            let unfollowButton = UITableViewRowAction(style: .Normal, title: self.titleMessage) {[weak self] action, indexPaxth in
                self?.unfollow(indexPath)
            }
            unfollowButton.backgroundColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
            return [unfollowButton]
        }
        return [UITableViewRowAction]()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= lengthEventDescription
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.row != 0 || indexPath.section != 0) && isMe()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let privateUser = selectedUser!["isPrivate"] as! Bool
        if privateUser && !isMe()  && !followingUser.contains(selectedUser!) {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
            let myString = "This Account is Private."
            let myAttribute = [ NSFontAttributeName : UIFont.boldSystemFontOfSize(25) ]
            let myStr = NSMutableAttributedString(string: myString, attributes: myAttribute)
            let myAttrString1 = NSAttributedString(string: "\n Follow the user to see their Plans, Events and Organizations")
            myStr.appendAttributedString(myAttrString1)
            header.titleHeader.attributedText = myStr
            header.titleHeader.numberOfLines = 3
            return header
        }
        
        if orgsButton.selected || followingButton.selected && isMe() && followingArray.count < 1 {
            return UIView()
        }
        
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
        let sectionData = plansButton.selected ? plans[section] : followingArray[section]
        header.titleHeader.text = sectionData["title"] as? String
        return header
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let privateUser = selectedUser!["isPrivate"] as! Bool
        if privateUser && !isMe() && !followingUser.contains(selectedUser!) {
            return 0
        }
        if followingButton.selected {
            return 9
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let privateUser = selectedUser!["isPrivate"] as! Bool
        if privateUser && !isMe() && !followingUser.contains(selectedUser!)  {
            return 100
        }
        if orgsButton.selected || followingButton.selected && isMe() && followingArray.count < 1 {
            return 0
        }
        return 32
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EventTableViewCell.kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if plansButton.selected {
            let sectionData = plans[indexPath.section]
            let events = sectionData["events"] as! [PFObject]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
            
        } else if orgsButton.selected {
            if indexPath.row == 0 && isMe() {
                let newOrganization = PFObject(className: "Organizations")
                newOrganization["leaderId"] = PFUser.currentUser()?.objectId!
                newOrganization["city"] = "Organization city"
                newOrganization["name"] = "Organization name"
                newOrganization["info"] = ""
                newOrganization["state"] = "Organization state"
                newOrganization["address"] = "Organization address"
                newOrganization["events"] = []
                newOrganization["admins"] = []
                newOrganization["members"] = []
                self.showOrganizationProfileViewController(newOrganization, isNewOrg: true)
                return
            }
            let index = isMe() ? indexPath.row - 1 : indexPath.row
            let organization = organizationArray[index]
            showOrganizationProfileViewController(organization, isNewOrg: false)
            
        } else if followingButton.selected {
            if indexPath.row == 0 && indexPath.section == 0 && isMe() {
                self.showSearchVIewController()
//                    tabBarController?.selectedIndex = 4
                return
            }
            let sectionItem = followingArray[indexPath.section]
            let sectionTitle = sectionItem["title"] as! String
            
            if let following = sectionItem["items"] as? [PFObject] {
                var isMyProfile = (isMe() ? 0 : 1)
                if indexPath.section == 0 {
                    isMyProfile = (isMe() ? 1 : 0)
                }
                if sectionTitle == TypeFollowingSection.Friends.rawValue {
                    let item = following[indexPath.row]
                    showProfileViewController(item as! PFUser)
                } else {
                    let item = following[indexPath.row - isMyProfile]
                    showOrganizationProfileViewController(item, isNewOrg: false)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Actions
    
    func unfollow(indexPath: NSIndexPath) {
        var sectionItem = followingArray[indexPath.section]
        let sectionTitle = sectionItem["title"] as! String
        let currentUser = UserManager().currentUser()
        
        if var following = sectionItem["items"] as? [PFObject] {
            if sectionTitle == TypeFollowingSection.Friends.rawValue {
                let item = following[indexPath.row]
                
                UserManager().unfollow(selectedUser!, object: item) {[weak self] (success) in
                    if let sself = self {
                        if success {
                            following.removeAtIndex(indexPath.row)
                            sectionItem["items"] = following
                            sself.followingArray[indexPath.section] = sectionItem
                            sself.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                        } else {
                            sself.tableView.reloadData()
                            sself.showAlert("Error", message: "Please try again later")
                        }
                    }
                }
            } else {
                let item = following[indexPath.row - 1]
                OrganizationManager().unfollowingUserOnOrganization(item, user: currentUser, completion: { [weak self] (success) -> Void in
                    if let sself = self {
                        if success {
                            following.removeAtIndex(indexPath.row - 1)
                            sectionItem["items"] = following
                            sself.followingArray[indexPath.section] = sectionItem
                            sself.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                        } else {
                            sself.tableView.reloadData()
                            sself.showAlert("Error", message: "Please try again later")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func changeProfileSectionTouched(sender: UIButton) {
        plansButton.selected = false
        followingButton.selected = false
        orgsButton.selected = false
        sender.selected = true
        tableView.contentOffset = CGPointMake(0, 0)
        tableView.reloadData()
    }
    
    @IBAction func onChangeProfilePictureTouchUp(sender: AnyObject) {
        if selectedUser!.isEqual(PFUser.currentUser()) {
            pickImage()
        }
    }
    
    func editProfileTouched(sender: AnyObject) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneProfileTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton

        profilePictureButton.enabled = true
        titleMessage = NSLocalizedString("Description", comment: "Description")
        message = NSLocalizedString("Please, enter profile description", comment: "Please, enter profile desription")
        let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.addTarget(self, action: nil, forControlEvents: .ValueChanged) //EditingChanged
            textField.placeholder = NSLocalizedString("Description", comment: "Description")
            textField.delegate = self
        }
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in }
        titleMessage = NSLocalizedString("OK", comment: "OK")
        let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
            self!.userDescription.text = alertController.textFields?.first?.text!
            self!.selectedUser!["description"] = alertController.textFields?.first?.text!
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func doneProfileTouched(sender: AnyObject) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton

        profilePictureButton.enabled = false
        self.selectedUser!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            self.message = NSLocalizedString("", comment: "")
            self.titleMessage = NSLocalizedString("The information was successfully changed.", comment: "The information was successfully changed.")
            self.showAlert((self.titleMessage), message: (self.message))
        }
    }
    
    @IBAction func followTouched(sender: AnyObject) {
        if UserManager().alreadyFollowOnUser(selectedUser!) {
            UserManager().unfollow(UserManager().currentUser(), object: selectedUser!, completion: {[weak self] (success) in
                if success {
                    self?.followButton.setImage(UIImage(named: "follow_button_profile"), forState: .Normal)
                }
            })
        } else {
            showActivityIndicator()
            UserManager().followingOnUser(selectedUser!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
            })
            self.followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)

        }
    }
    
    @IBAction func messageTouched(sender: AnyObject) {
        messageButton.enabled = false
        addChatWithUser(selectedUser!)
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfileFriends" {
            let destinationViewController = segue.destinationViewController as! ProfileFriendsViewController
            destinationViewController.selectedUser = selectedUser
        }
        else if (segue.identifier == "startChatWithUser"){
            let user = sender as! PFUser
            let destinationViewController = segue.destinationViewController as! ChatViewController
            destinationViewController.user = user //PFUser.currentUser()
            destinationViewController.chatRoomId = self.createdRoomID!
            destinationViewController.title = user["fullName"] as? String
        }
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
    
    // ORCropImageControllerDelegate
    
    override func cropVCDidFinishCrop(withImage image: UIImage?) {
        guard let img = image else {
            self.titleMessage = NSLocalizedString("Fail", comment: "Fail")
            self.message = NSLocalizedString("Failed to crop image!", comment: "Failed to crop image!")
            showAlert(self.titleMessage, message: self.message)
            return
        }
        
        refreshAvatarImage(withImage: img)
    }
    
}
