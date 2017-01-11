//
//  Search.swift
//  Ripple
//
//  Created by Adam Gluck on 2/11/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class SearchViewController: BaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, ProfileViewControllerDelegate {
    
    let backgroundColor = UIColor.init(red: 59/255, green: 59/255, blue: 59/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [Users]()
    var organizations = [Organizations]()
    var filteredUsers = [Users]()
    var filteredOrganizations = [Organizations]()
    var label = UILabel()
    
    var searchBar: UISearchBar = UISearchBar()
    
    var allUsersLoaded = false
    var allOrganizationsLoaded = false
    
    var searchMode = false
    
    var usersCollection: BackendlessCollection?
    var organizationsCollection: BackendlessCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchBar()
        prepareTableView()
        label.font = label.font.fontWithSize(30)
        label.textColor = UIColor.whiteColor()
        label.text = NSLocalizedString("NoResults", comment: "NoResults")
        label.sizeToFit()
        label.center.x = (tableView.superview?.center.x)!
        label.center.y = (tableView.superview?.center.y)!
        self.view.addSubview(label)
        label.hidden = true
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.userInteractionEnabled = true
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.whiteColor()
        nav?.barTintColor = UIColor.blackColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
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
        let nibLoadingCell = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.registerNib(nibLoadingCell, forCellReuseIdentifier: "LoadingCell")
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        let nibSectionHeader = UINib(nibName: "CustomTableHeaderView", bundle: nil)
        tableView.registerNib(nibSectionHeader, forHeaderFooterViewReuseIdentifier: "CustomTableHeaderView")
    }
    
    func prepareData() {
        showActivityIndicator()
        loadUnfollowUsers()
    }
    
    private func loadUnfollowUsers() {
        UserManager().loadUnfollowUsers(usersCollection) { (users, collection, error) in
            self.hideActivityIndicator()
            
            if users != nil && users!.count > 0 {
                self.usersCollection = collection
                self.users.appendContentsOf(users!)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                self.allUsersLoaded = true
                self.usersCollection = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func loadUnfollowOrganizations() {
        OrganizationManager().allUnfollowOrganizations(organizationsCollection) {[weak self] (organizations, collection, error) in
            self?.hideActivityIndicator()
            self?.organizationsCollection = collection
            
            if organizations != nil && organizations!.count > 0 {
                print(organizations?.description)
                self?.organizations.appendContentsOf(organizations!)
                dispatch_async(dispatch_get_main_queue()) {
                    self?.tableView.reloadData()
                }
            } else {
                self?.allOrganizationsLoaded = true
                dispatch_async(dispatch_get_main_queue()) {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchMode = false
        tableView.hidden = false
        label.hidden = true
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchMode = true
        showActivityIndicator()
        tableView.userInteractionEnabled = false
        filteredUsers.removeAll()
        filteredOrganizations.removeAll()
    
        if (searchBar.text != nil && searchBar.text!.characters.count > 0) {
            UserManager().searchUsers(searchBar.text!, completion: {[weak self] (users, error) in
                if (users != nil) {
                    self?.filteredUsers = users!
                }
                print("User results: \(users?.debugDescription)")
                OrganizationManager().searchOrgs(searchBar.text!, completion: { (organizations, error) in
                //OrganizationManager().searchUnfollowOrganizations(searchBar.text!, completion: { (organizations, error) in
                    
                    print("Org results: \(organizations?.debugDescription)")
                        
                    self?.hideActivityIndicator()
                    self?.tableView.userInteractionEnabled = true
                    
                    if (organizations != nil) {
                        self?.filteredOrganizations = organizations!
                    }
                    
                    self?.tableView.reloadData()
                    
                    if (self?.filteredOrganizations.count < 1 && self?.filteredUsers.count < 1) {
                        self?.tableView.hidden = true
                        self?.label.hidden = false
                    }
                })
            })
        }
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if searchMode {
                return filteredUsers.count
            }
            return users.count == 0 || allUsersLoaded ? users.count : users.count + 1
        } else {
            if searchMode {
                return filteredOrganizations.count
            }
            return allOrganizationsLoaded || !allUsersLoaded ? organizations.count : organizations.count + 1
        }
    }
    //Not here
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        cell.descriptionLabel.text = ""
        if indexPath.section == 0 {
            if (indexPath.row >= users.count) {
                loadUnfollowUsers()
                let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! LoadingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            let user = searchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
            cell.titleLabel.text = user.fullName
            if let picture = user.picture {
                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
            }
        } else {
            if (indexPath.row >= organizations.count) {
                loadUnfollowOrganizations()
                let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! LoadingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            
            let organization = searchMode ? filteredOrganizations[indexPath.row] : organizations[indexPath.row]
            cell.titleLabel.text = organization.name
            
            if let picture = organization.picture {
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
            if (filteredOrganizations.count != 0) {
                showOrganizationProfileViewController(filteredOrganizations[indexPath.row], isNewOrg: false, fromInvite: true)
            } else {
                showOrganizationProfileViewController(organizations[indexPath.row], isNewOrg: false, fromInvite: true)
            }
        } else {
            if (filteredUsers.count != 0) {
                print("User count: \(filteredUsers.count)")
                print("indexPath: \(indexPath.row)")
                showProfileViewController(filteredUsers[indexPath.row], delegate: self)
            } else {
                showProfileViewController(users[indexPath.row], delegate: self)
            }
            
        }
    }

    // MARK: - ProfileViewControllerDelegate
    
    func followCompletedOnUser(user: Users?) {
        guard let followUser = user else {
            return
        }
        
        if searchMode {
            if let index = filteredUsers.indexOf(followUser) {
                filteredUsers.removeAtIndex(index)
                tableView.reloadData()
            }
        } else {
            if let index = users.indexOf(followUser) {
                users.removeAtIndex(index)
                tableView.reloadData()
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
            let user = searchMode ? filteredUsers[indexObject.row] : users[indexObject.row]
            UserManager().followingOnUser(user, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                if self != nil && success {
                    if self!.searchMode {
                        self?.filteredUsers.removeAtIndex(indexObject.row)
                    } else {
                        self?.users.removeAtIndex(indexObject.row)
                    }
                    self?.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                }
            })
        } else {
            let organization = searchMode ? filteredOrganizations[indexObject.row] : organizations[indexObject.row]
            UserManager().followOnOrganization(organization, completion: {[weak self] (success) in
                self?.hideActivityIndicator()
                if self != nil && success {
                    if self!.searchMode {
                        self?.filteredOrganizations.removeAtIndex(indexObject.row)
                    } else {
                        self?.organizations.removeAtIndex(indexObject.row)
                    }
                    self?.tableView.deleteRowsAtIndexPaths([indexObject], withRowAnimation: .Left)
                }
            })
        }
    }
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
