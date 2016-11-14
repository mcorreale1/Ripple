//
//  AddFriendsViewController.swift
//  Ripple
//
//  Created by evgeny on 12.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import  ORLocalizationSystem

class AddFriendsViewController: BaseViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource {

    var allUsers = [PFUser]()
    var filteredUsers = [PFUser]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addFriends: UILabel!
   
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        addFriends.text = NSLocalizedString("Add Friends", comment: "Add Friends")
    }
    
    func prepareData() {
        showActivityIndicator()
        /*API().allUsers({ (users, error) in
            self.hideActivityIndicator()
            
            if users != nil {
                self.allUsers = users!
            } else if error != nil {
                self.showAlert("Error", message: error!.localizedDescription)
            }
            self.tableView.reloadData()
        })*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate = NSPredicate(format: "username CONTAINS[c] %@", searchText)
        let array = (allUsers as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredUsers = array as! [PFUser]
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.text! == "" ? filteredUsers.count : allUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        let user = searchBar.text! == "" ? allUsers[indexPath.row] : filteredUsers[indexPath.row]
        
        if (user["imageFile"] != nil) {
            if let picture = user["imageFile"]  as? PFObject {
                PictureManager().loadPicture(picture, inImageView: cell.imageView)
            } else {
                cell.imageView?.image = UIImage(named: "user_dafault_picture")
            }
        } else {
            cell.textLabel?.text = user.username
        }
        
        return cell
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
