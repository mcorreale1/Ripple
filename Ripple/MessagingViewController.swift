//
//  MessagingViewController.swift
//  Ripple
//
//  Created by Apple on 07.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Photos
import UIKit
//import GoogleMobileAds


let KBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

struct ChatRoomDetails {
    let chat: MessagingSystem.Chat
    var lastMessage: String?
    var lastMessageDate: NSDate?
    var hasNewMessages: Bool
}

class MessagingViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate{
    
    let kMessagesToChatSegue = "messagesToChat"
    
    var users = [Users]()
    
    var channels = [ChatChannel]()
    
    var msglength: NSNumber = 10
    
    let showMessegesContactsId = "messegesContacts"
    let titleColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBar()
        prepareTableView()
        prepareData()
        
        UserManager().followingUsers(UserManager().currentUser()) { [weak self] (users) in
            self?.users = users
        }
    }
    
    // MARK: - Helpers
    
    private func prepareNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let contactsButton = UIBarButtonItem(image: UIImage(named: "messeges_contact_list"), style: .Plain, target: self, action: #selector(MessagingViewController.contactsTouched(_:)))
        contactsButton.tintColor = titleColor
        navigationItem.rightBarButtonItem = contactsButton
        navigationController?.navigationBar.tintColor = titleColor
    }
    
    private func prepareTableView() {
        let nibFollowingCell = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView.registerNib(nibFollowingCell, forCellReuseIdentifier: "MessagingCell")

    }
    
    private func prepareData() {
        showActivityIndicator()
        ChatChannel.loadAllChannels(UserManager().currentUser()) {[weak self] (channels) in
            self?.hideActivityIndicator()
            self?.channels = channels
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Internal operations
    
    func contactsTouched(sender: AnyObject) {
        performSegueWithIdentifier(showMessegesContactsId, sender: self)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kMessagesToChatSegue {
            let destinationVC = segue.destinationViewController as! ChatViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let channel = channels[indexPath.row]
                destinationVC.channel = channel
            }
        }
    }

    // MARK: - UITableViewDataSourse
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessagingCell") as! ChatRoomTableViewCell
        let channel = channels[indexPath.row]
        
        if let user = channel.userAddressee() {
            cell.chatNameLabel.text = user.getProperty("name") as? String
            
            if let picture = user.getProperty("picture") as? Pictures {
                PictureManager().loadPicture(picture, inImageView: cell.profileImage)
            }
        }
        
        cell.indicateView.hidden = true
        cell.lastMessageLabel.text = channel.lastMessage?.message
        cell.updateTimeLabel.text = channel.lastMessage?.created.formatDateWithFormat("dd MMM h:mm")
        
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
            if let channel = self?.channels[indexPath.row] {
                channel.delete({[weak self] (success) in
                    if success {
                        self?.prepareData()
                    }
                })
            }
        }
        removeButton.backgroundColor = UIColor.init(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
        
        return [removeButton]
    }
}
