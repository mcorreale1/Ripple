//
//  ProfileViewController.swift
//  Ripple
//
//  Created by evgeny on 11.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import SDWebImage

protocol ProfileViewControllerDelegate {
    func followCompletedOnUser(user: Users?)
}

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
    var organizationArray = [Organizations]()
    var followingArray = [Dictionary<String, AnyObject>]()
    var followingUsers = [Users]()
    
    var selectedUser: Users?
    
    var  delegate: ProfileViewControllerDelegate?
    
    
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
        
        plansButton.selected = true
        followingButton.selected = false
        orgsButton.selected = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        messageButton.enabled = true
        prepareData()
        tableView.reloadData()
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
        title = ""
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        navigationController?.navigationItem.title = ""
        plansButton.selected = true
        profilePictureButton.enabled = false
        
        PictureManager().loadPicture(selectedUser?.picture, inButton: profilePictureButton)
        
        if selectedUser!.descr == nil {
            if self.isMe(){
                self.userDescription.text = "Say something about yourself!"
            } else {
                self.userDescription.text = ""
            }
        } else {
            self.userDescription.text = selectedUser!.descr
        }
        self.userDescription.sizeToFit()
        self.userDescription.textAlignment = .Center
        navigationItem.title = selectedUser!.fullName
        
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
        UserManager().followingUsers(UserManager().currentUser(), completion: { (followings) in
            self.followingUsers = followings
            
            if self.isMe() || !self.selectedUser!.isPrivate || self.followingUsers.contains(self.selectedUser!) {
                EventManager().eventPlansForUser(self.selectedUser!, isMe: self.isMe(), completion: {[weak self] (plan) in
                    self?.plans = plan
                    self?.tableView.reloadData()
                })
                
                OrganizationManager().organizationForUser(self.selectedUser!, completion: {[weak self] (org) in
                    self?.organizationArray = org
                    self?.organizationArray.sortInPlace { (org1: Organizations, org2: Organizations) -> Bool in
                        let name1 = org1.name
                        let name2 = org2.name
                        return name1?.lowercaseString < name2?.lowercaseString
                    }
                    self?.tableView.reloadData()
                })
                
                UserManager().followingForUser(self.selectedUser!, completion: {[weak self] (followings) in
                    self?.hideActivityIndicator()
                    self?.followingArray = followings
                    self?.tableView.reloadData()
                })
            }
        })
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
    
    private func countFollowings(type: TypeFollowingSection) -> Int {
        for sectionItem in followingArray {
            let sectionTitle = sectionItem["title"] as! String
            let following = sectionItem["items"] as? [AnyObject]
            
            if sectionTitle == type.rawValue {
                return following?.count ?? 0
            }
        }
        return 0
    }
    
    // MARK: - Internal operations
    
    func updateAvatar(withNewAvatarURL avatarURL: String, storagePath: String, completion: ((Bool, NSError?) -> Void)?) {
        let user = UserManager().currentUser()
        guard let userID = user.objectId else {
            print("Unable to change avatar. User is not logged in")
            return
        }
        
        func changeImageURL(forPicture picture: Pictures) {
            picture.imageURL = avatarURL
            picture.storagePath = storagePath
            
            picture.save { (savedPic, error) in
                if error == nil {
                    user.picture = savedPic as? Pictures
                    user.save({ (success, error) in
                        if error == nil {
                            completion?(success, nil)
                        } else {
                            completion?(false, error)
                        }
                    })
                } else {
                    completion?(false, error)
                }
            }
        }
        
        var picture = user.picture
        
        if picture !== nil {
            picture = Pictures()
            picture?.userId = userID
            picture?.user = user
        }
        
        changeImageURL(forPicture: picture!)
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
        
        PictureManager().uploadImage(image) { [weak self] (imageURL, storagePath, error) in
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
        let privateUser = selectedUser!.isPrivate
        if privateUser && !isMe() && !followingUsers.contains(selectedUser!){
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
        let privateUser = selectedUser!.isPrivate
        if privateUser && !isMe() && !followingUsers.contains(selectedUser!) {
            return 0
        }
        if plansButton.selected {
            let sectionData = plans[section]
            let events = sectionData["events"] as! [RippleEvent]
            return events.count
        } else if followingButton.selected {
            if followingArray.count < 1 {
                return isMe() ? 1 : 0
            } else {
                let sectionItem = followingArray[section]
                
                if let following = sectionItem["items"] as? [AnyObject] {
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
            let events = sectionData["events"] as! [RippleEvent]
            let event = events[indexPath.row]
            
            cell.eventNameLabel.text = event.name
            
            if let organization = event.organization {
                cell.eventOrganizationNameLabel.text =  organization.name
            }
            
            cell.eventDescriptionLabel.text = event.descr
            
            let picture = event.picture
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
            cell.eventDateLabel.text = dateFormatter.stringFromDate(event.startDate!)
            
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
            
            if let following = sectionItem["items"] as? [AnyObject] {
                let item = isMe() && indexPath.section == 0 ? following[indexPath.row - 1] : following[indexPath.row]
                
                if sectionTitle == TypeFollowingSection.Friends.rawValue {
                    cell.titleLabel.text = item.fullName
                } else {
                    cell.titleLabel.text = item.name
                }
                
                cell.descriptionLabel.text = ""
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")

                if item.picture! != nil {
                    PictureManager().loadPicture(item.picture!, inImageView: cell.pictureImageView)
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
            cell.nameOrganizationLabel.text = organization.name
            cell.roleInOrganizationLabel.text = OrganizationManager().roleInOrganization(selectedUser!, organization: organization).rawValue
            if let picture = organization.picture {
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
        let privateUser = selectedUser!.isPrivate
        if privateUser && !isMe()  && !followingUsers.contains(selectedUser!) {
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
        let privateUser = selectedUser!.isPrivate
        if privateUser && !isMe() && !followingUsers.contains(selectedUser!) {
            return 0
        }
        if followingButton.selected {
            return 9
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let privateUser = selectedUser!.isPrivate
        if privateUser && !isMe() && !followingUsers.contains(selectedUser!)  {
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
            let events = sectionData["events"] as! [RippleEvent]
            let event = events[indexPath.row]
            showEventDescriptionViewController(event)
            
        } else if orgsButton.selected {
            if indexPath.row == 0 && isMe() {
                showOrganizationProfileViewController(nil, isNewOrg: true, fromInvite: false)
                return
            }
            let index = isMe() ? indexPath.row - 1 : indexPath.row
            let organization = organizationArray[index]
            showOrganizationProfileViewController(organization, isNewOrg: false, fromInvite: false)
            
        } else if followingButton.selected {
            if indexPath.row == 0 && indexPath.section == 0 && isMe() {
                self.showSearchVIewController()
                return
            }
            let sectionItem = followingArray[indexPath.section]
            let sectionTitle = sectionItem["title"] as! String
            
            if let following = sectionItem["items"] as? [AnyObject] {
                let isMyProfile = (isMe() ? 1 : 0)
                
                if sectionTitle == TypeFollowingSection.Friends.rawValue {
                    let countSections = tableView.numberOfSections
                    let deltaIndex = countSections < 2 ? isMyProfile : 0
                    let item = following[indexPath.row - deltaIndex]
                    showProfileViewController(item as! Users)
                } else {
                    let deltaIndex = countFollowings(.Friends) > 0 ? isMyProfile : 1
                    let item = following[indexPath.row - deltaIndex]
                    showOrganizationProfileViewController(item as? Organizations, isNewOrg: false, fromInvite: false)
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
        let isMyProfile = (isMe() ? 1 : 0)
        
        if var following = sectionItem["items"] as? [AnyObject] {
            if sectionTitle == TypeFollowingSection.Friends.rawValue {
                let countSections = tableView.numberOfSections
                let deltaIndex = countSections < 2 ? isMyProfile : 0
                let item = following[indexPath.row - deltaIndex]
                UserManager().unfollow(item as! Users) {[weak self] (success) in
                    if success {
                        following.removeAtIndex(indexPath.row - deltaIndex)
                        sectionItem["items"] = following
                        self?.followingArray[indexPath.section] = sectionItem
                        self?.tableView.reloadData()
                        //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    } else {
                        self?.tableView.reloadData()
                        self?.showAlert("Error", message: "Server don't response. Please try again later")
                    }
                }
            } else {
                let deltaIndex = countFollowings(.Friends) > 0 ? isMyProfile : 1
                let item = following[indexPath.row - deltaIndex]
                
                OrganizationManager().unfollowingUserOnOrganization(item as! Organizations, user: currentUser, completion: {[weak self] (entity, error) in
                    if entity != nil {
                        UserManager().unfollowOnOrganization(entity!, withCompletion: {[weak self] (success) in
                            if success {
                                following.removeAtIndex(indexPath.row - deltaIndex)
                                sectionItem["items"] = following
                                self?.followingArray[indexPath.section] = sectionItem
                                self?.tableView.reloadData()
                            } else {
                                self?.showAlert("Error", message: "Server don't response. Please try again later")
                            }
                        })
                        
                        //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    } else {
                        self?.tableView.reloadData()
                        self?.showAlert("Error", message: "Server don't response. Please try again later")
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
        if selectedUser!.isEqual(UserManager().currentUser()) {
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
            self!.selectedUser!.descr = alertController.textFields?.first?.text!
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func doneProfileTouched(sender: AnyObject) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton

        profilePictureButton.enabled = false
        self.selectedUser!.save({ (success, error) in
            self.message = NSLocalizedString("", comment: "")
            self.titleMessage = NSLocalizedString("The information was successfully changed.", comment: "The information was successfully changed.")
            self.showAlert((self.titleMessage), message: (self.message))
        })
    }
    
    @IBAction func followTouched(sender: AnyObject) {
        showActivityIndicator()
        
        if UserManager().alreadyFollowOnUser(selectedUser!) {
            UserManager().unfollow(selectedUser!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                
                if success {
                    self?.showAlert("", message: "The profile has been removed from Following.")
                    self?.followButton.setImage(UIImage(named: "follow_button_profile"), forState: .Normal)
                }
            })
        } else {
            UserManager().followingOnUser(selectedUser!, completion: {[weak self] (success) in
                self?.delegate?.followCompletedOnUser(self?.selectedUser)
                self?.hideActivityIndicator()
                
                if success {
                    self?.showAlert("", message: "The profile has been added.")
                }
                self?.followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)
            })
        }
    }
    
    @IBAction func messageTouched(sender: AnyObject) {
        //self.performSegueWithIdentifier("ShowSettings", sender: self)
        //destinationVC.user = sender as? PFUser
        //destinationVC.chatRoomId = self.createdRoomID!
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
            let user = sender as! Users
            let destinationViewController = segue.destinationViewController as! ChatViewController
            destinationViewController.user = user 
            destinationViewController.title = user.fullName
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
