//
//  EventFeed.swift
//  Ripple
//
//  Created by Adam Gluck on 10/15/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import Parse

class EventFeed: UITableViewController {
    
    
    func alert(mainText: String, subText: String) // makes a function to display alerts
    {
        
        let userAlert = UIAlertController(title: mainText, message: subText, preferredStyle: UIAlertControllerStyle.Alert)
        
        userAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            // self.dismissViewControllerAnimated(true, completion: nil) (not wanted unless you want to go back to home page)
            
        }))
        
        self.presentViewController(userAlert, animated: true, completion: nil)
        
    }
    

    
  /*  @IBAction func Like(sender: AnyObject) {
        
        var status = PFObject(className:"status")
        status["likes"] = 10 //set to amount of likes
        var numlikes: NSNumber = status["likes"] as! NSNumber
        var Emessage = "Please try again later"
        status.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                    var increment = numlikes.integerValue + 1
                // The object has been incremented.
                
                //add something to show the increment
            } else {
                self.alert("Failed Like", subText: Emessage)
                
                // There was a problem, check error.description
            }
        }
        
    }
    //below is a comment function if needed
    
   @IBAction func Comment(sender: AnyObject) {
    } //comment should send to a different view controller
    */
    
    var messages = [String]()
    var usernames = [String]()
    var imagefiles = [PFFile]()
    var users = [String : String]() //makes a dictionary of users
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let query = PFUser.query() //kind of like a question = query
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.messages.removeAll(keepCapacity: true) // clear arrays
                self.users.removeAll(keepCapacity: true) // clear arrays
                self.imagefiles.removeAll(keepCapacity: true) //clears another fucking array
                self.usernames.removeAll(keepCapacity: true)
                
                
                for object in users {
                    
                    if let user = object as? PFUser
                    {
                        
                        self.users[user.objectId!] = user.username //puts all the users in the dictionary users to use later on
                        
                    }
                    
                }

            }

            
            let getFollowedUsersQuery = PFQuery(className: "followers") // starts to figure out who follows who
            
            getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            
            
            getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if let objects = objects //makes sure that the objects exists
                {
                    
                    for object in objects // loops through objects
                    {
                        
                        let followedUser = object["following"] as! String // the person being followed
                        
                        let query = PFQuery(className: "Post") //querying through the users posts
                        
                        query.whereKey("userId", equalTo: followedUser) // sets the followed user id to followedUser
                        
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            
                            if let objects = objects
                            {
                                
                                for object in objects {
                                    
                                    self.messages.append(object["Message"]as! String) //appending details to three arrays to store information about user being followed
                                    
                                    self.imagefiles.append(object["imageFile"] as! PFFile)
                                    
                                    self.usernames.append(self.users[object["userId"] as! String]!)
                                    
                                    self.tableView.reloadData()
                                    
                                }
                                print(self.users)
                                print(self.messages)
                            }
                        })
                        
                        
                    }
                    
                }
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cell
        //using the cell class
        
        imagefiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            
            if let downloadedImage = UIImage(data: data!) {
                
                myCell.postedImage.image = downloadedImage //downloads image
                
                
            }
        }
        
        
        myCell.username.text = usernames[indexPath.row] //chanes the message and username to whoever posted the picture
        
        myCell.message.text = messages[indexPath.row]
        
        return myCell
        


}
}
