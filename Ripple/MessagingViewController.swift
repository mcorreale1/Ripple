//
//  MessagingViewController.swift
//  Ripple
//
//  Created by Apple on 07.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Photos
import UIKit

import Parse
import Firebase
import GoogleMobileAds

let KBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

struct ChatRoomDetails {
    let roomID: String
    let creatorId, interlocutorId: String
    let creatorName, interlocutorName: String
    let lastMessage: String?
    let lastMessageDate: NSDate?
    let hasNewMessages: Bool
}

class MessagingViewController: BaseMessageViewController, UITableViewDataSource, UITableViewDelegate{
    
    let kMessagesToChatSegue = "messagesToChat"
    
    let dateFormatter: NSDateFormatter = {
       let df = NSDateFormatter()
        df.dateFormat = "dd MMM h:mm a"
        
        return df
    }()
    
    // TODO Find better way
    var myRooms: [ChatRoomDetails]!
    var otherRooms: [ChatRoomDetails]!
    var users = [PFUser]()
    
    var chatRooms: [ChatRoomDetails] {
        get {
            var totalRooms = myRooms
            totalRooms.appendContentsOf(otherRooms)
            return totalRooms
        }
    }
    //----------------------
    
    var msglength: NSNumber = 10
    private var _refHandle: FIRDatabaseHandle!
    
    var storageRef: FIRStorageReference!
    var remoteConfig: FIRRemoteConfig!
    
    let showMessegesContactsId = "messegesContacts"
    let titleColor = UIColor.init(red: 40/255, green: 19/255, blue: 76/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myRooms = []
        self.otherRooms = []
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        // Do any additional setup after loading the view.
        let contactsButton = UIBarButtonItem(image: UIImage(named: "messeges_contact_list"), style: .Plain, target: self, action: #selector(MessagingViewController.contactsTouched(_:)))
        contactsButton.tintColor = titleColor
        navigationItem.rightBarButtonItem = contactsButton
        navigationController?.navigationBar.tintColor = titleColor
        self.navigationController?.navigationBar.tintColor = titleColor
        
        let nibFollowingCell = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "MessagingCell")
        
        UserManager().followingUsers(UserManager().currentUser()) {[weak self] (users) in
            self?.users = users}
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addDatabaseHandlers()
    }
    
    // MARK: - Internal operations
    
    func contactsTouched(sender: AnyObject) {
        performSegueWithIdentifier(showMessegesContactsId, sender: self)
    }
    
    
    func addDatabaseHandlers() {
        addMyRoomsHandler()
        addOtherRoomsHandler()
    }
    
    func addMyRoomsHandler() {
        // Listen for new messages in the Firebase database
        let currentUserID = (PFUser.currentUser()?.objectId)!
        
        let query = databaseRef.child("chatrooms").queryOrderedByChild("createdBy").queryEqualToValue(currentUserID)
        let databaseHandlerId = query.observeEventType(.Value) { [weak self] (snapshot: FIRDataSnapshot) in
            guard let sself = self else {
                return
            }
            sself.hideActivityIndicator()

            guard !(snapshot.value is NSNull) else {
                sself.myRooms = [ChatRoomDetails]()
                sself.tableView.reloadData()
                print("No chatrooms found")
                return
            }
            
            let dataDict = snapshot.value as! [String : AnyObject]
            
            var chats: [ChatRoomDetails] = []
            
            for (roomID, rec) in dataDict {
                if let chat = rec as? [String : AnyObject] {
                    let lastMessageDate = (nil != chat["lastMessageDate"]) ? self?.dateFormatter.dateFromString(chat["lastMessageDate"] as! String) : nil
                    var hasUnreadMessages = true
                    
                    if lastMessageDate != nil {
                        if let lastReadMessageDateStr = chat["lastReadMessageByCreatorDate"] as? String, let lastReadMessageDate = self?.dateFormatter.dateFromString(lastReadMessageDateStr) {
                            
                            hasUnreadMessages = lastReadMessageDate.compare(lastMessageDate!) == .OrderedAscending
                        }
                    }
                    
                    let chatDetails = ChatRoomDetails(roomID: roomID, creatorId: chat["createdBy"] as! String, interlocutorId: chat["interlocutor"] as! String, creatorName: chat["creatorName"] as! String, interlocutorName: chat["interlocutorName"] as! String, lastMessage: chat["lastMessage"] as? String, lastMessageDate: lastMessageDate, hasNewMessages: hasUnreadMessages)
                    
                    chats.append(chatDetails)
                }
            }
            
            sself.myRooms = chats
            sself.tableView.reloadData()
        }
        
        databaseHandlerList.append(DatabaseHandlerInfo(query: query, handlerId: databaseHandlerId))
    }
    
    func addOtherRoomsHandler() {
        // Listen for new messages in the Firebase database
        let currentUserID = (PFUser.currentUser()?.objectId)!
        showActivityIndicator()
        
        let query = databaseRef.child("chatrooms").queryOrderedByChild("interlocutor").queryEqualToValue(currentUserID)
        let databaseHandlerId = query.observeEventType(.Value) { [weak self] (snapshot: FIRDataSnapshot) in
            guard let sself = self else {
                return
            }

            sself.hideActivityIndicator()
            
            guard !(snapshot.value is NSNull) else {
                print("No chatrooms found")
                sself.otherRooms = [ChatRoomDetails]()
                sself.tableView.reloadData()
                return
            }
            
            let dataDict = snapshot.value as! [String : AnyObject]
            
            var chats: [ChatRoomDetails] = []
            
            for (roomID, rec) in dataDict {
                if let chat = rec as? [String : AnyObject] {
                    let lastMessageDate = (nil != chat["lastMessageDate"]) ? self?.dateFormatter.dateFromString(chat["lastMessageDate"] as! String) : nil
                    var hasUnreadMessages = true
                    
                    if lastMessageDate != nil {
                        if let lastReadMessageDateStr = chat["lastReadMessageByInterlocutorDate"] as? String, let lastReadMessageDate = self?.dateFormatter.dateFromString(lastReadMessageDateStr) {
                            
                            hasUnreadMessages = lastReadMessageDate.compare(lastMessageDate!) == .OrderedAscending
                        }
                    }
                    
                    let chatDetails = ChatRoomDetails(roomID: roomID, creatorId: chat["createdBy"] as! String, interlocutorId: chat["interlocutor"] as! String, creatorName: chat["creatorName"] as! String, interlocutorName: chat["interlocutorName"] as! String, lastMessage: chat["lastMessage"] as? String, lastMessageDate: lastMessageDate, hasNewMessages: hasUnreadMessages)
                    chats.append(chatDetails)
                }
            }
            sself.otherRooms = chats
            sself.tableView.reloadData()
        }

        databaseHandlerList.append(DatabaseHandlerInfo(query: query, handlerId: databaseHandlerId))
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kMessagesToChatSegue {
            let cell = sender as! ChatRoomTableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            let chatRoomDetails = self.chatRooms[indexPath.row]
            let destVC = segue.destinationViewController as! ChatViewController
            
            destVC.chatRoomId = chatRoomDetails.roomID
            destVC.title = cell.chatNameLabel.text
        }
    }

    // MARK: - UITableViewDataSourse
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatRoomDetails = chatRooms[indexPath.row]
        let chatRoomName = (chatRoomDetails.creatorId == PFUser.currentUser()!.objectId) ? chatRoomDetails.interlocutorName : chatRoomDetails.creatorName
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MessagingCell") as! ChatRoomTableViewCell
        cell.chatNameLabel.text = chatRoomName
        
        let query = PFUser.query()!
        query.whereKey("fullName", equalTo: chatRoomName)
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if let object = objects?.first {
                cell.chatNameLabel.text = object["fullName"] as? String
                
                if let picture = object["picture"] as? PFObject {
                    PictureManager().loadPicture(picture, inImageView: cell.profileImage)
                }
            }
            cell.indicateView.backgroundColor = (chatRoomDetails.hasNewMessages) ? UIColor.blueColor() : UIColor.whiteColor()
            cell.lastMessageLabel.text  = chatRoomDetails.lastMessage != nil ? chatRoomDetails.lastMessage : ""
            cell.updateTimeLabel.text = chatRoomDetails.lastMessageDate != nil ? self.dateFormatter.stringFromDate(chatRoomDetails.lastMessageDate!) : ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier(kMessagesToChatSegue, sender: cell)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let removeButton = UITableViewRowAction(style: .Normal, title: "Delete") {[weak self] action, indexPath in
            if let chatRoomDetails = self?.chatRooms[indexPath.row] {
                self?.databaseRef.child("chatrooms").child(chatRoomDetails.roomID).removeValueWithCompletionBlock({ (error, ref) in
                    if error != nil {
                        print("Failed to delete chat: ", error)
                        return
                    } else {
                        self?.addDatabaseHandlers()
                    }
                })
            }
            
        }
        removeButton.backgroundColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
        return [removeButton]
    }
}
