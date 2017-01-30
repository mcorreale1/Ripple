//
//  OrganizationProfile1.swift
//  Ripple
//
//  Created by Adam Gluck on 2/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import ORCommonCode_Swift
import ORCommonUI_Swift

extension UIImage {
    var uncompressedPNGData: NSData     { return UIImagePNGRepresentation(self)!        }
    var smallestJPEG:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}


class OrganizationProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var organizationDescriptionTextView: UITextView!
    @IBOutlet weak var membersDescriptionTextView: UITextView!
    
    @IBOutlet weak var profilePictureButton: ProfilePictureButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    //@IBOutlet weak var bottonLCDescrTextView: NSLayoutConstraint!
    
    var fromInviteScreen = false
    var editOrganization = false
    var isEventCreate = false
    
    var organization: Organizations?
    var orgName = ""
    var orgPicture: UIImage?
    var orgDescription = ""
    
    var orgEvents = [RippleEvent]()
    var orgMembers = [Users]()
    
    var titleMessage :String = ""
    var message :String = ""
    
    let titleColor = UIColor.init(red: 0/255, green:0/255, blue: 0/255, alpha: 1)
    var alertController = UIAlertController()
    let maxLengthOrgDescription = 250
    let maxLengthOrgName = 30
    
    deinit {
        or_removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        or_addObserver(self, selector: #selector(onEventIsCreate), name: PulseNotification.PulseNotificationIsEventCreate.rawValue)
        prepareTableView()
        
        prepareNavigationBar()
        
        if (editOrganization) {
            showAlertEnterOrganizationName()
            prepareViews()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!editOrganization) {
            prepareData()
            prepareViews()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrganizationProfileViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrganizationProfileViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isEventCreate {
            isEventCreate = false
            EventManager().eventOrganization(organization!) {[weak self] (events) in
                self?.orgEvents = events
                self?.orgEvents.sortInPlace { (event1: RippleEvent, event2: RippleEvent) -> Bool in
                    let date1 = event1.startDate
                    let date2 = event2.startDate
                    return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
                }
                
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Helpers
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.barTintColor = .whiteColor()
        
        if editOrganization {
            let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.saveTouched(_:)))
            navigationItem.rightBarButtonItem = rightButton
        } else if isLeader() || isAdmin() {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editProfileTouched(_:)))
            navigationItem.rightBarButtonItem = editButton
        } else {
            let rightButton = UIBarButtonItem(image: UIImage(named: "report_button"), style: .Plain, target: self, action: #selector(sendReport))
            rightButton.tintColor = titleColor
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    private func showAlertEnterOrganizationName() {
        let title = NSLocalizedString("Organization Name", comment: "Organization Name")
        let message = NSLocalizedString("Please, enter organization name", comment: "Please, enter organization name")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Organization Name", comment: "Organization Name")
            textField.returnKeyType = .Done
            textField.text = self.orgName
            textField.delegate = self
            
            
        }
        
        let cancelText = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: cancelText, style: .Cancel) {[weak self] (result : UIAlertAction) -> Void in
            self?.navigationController?.popViewControllerAnimated(true)
        }
        
        let okText = NSLocalizedString("OK", comment: "OK")
        let okAction = UIAlertAction(title: okText, style: .Default, handler: {[weak self] (result :UIAlertAction) -> Void in
            if self?.orgName == "" {
                self?.showAlertEnterOrganizationName()
            }
        });
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    private func needHideFollowButton() -> Bool {
        return editOrganization || isLeader() || isAdmin() || fromInviteScreen
    }
    
    private func prepareData() {
        guard let org = organization else {
            return
        }
        
        orgName = organization?.name ?? ""
        orgDescription = organization?.info ?? ""
        
        if let picture = org.picture {
            PictureManager().downloadImage(fromURL: picture.imageURL!, completion: {[weak self] (image, error) in
                self?.orgPicture = image
            })
        }
        
        EventManager().eventOrganization(org) {[weak self] (events) in
            self?.orgEvents = events
            self?.orgEvents.sortInPlace { (event1: RippleEvent, event2: RippleEvent) -> Bool in
                let date1 = event1.startDate
                let date2 = event2.startDate
                return date1?.timeIntervalSince1970 < date2?.timeIntervalSince1970
            }
            
            OrganizationManager().membersInOrganizations(org) { [weak self] (result) in
                if result != nil {
                    self?.orgMembers = result!
                    self?.orgMembers.sortInPlace { (user1: Users, user2: Users) -> Bool in
                        let name1 = user1.name
                        let name2 = user2.name
                        return name1?.lowercaseString < name2?.lowercaseString
                    }
                    self?.memberCountLabel.text = String(result!.count) + " " + NSLocalizedString("Members", comment: "Members")
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    private func prepareViews() {        
        eventsButton.titleLabel?.text = NSLocalizedString("Events", comment: "Events")
        membersButton.titleLabel?.text = NSLocalizedString("Members", comment: "Members")
        aboutButton.titleLabel?.text = NSLocalizedString("About", comment: "About")
        aboutButton.selected = true
        tableView.backgroundColor = UIColor.whiteColor()
        followButton.hidden = needHideFollowButton()
        memberCountLabel.text = ""
        title = orgName
        
        membersDescriptionTextView.hidden = true
        
        organizationDescriptionTextView.placeholder = orgDescription == "" ? "What are the details of your organization?" : ""
        organizationDescriptionTextView.text = orgDescription
        organizationDescriptionTextView.hidden = false
        organizationDescriptionTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        
        organizationDescriptionTextView.editable = editOrganization
        profilePictureButton.enabled = editOrganization
        PictureManager().loadPicture(organization?.picture, inButton: profilePictureButton)
        
        if (!followButton.hidden && (isFollowing() || isMember() || isAdmin())) {
            followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)
        }
        
    }
    
    private func prepareTableView() {
        let nibEventCell = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.registerNib(nibEventCell, forCellReuseIdentifier: "EventCell")
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        
        let nibActionCell = UINib(nibName: "ActionTableViewCell", bundle: nil)
        tableView.registerNib(nibActionCell, forCellReuseIdentifier: "ActionTableViewCell")
    }
    
    private func prepareHiddenViews(isAbout: Bool) {
        eventsButton.selected = false
        membersButton.selected = false
        aboutButton.selected = isAbout
        tableView.hidden = isAbout
        organizationDescriptionTextView.hidden = !isAbout
    }
    
    private func uploadOnServer(image image: UIImage, block: ((String, String) -> Void)) {
        PictureManager().uploadImage(image) { [weak self] (imageURL, storagePath, error) in
            self?.hideActivityIndicator()
            
            guard error == nil else {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                let message = NSLocalizedString("Failed to upload avatar", comment: "Failed to upload avatar")
                self?.showAlert(NSLocalizedString("Error", comment: "Error"), message:message + ". Please try again later")
                return
            }
            
            guard let url = imageURL else {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                let message = NSLocalizedString("Image URL is lost", comment: "Image URL is lost")
                self?.showAlert(NSLocalizedString("Error", comment: "Error"), message: message)
                return
            }
            
            block(url, storagePath!)
        }
    }
    
    private func savePicture(block: ((Bool, NSError?) -> Void)) {
        uploadOnServer(image: orgPicture!) {[weak self] (url, storagePath) in
            guard let sself = self else {
                return
            }
            
            func changeImageURL(forPicture picture: Pictures?) {
                guard let sPicture = picture else {
                    return
                }
                
                sPicture.imageURL = url
                sPicture.storagePath = storagePath
                
                sPicture.save { (savedPic, error) in
                    if error == nil {
                        self?.organization?.picture = savedPic as? Pictures
                        self?.organization?.save({ (savedOrg, error) in
                            self?.organization = savedOrg as? Organizations
                            if error == nil && savedOrg != nil {
                                block(true, nil)
                            } else {
                                block(false, error)
                            }
                        })
                    } else {
                        block(false, error)
                    }
                }
            }
            
            var picture = self?.organization?.picture
            
            if picture == nil {
                picture = Pictures()
                picture?.userId = self?.organization?.objectId
                picture?.owner = self?.organization
            }
            changeImageURL(forPicture: picture)
        }
    }
    
    func saveOrganizationSuccess() {
        editOrganization = false
        prepareViews()
        prepareNavigationBar()
        prepareData()
    }
    
    func checkFieldsAndShowAlertIfNeeded() -> Bool {
        if orgName == "" {
            showAlert("Error", message: NSLocalizedString("The organization was not created. Please, enter organization name.", comment: ""))
            return false
        }
        
        if orgDescription == ""  {
            showAlert("Error", message: NSLocalizedString("The organization was not created. Please, enter organization description.", comment: ""))
            return false
        }
        
        if orgPicture == nil {
            showAlert("Error", message: NSLocalizedString("The organization was not created. Please, upload profile images and press Done.", comment: ""))
            return false
        }
        
        return true
    }
    
    private func isLeader(user: Users = UserManager().currentUser()) -> Bool {
        return OrganizationManager().roleInOrganization(user, organization: organization!) == .Founder
    }
    
    private func isAdmin(user: Users = UserManager().currentUser()) -> Bool {
        return OrganizationManager().roleInOrganization(user, organization: organization!) == .Admin
    }
    
    private func isMember(user: Users = UserManager().currentUser()) -> Bool {
        return OrganizationManager().roleInOrganization(user, organization: organization!) == .Member
    }
    
    private func isFollowing(user: Users = UserManager().currentUser()) -> Bool {
        return OrganizationManager().roleInOrganization(user, organization: organization!) == .Follower
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.view.frame.origin.y = -80
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let sumLength = text.characters.count + textView.text.characters.count
        return sumLength < maxLengthOrgDescription || text.characters.count < 1
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        orgDescription = textView.text
    }
    
    func textViewDidChange(textView: UITextView) {
        orgDescription = textView.text
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxLengthOrgName
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        orgName = textField.text ?? ""
        title = orgName
        
    }
    
    // MARK: - Actions
    
    @IBAction func switchSectionTouched(sender: UIButton) {
        self.view.endEditing(true)
        
        if editOrganization {
            showAlert("Error", message: "Please, save your created organization ")
            return
        }
        
        prepareHiddenViews(false)
        sender.selected = true
        tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        if tableView.cellForRowAtIndexPath(indexPath) != nil {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    @IBAction func showAboutTouched(sender: UIButton) {
        prepareHiddenViews(true)
        organizationDescriptionTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    @IBAction func onChangeProfilePicturetouchUp(sender: AnyObject) {
        view.endEditing(true)
        message = NSLocalizedString("Select image source", comment: "Select image source")
        let actionSheetOptions = UIAlertController(title: nil, message: message.localized(), preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            titleMessage = NSLocalizedString("Camera", comment: "Camera")
            actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
                self?.showImagePicker(withSourceType: .Camera)
            })
        }
        
        titleMessage = NSLocalizedString("Album", comment: "Album")
        actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
            self?.showImagePicker(withSourceType: .SavedPhotosAlbum)
        })
        
        titleMessage = NSLocalizedString("Library", comment: "Library")
        actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
            self?.showImagePicker(withSourceType: .PhotoLibrary)
        })
        
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        actionSheetOptions.addCancelAction(withTitle: titleMessage)
        presentViewController(actionSheetOptions, animated: true, completion: nil)
    }
    
    func saveTouched(sender: AnyObject) {
        if (!checkFieldsAndShowAlertIfNeeded()) {
            return
        }
        
        showActivityIndicator()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        view.endEditing(true)
        view.frame.origin.y = 0
        
        if editOrganization && organization == nil {
            organization = Organizations()
            organization?.events = [RippleEvent]()
            organization?.members = "[ \"" + UserManager().currentUser().objectId + "\"]"
            organization?.admins = "[\"\"]"
            organization?.leaderId = UserManager().currentUser().objectId
        }
        
        organization?.name = orgName
        organization?.info = orgDescription
        
        organization?.save({[weak self] (entity, error) in
            if error == nil {
                self?.organization = entity as? Organizations
                print("saving picture")
                self?.savePicture({ (success, error) in
                    print("picture saved")
                    self?.hideActivityIndicator()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error != nil {
                        self?.showAlert("Error", message: error!.localizedDescription)
                    } else {
                        self?.saveOrganizationSuccess()
                    }
                })
            } else {
                self?.showAlert("Error", message: error!.localizedDescription)
            }
        })
    }
    
    func editProfileTouched(sender: AnyObject) {
        editOrganization = true
        prepareViews()
        prepareNavigationBar()
        showAlertEnterOrganizationName()
    }
    
    @IBAction func followToOrganizationTouched(sender: AnyObject) {
        showActivityIndicator()
        
        if OrganizationManager().roleInOrganization(UserManager().currentUser(), organization: self.organization!) == .Member {
            OrganizationManager().unfollowingUserOnOrganization(self.organization!, user: UserManager().currentUser(), completion: {[weak self] (entity, error) in
                self?.hideActivityIndicator()
                
                if entity != nil {
                    self?.followButton.setImage(UIImage(named: "follow_button_profile"), forState: .Normal)
                }
            })
        } else {
            InvitationManager().isCurrentUserInvitedToOrganization(organization!, completion: {[weak self] (invited) in
                self?.hideActivityIndicator()
                
                if self == nil {
                    return
                }
                
                if invited {
                    OrganizationManager().joinOrganization(self!.organization!, completion: { (success) in
                        if success {
                            self?.showAlert("", message: "The organization has been added.")
                            self?.followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)
                        }
                    })
                } else {
                    let currentUserOrgs = UserManager().currentUser().organizations
                    var userFollowingOrg = false
                    for org in currentUserOrgs {
                        if org.objectId == self!.organization!.objectId {
                            userFollowingOrg = true
                            break
                        }
                    }
                    
                    if userFollowingOrg {
                        UserManager().unfollowOnOrganization(self!.organization!, withCompletion: {[weak self] (success) in
                            if success {
                                self?.showAlert("", message: "The organization has been removed from Following.")
                                self?.followButton.setImage(UIImage(named: "follow_button_profile"), forState: .Normal)
                            }
                        })
                    } else {
                        UserManager().followOnOrganization(self!.organization!, completion: {[weak self] (success) in
                            if success {
                                self!.showAlert("", message: "The organization has been added to Following.")
                                self?.followButton.setImage(UIImage(named: "unfollow_button_profile"), forState: .Normal)
                            }
                        })
                    }
                }
            })
        }
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
        
        presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    // MARK: - ImagePickerDelegate
    
    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { [weak self] in
            let mediaItem = info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]
            
            guard let image: UIImage = mediaItem as? UIImage else {
                self?.showAlert(NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Image is lost", comment: "Image is lost"))
                return;
            }
            self?.showImageEditScreen(withImage: image, frameType: .Circle, maxSize: CGSize(width: 320.0, height: 320.0))
        }
    }
    
    
    // MARK: - ORCropImageViewControllerDelegate
    
    override func cropVCDidFinishCrop(withImage image: UIImage?) {
        guard let img = image else {
            self.titleMessage = NSLocalizedString("Fail", comment: "Fail")
            self.message = NSLocalizedString("Failed to crop image!", comment: "Failed to crop image!")
            showAlert(self.titleMessage, message: self.message)
            return
        }
        
         let smallerImage = image!.smallestJPEG
        let tinyImage : UIImage = UIImage(data: smallerImage)!
            orgPicture = tinyImage
            profilePictureButton.setBackgroundImage(orgPicture, forState: .Normal)
        
    }
    
    //MARK: - Notifications
    
    func onEventIsCreate() {
        isEventCreate = true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let heighTabBar = tabBarController != nil ? tabBarController!.tabBar.height : 0
        
        guard let userInfo = sender.userInfo, let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        let frame = frameValue.CGRectValue()
        
        //Here
        //bottonLCDescrTextView.constant = frame.size.height - heighTabBar - 80
        
        UIView.animateWithDuration(NSTimeInterval(duration), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = 0
        
        guard  let userInfo = sender.userInfo, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        //bottonLCDescrTextView.constant = 0
        
        UIView.animateWithDuration(NSTimeInterval(duration), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount = eventsButton.selected ? orgEvents.count : orgMembers.count
        if(eventsButton.selected) {
            if(!(isLeader() || isAdmin() || isMember())) {
                for event in orgEvents {
                    if(event.isPrivate) {
                        cellCount = cellCount - 1
                    }
                }
            }
        }
        return !editOrganization && (isLeader() || isAdmin()) ? cellCount + 1 : cellCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var index = indexPath.row
        
        if isLeader() || isAdmin() {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
                let title = eventsButton.selected ? "AddEvents" : "AddMembers"
                cell.titleLabel.text = NSLocalizedString(title, comment: title)
                return cell
            }
            index -= 1
        }
        
        if eventsButton.selected {
            let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
            let event = orgEvents[index]
            
            cell.eventNameLabel.text = event.name
            cell.eventOrganizationNameLabel.text = title
            cell.eventDescriptionLabel.text = event.descr
            let picture = event.picture
            PictureManager().loadPicture(picture, inImageView: cell.eventPictureImageView)
            
            if let date = event.startDate {
                cell.eventDateLabel.text = date.formatEvent()
            }
            
            return cell
        }
        
        if membersButton.selected {
            let user = orgMembers[index]
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
            let picture = user.picture
            PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            cell.titleLabel.text = user.name 
            cell.descriptionLabel.text = ""
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return eventsButton.selected ? EventTableViewCell.kCellHeight : FollowingTableViewCell.kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = isLeader() || isAdmin() ? indexPath.row - 1 : indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (isLeader() || isAdmin()) && indexPath.row == 0 {
            if eventsButton.selected {
                showCreateEventViewController(organization)
            } else {
                showInviteUsersViewController(organization, event: nil)
            }
            return
        }
        
        if eventsButton.selected {
            let event = orgEvents[index]
            event.organization = self.organization
            showEventDescriptionViewController(event)
        } else {
            let user = orgMembers[index]
            showProfileViewController(user)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        var index = indexPath.row
        
        if isLeader() || isAdmin() {
            if index == 0 {
                return false
            }
            
            if eventsButton.selected {
                return true
            }
            index -= 1
            let user = orgMembers[index]
            return !isLeader(user) && !isAdmin(user) || (isAdmin(user) && isLeader())
        }
        
        return false
    }
    
     func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if eventsButton.selected {
            let eventDeleteAction = UITableViewRowAction(style: .Default, title: "Remove") {[weak self] action, indexPath in
                self?.removeEventFromOrganization(indexPath)
            }
            return [eventDeleteAction]
        }
        
        var actions = [UITableViewRowAction]()
        let index = indexPath.row - 1
        let user = orgMembers[index]
        
        if !isAdmin(user) || isLeader() {
            let removeMemberButton = UITableViewRowAction(style: .Default, title: "Remove\nMember") {[weak self] action, indexPath in
                self?.removeUserFromOrganization(indexPath)
            }
            actions.append(removeMemberButton)
        }
        
        if isLeader() {
            var actionAdmin = UITableViewRowAction()
            
            if isAdmin(user) {
                actionAdmin = UITableViewRowAction(style: .Default, title: "Remove\nan\nAdministrator") {[weak self] action, indexPath in
                    self?.removeUserFromAdmins(user)
                }
            } else {
                actionAdmin = UITableViewRowAction(style: .Normal, title: "Make\nan\nAdministrator") {[weak self] action, indexPath in
                    self?.addUserInAdmins(user)
                }
            }
            
            actions.append(actionAdmin)
        }
        return actions
    }
    
    // MARK: - Helper
    
    private func addUserInAdmins(user: Users) {
        if user.objectId == nil {
            tableView.reloadData()
            return
        }
        
        OrganizationManager().addAdminOrganization(self.organization!, user: user, completion: {[weak self] entity, error in
            if entity != nil && error == nil {
                self?.tableView.reloadData()
            }
        })
    }
    
    private func removeUserFromAdmins(user: Users) {
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func removeUserFromOrganization(indexObject: NSIndexPath) {
        if isLeader() || isAdmin() {
            let user = orgMembers[indexObject.row - 1]
            OrganizationManager().unfollowingUserOnOrganization(organization!, user: user, completion: { (entity, error) in
                if error == nil && entity != nil {
                    if let objectIndex = self.orgMembers.indexOf(user) {
                        self.orgMembers.removeAtIndex(objectIndex)
                    }
                    
                    self.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                    self.tableView.reloadData()
                } else {
                    self.tableView.reloadData()
                    self.showAlert("Error", message: "User remove failed. Please try again later")
                }
            })
        }
    }
    
    func removeEventFromOrganization(indexObject: NSIndexPath) {
        let event = orgEvents[indexObject.row -  ((isAdmin() || isLeader()) ? 1 : 0)]
        
        self.showActivityIndicator()
        
        EventManager().deleteEvent(event) { [weak self] (success) in
            guard self != nil && success else {
                return
            }
            
            var events = self!.organization!.events
            if let index = events.indexOf(event) {
                events.removeAtIndex(index)
                self!.organization!.events = events
            }
            
            if let indexObj = self?.orgEvents.indexOf(event) {
                self?.orgEvents.removeAtIndex(indexObj)
            }
            
            self?.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
            self?.tableView.reloadData()
            self?.hideActivityIndicator()
        }
    }
}
