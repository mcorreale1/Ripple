//
//  ProfileFriendsViewController.swift
//  Ripple
//
//  Created by evgeny on 11.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORLocalizationSystem

class ProfileFriendsViewController: BaseViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource {
    
    var allFriends = [PFUser]()
    var filteredFriends = [PFUser]()
    var selectedUser: PFUser?
    
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendsLabel: UILabel!
    
    var titleMessage :String = ""
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        addFriendsButton.hidden = selectedUser!.objectId != PFUser.currentUser()?.objectId
        friendsLabel.text = NSLocalizedString("Friends", comment: "Friends")
    }

    func prepareData() {
        showActivityIndicator()
        API().friendsWithUser(selectedUser!) { (friends, error) in
            self.hideActivityIndicator()
            
            if friends != nil {
                self.allFriends = friends!
            } else if error != nil {
                self.titleMessage = NSLocalizedString("Error", comment: "Error")
                self.showAlert(self.titleMessage, message: error!.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate = NSPredicate(format: "username CONTAINS[c] %@", searchText)
        let array = (allFriends as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredFriends = array as! [PFUser]
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.text! == "" ? filteredFriends.count : allFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "FriendCell")
        }
        
        let user = searchBar.text! == "" ? allFriends[indexPath.row] : filteredFriends[indexPath.row]
        
        if (user["imageFile"] != nil) {
            cell!.imageView?.image = user["imageFile"] as? UIImage
        } else {
            cell!.textLabel?.text = user.username
        }
        
        return cell!
    }
    
    // MARK: - Actions
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
