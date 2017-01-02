//
//  MessagesContactListViewController.swift
//  Ripple
//
//  Created by Apple on 07.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class MessagesContactListViewController: BaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let titleColor = UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)
    override var chatSegueIdentifier: String { return "chat" }
    var users = [Users]()
    var filteredUsers = [Users]()
    static let cellId = "participantId"
    var searchBar: UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserManager().followingUsers(UserManager().currentUser()) {[weak self] (users) in
            self?.users = users
            self?.tableView.reloadData()
        }
        
        let nibFollowingCell = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "FollowingCell")
        // Do any additional setup after loading the view.
        prepareSearchBar()
        
        let button = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(MessagesContactListViewController.goBack))
        self.navigationItem.leftBarButtonItem = button
        navigationItem.leftBarButtonItem?.image = UIImage(named: "back 1")
        
    }

    // MARK: UITableViewDataSourse
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.text == "" ? users.count : filteredUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingTableViewCell
        let user = searchBar.text == "" ? self.users[indexPath.row] : filteredUsers[indexPath.row]
        
        cell.titleLabel.text = user.fullName
        cell.descriptionLabel.text = nil
        
        if let picture = user.picture {
            PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
        } else {
            cell.pictureImageView.image = UIImage(named: "user_dafault_picture")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = searchBar.text == "" ? self.users[indexPath.row] : filteredUsers[indexPath.row]
        
        if !isPerformingSegueToChat {
            isPerformingSegueToChat = true
            addChatWithUser(user)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "chat" {
            let user = sender as! Users
            let destinationVC = segue.destinationViewController as! ChatViewController
            destinationVC.user = user
            destinationVC.title = user.fullName
        }
    }
    
    func prepareSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.tintColor = UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)
        searchBar.searchBarStyle = .Minimal
        searchBar.setImage(UIImage(named: "search_icon"), forSearchBarIcon: .Search, state: .Normal)
        
        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = titleColor
            textFieldInsideSearchBar.layer.borderColor = titleColor.CGColor
            textFieldInsideSearchBar.layer.borderWidth = 1
            textFieldInsideSearchBar.layer.cornerRadius = 6
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string:"Search", attributes:[NSForegroundColorAttributeName: titleColor])
        }
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = titleColor
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchUserPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchText)
        filteredUsers = (users as NSArray).filteredArrayUsingPredicate(searchUserPredicate) as! [Users]
        tableView.reloadData()
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }

}
