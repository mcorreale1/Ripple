//
//  ChatViewController.swift
//  Ripple
//
//  Created by Apple on 09.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse

import Firebase
import FirebaseAuth
import GoogleMobileAds

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

class ChatViewController: BaseMessageViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var sentButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tabelView: UITableView!
    
    @IBOutlet weak var lyocBottomOffset: NSLayoutConstraint!
    
    var dateOrder: [NSDate] = []
    var messages: [NSDate : [[String : String]]]! = [:]
    var msglength: NSNumber = 100
    
    var chatRoomId: String!
    var user: PFUser?
    
    
    let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm:ss"
        
        return df
    }()
    
    let sectionDayDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "MMMM d"
        
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabelView.rowHeight = UITableViewAutomaticDimension
        self.tabelView.estimatedRowHeight = 96.0
        
        self.tabelView.registerNib(UINib(nibName: "CustomTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "dateHeaderView")
        
        loadAd()
        logViewLoaded()
        
        addDatabaseHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveLastReadMessageDate()
    }
    
    @IBAction func didPressCrash(sender: AnyObject) {
        fatalError()
    }
    
    func logViewLoaded() {
    }
    
    func loadAd() {
    }
    
    func addDatabaseHandlers() {
        if (self.chatRoomId != nil) {
            let query = databaseRef.child("messages").child(self.chatRoomId)
            let databaseHandlerId = query.observeEventType(.ChildAdded, withBlock: { [weak self] (snapshot) -> Void in
                guard let sself = self else {
                    return
                }

                var message = snapshot.value as! Dictionary<String, String>
                let keyMessage = snapshot.key
                message["id"] = keyMessage
                
                guard let dateStr = message[Constants.MessageFields.date] else {
                    return
                }
                
                let messageDate = sself.dateFormatter.dateFromString(dateStr) ?? NSDate()
                let messageDayDate = sself.dateWithoutTime(fromDate: messageDate)
                let shouldInsertSection: Bool = sself.messages[messageDayDate] == nil
                
                var messagesSection: [[String : String]] = sself.messages[messageDayDate] ?? []
                
                if shouldInsertSection {
                    sself.dateOrder.append(messageDayDate)
                    sself.dateOrder = sself.dateOrder.sort({ (date1, date2) -> Bool in
                        return date1.compare(date2) == NSComparisonResult.OrderedAscending
                    })
                }
                
                messagesSection.append(message)
                sself.messages[messageDayDate] = messagesSection
                
                let section = sself.dateOrder.indexOf(messageDayDate)!
                
                if shouldInsertSection {
                    sself.tabelView.insertSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
                } else {
                    sself.tabelView.insertRowsAtIndexPaths([NSIndexPath(forRow: messagesSection.count-1, inSection: section)], withRowAnimation: .Automatic)
                }
            })
            
            databaseHandlerList.append(DatabaseHandlerInfo(query: query, handlerId: databaseHandlerId))
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= self.msglength.integerValue // Bool
    }
    
    // UITableViewDataSource protocol methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateOrder.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDate = dateOrder[section]
        let msgArr = messages[sectionDate]!
        
        return msgArr.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDate = dateOrder[section]
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("dateHeaderView") as! CustomTableHeaderView
        
        if NSCalendar.currentCalendar().isDateInToday(sectionDate) {
            headerView.titleHeader.text = "Today".localized()
        } else if NSCalendar.currentCalendar().isDateInYesterday(sectionDate) {
            headerView.titleHeader.text = "Yesterday".localized()
        } else {
            headerView.titleHeader?.text = sectionDayDateFormatter.stringFromDate(sectionDate)
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tabelView .dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as! ChatMessageCell
        // Unpack message from Firebase DataSnapshot
        
        let sectionDate = dateOrder[indexPath.section]
        let message = messages[sectionDate]![indexPath.row]
        
        let name = message[Constants.MessageFields.name] as String!
        let text = message[Constants.MessageFields.text]
        
        cell.messageLabel.text = (text ?? "")
        cell.isOwnMessage = name == PFUser.currentUser()!.username!
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutIfNeeded()
        cell
    }
    
    func dateWithoutTime(fromDate date: NSDate) -> NSDate {
        let comps = NSCalendar.currentCalendar().componentsInTimeZone(NSTimeZone.localTimeZone(), fromDate: date)
        let extraSeconds = Double(((comps.hour * 60) + comps.minute) * 60 + comps.second)
        
        return date.dateByAddingTimeInterval(-extraSeconds)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let removeButton = UITableViewRowAction(style: .Normal, title: "Delete") {[weak self] action, indexPath in
            self?.showActivityIndicator()
            
            if let sectionDate = self?.dateOrder[indexPath.section] {
                let message = self?.messages[sectionDate]![indexPath.row]
                self?.tabelView.userInteractionEnabled = false
                
                if let messageId = message!["id"] {
                    self?.databaseRef.child("messages").child(self!.chatRoomId).child(messageId).removeValueWithCompletionBlock({(error, ref) in
                        self?.hideActivityIndicator()
                        self?.tabelView.userInteractionEnabled = true
                        
                        if error != nil {
                            print("Failed to delete message: ", error)
                            return
                        } else {
                            if var messgesArray = self?.messages[sectionDate] {
                                messgesArray.removeAtIndex(indexPath.row)
                                self?.messages[sectionDate] = messgesArray
                                self?.tabelView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                                
                            }
                            self?.updateLastMessageInRoom()
                        }
                    })
                }
            }
        }
        removeButton.backgroundColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        return [removeButton]
    }
    
    // UITextViewDelegate protocol methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text != nil && textField.text!.characters.count > 0 {
            let data = [Constants.MessageFields.text: textField.text! as String]
            sendMessageServer(data)
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
    func sendMessageServer(data: [String: String]) {
        var mdata = data
        let user = UserManager().currentUser()
        mdata[Constants.MessageFields.name] = user["username"] as? String
        
        if let photoUrl = AppState.sharedInstance.photoUrl {
            mdata[Constants.MessageFields.photoUrl] = photoUrl.absoluteString
        }
        
        let messageDate = dateFormatter.stringFromDate(NSDate())
        mdata["date"] = messageDate
        
        // Push data to Firebase Database
        databaseRef.child("messages").child(self.chatRoomId).childByAutoId().setValue(mdata)
        
        let chatRoom = databaseRef.child("chatrooms").child(self.chatRoomId)
        
        chatRoom.updateChildValues(["lastMessage" : data["text"]!, "lastMessageDate" : messageDate])
    }
    
    func saveLastReadMessageDate() {
        guard nil != messages else {
            return
        }
        
        let user = UserManager().currentUser()
        
        let chatRoom = databaseRef.child("chatrooms").child(self.chatRoomId)
        
        chatRoom.observeSingleEventOfType(.Value) { [weak self] (roomSnapshot: FIRDataSnapshot) in
            if let roomDetails = roomSnapshot.value as? [String : AnyObject] {
                let chatRoomCreatorId = roomDetails["createdBy"] as! String
                if let lastMessageDate = self?.dateFormatter.stringFromDate(NSDate()) {
                    if chatRoomCreatorId == user.objectId! {
                        chatRoom.updateChildValues(["lastReadMessageByCreatorDate" : lastMessageDate])
                    } else {
                        chatRoom.updateChildValues(["lastReadMessageByInterlocutorDate" : lastMessageDate])
                    }
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendMessage(sender: UIButton) {
        textFieldShouldReturn(textField)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - UIKeyboard handlers
    
    override func willShowKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
        lyocBottomOffset.constant = kbFrame.size.height - tabBarController!.tabBar.height
        
        let lastVisibleCellIndexPath = self.tabelView.indexPathsForVisibleRows?.last
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationOptionCurve), animations: { 
            self.view.layoutIfNeeded()
            }, completion: { [weak self] (success) in
                if let indexPath = lastVisibleCellIndexPath {
                    self!.tabelView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                }
        })
    }
    
    override func willHideKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
        lyocBottomOffset.constant = 0.0
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationOptionCurve), animations: { 
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK: - Helpers
    
    func updateLastMessageInRoom() {
        let sectionDate = dateOrder.last
        let chatRoom = databaseRef.child("chatrooms").child(self.chatRoomId)
        
        if let message = messages[sectionDate!]?.last {
            let date = message[Constants.MessageFields.date] ?? dateFormatter.stringFromDate(NSDate())
            let text = message[Constants.MessageFields.text] ?? ""
            chatRoom.updateChildValues(["lastMessage" : text, "lastMessageDate" : date])
        } else {
            chatRoom.updateChildValues(["lastMessage" : "", "lastMessageDate" : dateFormatter.stringFromDate(NSDate())])
        }
    }

}
