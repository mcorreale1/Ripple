//
//  InviteUsersViewController.swift
//  Ripple
//
//  Created by evgeny on 08.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class InviteUsersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var event: RippleEvent?
    var organization: Organizations?
    
    var users = [Users]()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        prepareTableView()
        tableView.addSubview(label)
        label.text = NSLocalizedString("NoResults", comment: "NoResults")
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        label.font = label.font.fontWithSize(30)
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.center.x = (tableView.superview?.center.x)!
        label.center.y = (tableView.superview?.center.y)!
        label.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func prepareData() {
        UserManager().usersFromFacebookFriends() { (result) in
            if let fbFriends = result {
                self.users.appendContentsOf(fbFriends)
            }
        }
        tableView.reloadData()
    }
    
    func prepareTableView() {
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 1 {
//            return filteredUsers.count
//        }
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        let user = users[indexPath.row]
        cell.titleLabel.text = user.name ?? ""
        cell.descriptionLabel.text = ""
        if let picture = user.picture {
            PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
        } else {
            cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
        }
        
//        if indexPath.section == 1 {
//            let user = searchBar.text == "" ? users[indexPath.row] : filteredUsers[indexPath.row]
//            cell.titleLabel.text = user.name ?? ""
//            if let picture = user.picture {
//                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
//            } else {
//                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
//            }
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let invitationButton = UITableViewRowAction(style: .Normal, title: "Send Invitation") {[weak self] action, indexPath in
            self?.sendInvitationTouched(indexPath)
        }
        invitationButton.backgroundColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        return [invitationButton]
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let refreshAlert = UIAlertController(title: "Are you sure you want to send an invitation to this user?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.sendInvitationTouched(indexPath)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
        header.titleHeader.text = section == 0 ? "Users to Invite" : "Following on Pulse"
        return header
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 14
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchBar.text == "" {
            return
        }
        if let searchString = searchBar.text {
            if event != nil {
                UserManager().getUsersToInviteToEvent(event!, searchString: searchString) { (result, error) in
                    self.users.removeAll()
                    if(error == nil) {
                        self.users.appendContentsOf(result)
                        self.tableView.reloadData()
                    }
                }
            } else if organization != nil {
                UserManager().findUsersToInviteToOrganization(organization!, searchString: searchString) { (result, error) in
                    self.users.removeAll()
                    if(error == nil) {
                        self.users.appendContentsOf(result)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
        
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        let searchUserPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
//        filteredUsers = (users as NSArray).filteredArrayUsingPredicate(searchUserPredicate) as! [Users]
//        tableView.reloadData()
//        
//        if filteredUsers.count == 0  {
//            label.hidden = false
//        }
//        else {
//            label.hidden = true
//        }
//        if searchBar.text! == "" {
//            label.hidden = true
//        }
//        
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Actions
    
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
    
    func sendInvitationTouched(objectIndex: NSIndexPath) {
        //let user = searchBar.text == "" ? users[objectIndex.row] : filteredUsers[objectIndex.row]
        let user = users[objectIndex.row]
        showActivityIndicator()
        if organization != nil {
            print("sending org invite to \(user.name)")
            InvitationManager().sendInvitationInOrganization(user, organization: organization!) {[weak self] (success) in
                self?.hideActivityIndicator()
                if success {
                    print("success")
//                    if self?.searchBar.text == "" {
//                        self?.users.removeAtIndex(objectIndex.row)
//                    } else {
//                        self?.filteredUsers.removeAtIndex(objectIndex.row)
//                    }
                    
                    self?.users.removeAtIndex(objectIndex.row)
                    self?.tableView.deleteRowsAtIndexPaths([objectIndex], withRowAnimation: .Left)
                    
                    if let deviceID = user.getProperty("deviceID") as? String {
                    
                        self!.publishMessageAsPushNotificationSync(UserManager().currentUser().name! + " Invited you to join " + self!.organization!.name!, deviceId: deviceID)
                    }
                    self?.tableView.reloadData()
                }
            }
        }
        
        if event != nil {
            InvitationManager().sendInvitationOnEvent(user, event: event!, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                print("in send invite")
                if success {
                    print("send invite successful")
//                    if self?.searchBar.text == "" {
//                        self?.users.removeAtIndex(objectIndex.row)
//                    } else {
//                        self?.filteredUsers.removeAtIndex(objectIndex.row)
//                    }
                    self?.users.removeAtIndex(objectIndex.row)
                    self?.tableView.deleteRowsAtIndexPaths([objectIndex], withRowAnimation: .Left)
                    
                    let selectedUser = UserManager().currentUser().name
                    
                    if let deviceID = user.getProperty("deviceID") as? String {
                        print("sending to device id: \(deviceID)")
                        self!.publishMessageAsPushNotificationSync(selectedUser! + " invited you to an event", deviceId: deviceID)
                    }
                    self?.tableView.reloadData()
                }
            })
        }
    }

}
