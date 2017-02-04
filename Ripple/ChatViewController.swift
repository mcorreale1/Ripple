//
//  ChatViewController.swift
//  Ripple
//
//  Created by Apple on 09.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
//import GoogleMobileAds

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

class ChatViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var sentButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tabelView: UITableView!
    
    @IBOutlet weak var lyocBottomOffset: NSLayoutConstraint!
    
    var msglength: NSNumber = 100
    
    var user: Users?
    
    var channel = ChatChannel()
    var messages = [Dictionary<String, AnyObject>]()
    
    var alreadyLoadingMessages = false
    
    var timerLoadMessages: NSTimer?
    
    let sectionDayDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "MMMM d"
        
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelView.rowHeight = UITableViewAutomaticDimension
        tabelView.estimatedRowHeight = 96.0
        tabelView.registerNib(UINib(nibName: "CustomTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "dateHeaderView")
        prepareData()
        
        timerLoadMessages = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timerLoadMessages?.invalidate()
        timerLoadMessages = nil
    }
    
    private func prepareData() {
        showActivityIndicator()
        
        if channel.users?.count < 1 {
            title = user?.name
            
            ChatChannel().channelForUser(user!, completion: {[weak self] (channel) in
                self?.channel = channel
                
                if self?.channel.users?.count < 2 && self?.user != nil {
                    self?.channel.users = [(self?.user)!, UserManager().currentUser()]
                }
                
                if self?.channel.objectId != nil {
                    self?.loadMessages()
                } else {
                    self?.hideActivityIndicator()
                }
            })
        } else {
            title = channel.userAddressee()?.getProperty("name") as? String
            loadMessages()
        }
    }
    
    func loadMessages() {
        if alreadyLoadingMessages || channel.objectId == nil {
            return
        }
        
        alreadyLoadingMessages = true
        MessagesManager.sharedInstance.getMessages(channel) {[weak self] (messages) in
            self?.hideActivityIndicator()
            self?.alreadyLoadingMessages = false
            self?.hideActivityIndicator()
            self?.messages = messages
            self?.tabelView.reloadData()
            
            if let indexPath = self?.indexpathForLastRow() {
                self?.tabelView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
                
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= self.msglength.integerValue
    }
    
    func indexpathForLastRow() -> NSIndexPath? {
        let numberOfSections = tabelView.numberOfSections - 1
        
        if numberOfSections < 0 {
            return nil
        }
        
        let numberRows = tabelView.numberOfRowsInSection(numberOfSections) - 1
        
        return NSIndexPath(forRow: numberRows, inSection: numberOfSections)
    }
    
    // UITableViewDataSource protocol methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = messages[section]
        
        if let msgArr = sectionData["messages"] as? [ChatMessage] {
            return msgArr.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = messages[section]
        let date = sectionData["date"] as? NSDate ?? NSDate()
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("dateHeaderView") as! CustomTableHeaderView
        
        if NSCalendar.currentCalendar().isDateInToday(date) {
            headerView.titleHeader.text = "Today".localized()
        } else if NSCalendar.currentCalendar().isDateInYesterday(date) {
            headerView.titleHeader.text = "Yesterday".localized()
        } else {
            headerView.titleHeader?.text = sectionDayDateFormatter.stringFromDate(date)
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tabelView .dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as! ChatMessageCell
        let sectionData = messages[indexPath.section]
        
        guard let msgArr = sectionData["messages"] as? [ChatMessage] else {
            return cell
        }
        
        let message = msgArr[indexPath.row]
        cell.messageLabel.text = message.message ?? ""
        cell.isOwnMessage = message.ownerId == UserManager().currentUser().objectId
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutIfNeeded()
        cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let removeButton = UITableViewRowAction(style: .Normal, title: "Delete") {[weak self] action, indexPath in
            if let sectionData = self?.messages[indexPath.section] {
                guard let msgArr = sectionData["messages"] as? [ChatMessage] else {
                    return
                }
                
                let message = msgArr[indexPath.row]
                
                self?.showActivityIndicator()
                self?.tabelView.userInteractionEnabled = false
                
                message.delete({ (success) in
                    self?.prepareData()
                })
            }
        }
        removeButton.backgroundColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        return [removeButton]
    }
    
    func publishMessageAsPushNotificationSync(message: String, deviceId: String) -> MessageStatus? {
        if(deviceId == " ") {
            return nil
        }
        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-text":"You have receieved a new message from"])
        var error: Fault?
        let messageStatus = Backendless.sharedInstance().messaging.publish("default", message: message,publishOptions:publishOptions,deliveryOptions:deliveryOptions,error: &error)
        if error == nil {
            print("MessageStatus = \(messageStatus.status) ['\(messageStatus.messageId)']")
            return messageStatus
        }
        else {
            print("Server reported an error: \(error)")
            return nil
        }
    }
    
    // UITextViewDelegate protocol methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text != nil && textField.text!.characters.count > 0 {
            sendMessageServer()
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
    func sendMessageServer() {
        showActivityIndicator()
        
        MessagingSystem().send(textField.text, inChannel: channel, toUser: channel.userAddressee()) {[weak self] (channel, error) in
            if channel != nil {
                self?.channel = channel!
                self?.prepareData()
                if let deviceID = channel!.userAddressee()?.getProperty("deviceID") as? String {
                    let name = channel!.userAddressee()?.getProperty("name") as? String
                    self!.publishMessageAsPushNotificationSync(UserManager().currentUser().name! + " sent you a message", deviceId: deviceID)
                }
                
            }
        }
    }

    @IBAction func sendMessage(sender: UIButton) {
        textFieldShouldReturn(textField)
    }
    
    // MARK: - UIKeyboard handlers
    
    override func willShowKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
        lyocBottomOffset.constant = kbFrame.size.height
        
        let lastVisibleCellIndexPath = tabelView.indexPathsForVisibleRows?.last
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationOptionCurve), animations: { 
            self.view.layoutIfNeeded()
            }, completion: { [weak self] (success) in
                if let indexPath = lastVisibleCellIndexPath {
                    self?.tabelView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                }
        })
    }
    
    override func willHideKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
        lyocBottomOffset.constant = 0.0
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationOptionCurve), animations: { 
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
