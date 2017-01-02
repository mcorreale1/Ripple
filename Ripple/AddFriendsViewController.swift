//
//  AddFriendsViewController.swift
//  Ripple
//
//  Created by evgeny on 12.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class AddFriendsViewController: BaseViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource {

    var allUsers = [Users]()
    var filteredUsers = [Users]()
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        let array = (allUsers as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredUsers = array as! [Users]
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.text! == "" ? filteredUsers.count : allUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        let user = searchBar.text! == "" ? allUsers[indexPath.row] : filteredUsers[indexPath.row]
        
        // TODO problems here too
//        if (user["imageFile"] != nil) {
//            if let picture = user["imageFile"]  as? PFObject {
//                PictureManager().loadPicture(picture, inImageView: cell.imageView)
//            } else {
//                cell.imageView?.image = UIImage(named: "user_dafault_picture")
//            }
//        } else {
            cell.textLabel?.text = user.name
//        }
        
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
