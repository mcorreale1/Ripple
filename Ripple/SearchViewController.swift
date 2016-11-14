//
//  Search.swift
//  Ripple
//
//  Created by Adam Gluck on 2/11/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORLocalizationSystem

class SearchViewController: BaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    let backgroundColor = UIColor.init(red: 59/255, green: 59/255, blue: 59/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [PFUser]()
    var organizations = [PFObject]()
    var filteredUsers = [PFUser]()
    var filteredOrganizations = [PFObject]()
    var label = UILabel()
    
    var searchBar: UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchBar()
        prepareTableView()
//        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings_button"), style: .Plain, target: self, action: #selector(SearchViewController.settingsTouched(_ :)))
//        navigationItem.rightBarButtonItem = settingsButton
        label.font = label.font.fontWithSize(30)
        label.textColor = UIColor.whiteColor()
        label.text = NSLocalizedString("NoResults", comment: "NoResults")
        label.sizeToFit()
        label.center.x = (tableView.superview?.center.x)!
        label.center.y = (tableView.superview?.center.y)!
        self.view.addSubview(label)
        label.hidden = true
//        settingsButton.enabled = true
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.userInteractionEnabled = true
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.whiteColor()
        nav?.barTintColor = UIColor.blackColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        prepareData()
//        navigationItem.rightBarButtonItem?.enabled = true
        showActivityIndicator()
     }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.userInteractionEnabled = false
        let navigationController = self.navigationController?.navigationBar
        navigationController?.barTintColor = UIColor.whiteColor()
        navigationController?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)]
        hideActivityIndicator()
    }
    
    func prepareSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.searchBarStyle = .Minimal
        searchBar.setImage(UIImage(named: "search_icon"), forSearchBarIcon: .Search, state: .Normal)
        
        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.whiteColor()
            textFieldInsideSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
            textFieldInsideSearchBar.layer.borderWidth = 1
            textFieldInsideSearchBar.layer.cornerRadius = 6
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string:"Search", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        }
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.barTintColor = backgroundColor
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func prepareTableView() {
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
    }
    
    func prepareData() {
        showActivityIndicator()
        OrganizationManager().allUnfollowOrganizations {[weak self] (organizations, error) in
            self?.hideActivityIndicator()
            
            if organizations != nil {
                self?.organizations = organizations!
                self?.organizations.sortInPlace { (org1: PFObject, org2: PFObject) -> Bool in
                    let name1 = org1["name"] as? String
                    let name2 = org2["name"] as? String
                    return name1?.lowercaseString < name2?.lowercaseString
                }
                self?.tableView.reloadData()
            }
        }
        
        UserManager().allUnfollowUsers {[weak self] (users, error) in
            self?.hideActivityIndicator()
            
            if users != nil {
                self?.users = users!
                self?.users.sortInPlace { (user1: PFObject, user2: PFObject) -> Bool in
                    let name1 = user1["fullName"] as? String
                    let name2 = user2["fullName"] as? String
                    return name1?.lowercaseString < name2?.lowercaseString
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        return false
    }
    
    // MARK: - UISearchBarDelegate
    func sortAlp(user1: PFUser, user2: PFUser) -> Bool{
        let name1 = user1["fullName"] as? String
        let name2 = user2["fullName"] as? String
        return name1 < name2
    }
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchUserPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchText)
        let searchOrgPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        filteredUsers = (users as NSArray).filteredArrayUsingPredicate(searchUserPredicate) as! [PFUser]
        filteredOrganizations = (organizations as NSArray).filteredArrayUsingPredicate(searchOrgPredicate) as! [PFObject]
        filteredOrganizations.sortInPlace { (org1: PFObject, org2: PFObject) -> Bool in
            let name1 = org1["name"] as? String
            let name2 = org2["name"] as? String
            return name1?.lowercaseString < name2?.lowercaseString
        }
        filteredUsers.sortInPlace { (user1: PFObject, user2: PFObject) -> Bool in
            let name1 = user1["fullName"] as? String
            let name2 = user2["fullName"] as? String
            return name1?.lowercaseString < name2?.lowercaseString
        }
        tableView.reloadData()
        
        if (filteredUsers.count == 0 && filteredOrganizations.count == 0) {
            label.hidden = false
        }
        else {
            label.hidden = true

        }
        if searchBar.text! == "" {
            label.hidden = true
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return searchBar.text == "" ? users.count : filteredUsers.count
        } else {
            return searchBar.text == "" ? organizations.count : filteredOrganizations.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        cell.descriptionLabel.text = ""
        
        if indexPath.section == 0 {
            let user = searchBar.text == "" ? users[indexPath.row] : filteredUsers[indexPath.row]
            cell.titleLabel.text = user["fullName"] as? String
            if let picture = user["picture"] as? PFObject {
                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
            }
        } else {
            let organization = searchBar.text == "" ? organizations[indexPath.row] : filteredOrganizations[indexPath.row]
            cell.titleLabel.text = organization["name"] as? String
            if let picture = organization["picture"] as? PFObject {
                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
            }

        }
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let followButton = UITableViewRowAction(style: .Normal, title: "Follow") {[weak self] action, indexPath in
                self?.followingOnObject(indexPath)
        }
        followButton.backgroundColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        return [followButton]
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CustomTableHeaderView") as! CustomTableHeaderView
        header.titleHeader.text = section == 0 ? NSLocalizedString("SuggestedFriends", comment: "SuggestedFriends") : NSLocalizedString("Organizations", comment: "Organizations")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        return cell.frame.height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.userInteractionEnabled = false
        if indexPath.section == 1 {
            if(filteredOrganizations.count != 0){
                showOrganizationProfileViewController(filteredOrganizations[indexPath.row], isNewOrg: false)
            } else {
                showOrganizationProfileViewController(organizations[indexPath.row], isNewOrg: false)
            }
        }
        else{
            if( filteredUsers.count != 0) {
                showProfileViewController(filteredUsers[indexPath.row])
            } else {
                showProfileViewController(users[indexPath.row])
            }
            
        }
    }

    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    func followingOnObject(indexObject: NSIndexPath) {
        showActivityIndicator()
        if indexObject.section == 0 {
            let user = searchBar.text == "" ? users[indexObject.row] : filteredUsers[indexObject.row]
            UserManager().followingOnUser(user, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                if success {
                    if self?.searchBar.text == "" {
                        self?.users.removeAtIndex(indexObject.row)
                    } else {
                        self?.filteredUsers.removeAtIndex(indexObject.row)
                    }
                    self?.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                }
            })
        } else {
            let organization = searchBar.text == "" ? organizations[indexObject.row] : filteredOrganizations[indexObject.row]
            OrganizationManager().followingOnOrganization(organization, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                if success {
                    if self?.searchBar.text == "" {
                        self?.organizations.removeAtIndex(indexObject.row)
                    } else {
                        self?.filteredOrganizations.removeAtIndex(indexObject.row)
                    }
                    self?.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                }
            })
        }
    }
    
    func settingsTouched(sender: UIBarButtonItem!) {
//        navigationItem.rightBarButtonItem?.enabled = false
        self.performSegueWithIdentifier("ShowSettings", sender: self)
    }
    
    @IBAction func segmentedControllerValueChange(sender: AnyObject) {
        tableView.reloadData()
    }
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        
    }
}
