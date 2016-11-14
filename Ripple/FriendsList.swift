//
//  FriendsList.swift
//  Ripple
//
//  Created by Adam Gluck on 11/4/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import Parse

class FriendsList: UITableViewController, UISearchResultsUpdating {

    @IBOutlet var MessageTableView: UITableView! //named to fit code
    
    var images = [UIImage]()
    var usernames = [String]()
    
    var tableData: [String] = [String]()
   func loadParseData()
   {
    
    //fuck around with this to query through the users and then display the queried data to the user table
    let query = PFUser.query()!
    query.whereKey("accepted", equalTo: PFUser.currentUser()!.objectId!)
    query.whereKey("objectId", containedIn: PFUser.currentUser()?["accepted"] as! [String])
    
    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
        
        if let results = results {
            
            for result in results as! [PFUser] {
                
                self.usernames.append(result.username!)
                
                let imageFile = result["image"] as! PFFile
                
                imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    
                    if error != nil {
                        
                        print(error, terminator: "")
                        
                    } else {
                        
                        if let data = imageData {
                            
                            self.images.append(UIImage(data: data)!)
                            
                            self.tableView.reloadData()
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }
            
            self.tableView.reloadData()
            
        }
        
    }
   /* query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
    
    }
    */
    
    // return query
    
    //queries through all users that aren't PFUser
    }
    
    var friendsList = [String]()
    var resultSearchController = UISearchController()
    
    
    func retrieveMessages() {
        
        let query:PFQuery = PFQuery(className: "FriendList")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            
            self.friendsList = [String]()
            
            for messageObject in objects! //this is actually just friends
            {
                
                let messageText:String? = (messageObject )["Friends"] as? String
                
                if (messageText != nil)
                {
                    self.friendsList.append(messageText!) //friends list
                    
                }
            }
            dispatch_async(dispatch_get_main_queue()) //runs it on a parallel main thread
                {
                    self.MessageTableView.reloadData()
            }
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //need a command like setbackground color
        

        loadParseData()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.backgroundColor = UIColor.clearColor()
            self.tableView.backgroundColor = UIColor.clearColor()
            self.tableView.backgroundView = nil
            
            controller.searchBar.backgroundImage = UIImage(named: "pattern back.png")
            
            
            self.tableView.tableHeaderView = controller.searchBar
            
            
            return controller
        })()
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if (self.resultSearchController.active) {
            return self.friendsList.count
        }
        else {
            return self.usernames.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        if images.count > indexPath.row {
            
            cell.imageView?.image = images[indexPath.row]
            
        }

        
        // 3
        if (self.resultSearchController.active) {
            cell.textLabel?.text = friendsList[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = usernames[indexPath.row]
            
            return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        friendsList.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (tableData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        friendsList = array as! [String]
        
        self.tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         self.performSegueWithIdentifier("Messages", sender: self)

    }
}
