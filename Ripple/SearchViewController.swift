//
//  Search.swift
//  Ripple
//
//  Created by Adam Gluck on 2/11/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import FBSDKLoginKit

class SearchViewController: BaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, ProfileViewControllerDelegate {
    
    let backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [Users]()
    var organizations = [Organizations]()
    var filteredUsers = [Users]()
    var filteredOrganizations = [Organizations]()
    var filteredEvents = [RippleEvent]()
    var label = UILabel()
    
    var searchBar: UISearchBar = UISearchBar()
    
    let titleColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    
    var allUsersLoaded = false
    var allOrganizationsLoaded = false
    var allEventsLoaded = false
    
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
        //searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.userInteractionEnabled = true
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1) //back button color
        nav?.barTintColor = UIColor.whiteColor()
       // nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
     }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.userInteractionEnabled = false
        let navigationController = self.navigationController?.navigationBar
        navigationController?.barTintColor = UIColor.whiteColor()
        navigationController?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)]
        hideActivityIndicator()
    }
    
    
    func prepareSearchBar() {
        //searchBar.sizeToFit()
        searchBar.delegate = self
        //searchBar.tintColor = UIColor.whiteColor()
        searchBar.searchBarStyle = .Minimal
        //searchBar.setImage(UIImage(named: "SearchBarSearchController"), forSearchBarIcon: .Search, state: .Normal)
        
        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            //textFieldInsideSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
            textFieldInsideSearchBar.backgroundColor = UIColor.clearColor()
//            textFieldInsideSearchBar.layer.borderWidth = 1
//            textFieldInsideSearchBar.layer.cornerRadius = 6
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string:"Search Events, Orgs and Friends!", attributes:[NSForegroundColorAttributeName: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha:1)])
        }
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.barTintColor = titleColor
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
    //added loadunfolloworg and hide activity indicator
    func prepareData() {
        showActivityIndicator()
        loadUnfollowUsers()
        loadUnfollowOrganizations()
        hideActivityIndicator()
        
    }
    
    private func loadEvents() {
        if(allEventsLoaded) {
            self.tableView.reloadData()
            return
        }
    }
    
    //FacebookSDK stuff in here, add more to it later
    private func loadUnfollowUsers() {
        if(allUsersLoaded) {
            self.tableView.reloadData()
            return
        }
    
        
        let params = ["fields": "name, user_friends, uid", ]
        let graphRequest = FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: params)
        
        UserManager().loadUnfollowUsers(usersCollection) { [weak self] (users, collection, error) in
            if users != nil && users!.count > 0 {
                AppDelegate().loginToFacebook()
                var facebookFriendNames = [String]()
                _ = graphRequest.startWithCompletionHandler() { [weak self] (connection, result, error) in
                    if(error != nil) {
                        print("Error \(error.description)")
                        return
                    }
                    print("Print fbsdk result \(result)")
                    
                    if let dictionary = result as? NSDictionary {
                        if let friendsArray = dictionary["data"] as! [AnyObject]? {
                            for rawFriend in friendsArray {
                                let friend = rawFriend as! NSDictionary
                                let name = friend["name"] as! String

                                facebookFriendNames.append(name)
                            }
                        }
                    }
                    print("Friends array \(facebookFriendNames)")
                    
                    var FBFriends = [Users]()
                    var otherFriends = [Users]()
                    for user in users! {
                        for currentUser in (self?.users)! {
                            if (user.name == currentUser.name) {
                                self?.allUsersLoaded = true
                                return
                            }
                        }
                        if(facebookFriendNames.contains(user.name!)) {
                            print("Found friend!")
                        }
                        (facebookFriendNames.contains(user.name!)) ? FBFriends.append(user) : otherFriends.append(user)
                    }
                    FBFriends.appendContentsOf(otherFriends)
                    
                    self?.usersCollection = collection
                    self?.users.appendContentsOf(FBFriends)
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.tableView.reloadData()
                    }
                }
                
            } else {
                self?.allUsersLoaded = true
                self?.usersCollection = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    //something is wrong with this method, why is this one weak but not the others?
    private func loadUnfollowOrganizations() {
        if(allOrganizationsLoaded) {
            tableView.reloadData()
            return
        }
        OrganizationManager().allUnfollowOrganizations(organizationsCollection) {[weak self] (orgs, collection, error) in
            if orgs != nil && orgs!.count > 0 {
                //print(orgs?.description)
                //print(self?.organizations.description)
                for newOrg in orgs! {
                    for currentOrg in (self?.organizations)! {
                        if (newOrg.name == currentOrg.name) {
                            self?.allOrganizationsLoaded = true
                            return
                        }
                    }
                }
                self?.organizations.appendContentsOf(orgs!)
                dispatch_async(dispatch_get_main_queue()) {
                    self?.tableView.reloadData()
                }
            } else {
                self!.allOrganizationsLoaded = true
                self!.organizationsCollection = nil //added
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
        filteredEvents.removeAll()
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
                OrganizationManager().searchOrgs(searchBar.text!, completion: { (organizations, error) in
                    self?.hideActivityIndicator()
                    self?.tableView.userInteractionEnabled = true
                    
                    if (organizations != nil) {
                        self?.filteredOrganizations = organizations!
                    }
                    
                    self?.tableView.reloadData()
                    EventManager().searchEventsByName(searchBar.text!) { (events) in
                        self?.filteredEvents.appendContentsOf(events)
                        self?.tableView.reloadData()
                        
                        if (self?.filteredOrganizations.count < 1 && self?.filteredUsers.count < 1 && self?.filteredEvents.count < 1) {
                            self?.tableView.hidden = true
                            self?.label.hidden = false
                        }
                    }

                })
            })
        }
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if searchMode {
                return filteredUsers.count
            }
            return users.count == 0 || allUsersLoaded ? users.count : users.count + 1
        } else if (section == 1) {
            if searchMode {
                return filteredOrganizations.count
            }
            return allOrganizationsLoaded || !allUsersLoaded ? organizations.count : organizations.count + 1
        } else {
            if(filteredEvents.count > 0) {
                tableView.hidden = false
                label.hidden = true
            }
            return filteredEvents.count
        }
    }
    //Not here
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        //Possible memory leak here?
        cell.descriptionLabel.text = ""
        if indexPath.section == 0 {
            if (indexPath.row >= users.count) {
                loadUnfollowUsers()
                let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! LoadingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            let user = searchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
            cell.titleLabel.text = user.name
            if let picture = user.picture {
                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
            }
        } else if (indexPath.section == 1) {
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
        } else {
            let event = filteredEvents[indexPath.row]
            cell.titleLabel.text = event.name
            if let picture = event.picture {

                PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
            } else {
                cell.pictureImageView.image = UIImage(named: "user_default_picture")
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let followButton = UITableViewRowAction(style: .Normal, title: "Follow") {[weak self] action, indexPath in
                self?.followingOnObject(indexPath)
        }
        followButton.backgroundColor = UIColor.init(red: 0/255, green: 255/255, blue: 0/255, alpha: 1)
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
        var headerText:String
        if(section == 0) {
            headerText = NSLocalizedString("Suggested Friends", comment: "Suggested Friends")
        } else if (section == 1) {
            headerText = NSLocalizedString("Organizations", comment: "Organizations")
        } else {
            headerText = "Events"
        }
        header.titleHeader.text = headerText
        return header
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.init(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
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
                showOrganizationProfileViewController(filteredOrganizations[indexPath.row], isNewOrg: false, fromInvite: false)
            } else {
                if(indexPath.row > organizations.count-1) {
                    self.view.userInteractionEnabled = true
                    return
                }
                showOrganizationProfileViewController(organizations[indexPath.row], isNewOrg: false, fromInvite: false)
            }
        } else if(indexPath.section == 0) {
            if (filteredUsers.count != 0) {
                showProfileViewController(filteredUsers[indexPath.row], delegate: self)
            } else {
                showProfileViewController(users[indexPath.row], delegate: self)
            }
            
        } else {
            if(filteredEvents.count != 0) {
                showEventDescriptionViewController(filteredEvents[indexPath.row])
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
        } else if(indexObject.section == 1){
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
