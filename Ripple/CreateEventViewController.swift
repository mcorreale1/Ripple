//
//  CreateEvent.swift
//  Ripple
//
//  Created by Adam Gluck on 1/16/16.
//  Copyright (c) 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import ORCommonUI_Swift
import Firebase
import ORLocalizationSystem
import UITextView_Placeholder
import ORCommonCode_Swift

class CreateEventViewController: BaseViewController, UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var layoutHeightEventDate: NSLayoutConstraint!
    @IBOutlet weak var layoutHeightEventTime: NSLayoutConstraint!
    
    @IBOutlet weak var layoutHeightEventDateEnd: NSLayoutConstraint!
    
    @IBOutlet weak var dataPickerEndEvent: UIDatePicker!
    @IBOutlet weak var datePickerDateEvent: UIDatePicker!
    @IBOutlet weak var labelDateEvent: UILabel!
    @IBOutlet weak var labelDateEventEnd: UILabel!
    
    @IBOutlet weak var datePickerStartTime: UIDatePicker!
    @IBOutlet weak var datePickerFinishTime: UIDatePicker!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    @IBOutlet weak var labelTimeEvent: UILabel!
    @IBOutlet weak var organizationNameLabel: UILabel!
    @IBOutlet weak var countGoingLabel: UILabel!
    
    @IBOutlet weak var uploadImageButton: UIButton!
    
    @IBOutlet weak var uploadImageLabel: UILabel!
    @IBOutlet weak var eventPictureImageView: ProfilePictureImageView!
    
    @IBOutlet weak var eventPriceLabel: UILabel!
    @IBOutlet weak var eventPrivacyLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    
    @IBOutlet weak var buttonChooseDate: UIButton!
    @IBOutlet weak var buttonChooseDateEnd: UIButton!
    @IBOutlet weak var buttonChooseTime: UIButton!
    @IBOutlet weak var buttonChooseAddress: UIButton!
    @IBOutlet weak var buttonChoosePrivacy: UIButton!
    @IBOutlet weak var buttonChoosePrice: UIButton!
    @IBOutlet weak var buttonSendInvitation: UIButton!
    
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var postPulsingButton: UIButton!
    @IBOutlet weak var heughtPostPulse: NSLayoutConstraint!
    @IBOutlet weak var hostedBy: UILabel!
    
    let warningColor = UIColor.init(red: 210/255, green: 36/255, blue: 22/255, alpha: 0.7)
    
    var organization: PFObject?
    var eventName = ""
    var dayEvent: NSDate?
    var dayEventEnd: NSDate?
    var startTime: NSDate?
    var finishTime: NSDate?
    var priceEvent = Float()
    var isPrivateEvent = true
    var eventAddress = ""
    var event: PFObject?
    var wereInvitationsSent = false
    
    let heightEventDateView: CGFloat = 180
    let maxLengthEventDescription = 251
    var lengthEventName = 40
    let maxHeightBottomBar: CGFloat = 126
    let minHeightBottomBar: CGFloat = 38
    let defaultEventDescirption = NSLocalizedString("You can write a description up to 250 characters.", comment: "You can write a description up to 250 characters.")
    
    var bottomBarStartDragging = false
    
    var titleMessage :String = ""
    var message :String = ""

    var eventCreating = false
    
    deinit {
        or_removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        or_addObserver(self, selector: #selector(onEventSendInvitationsNotification), name: PulseNotification.PulseNotificationEventSendInvitations.rawValue)
        
        eventDescriptionTextView.delegate = self
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(CreateEventViewController.editNameTouched(_:)))
        navigationItem.rightBarButtonItem = editButton
         self.organizationNameLabel.text = organization!["name"] as? String
        
        if event?["name"] != nil {
            uploadImageButton.enabled = false
            buttonChooseDate.enabled = false
            buttonChooseDateEnd.enabled = false
            buttonChooseTime.enabled = false
            buttonChoosePrivacy.enabled = false
            buttonChoosePrice.enabled = false
            eventDescriptionTextView.editable = false
            eventName = event!["name"] as! String
            startTime =  event!["startDate"] as? NSDate
            finishTime = event!["endDate"] as? NSDate
            title = event!["name"] as? String
            priceEvent = NSString(string: eventPriceLabel.text!).floatValue
            dayEvent = event!["startDate"] as? NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE\nLLLL, dd"
            self.labelDateEvent.text = dateFormatter.stringFromDate(event!["startDate"] as! NSDate)
            self.labelDateEventEnd.text = dateFormatter.stringFromDate(event!["endDate"] as! NSDate)
            dayEventEnd = dataPickerEndEvent.date
            dayEvent = dataPickerEndEvent.date
    
            if let organization = event?["organization"] as? PFObject {
                organization.fetchInBackgroundWithBlock({ (result, error) in
                    if(error == nil) {
                        self.organizationNameLabel.text = organization["name"] as? String
                    } else {
                        print(error)
                    }
                })
            } else {
                organizationNameLabel.text = ""
            }

            self.eventDescriptionTextView.text = event!["description"] as? String
            self.labelTimeEvent.text = startTime!.formatEventTime() + "-" + finishTime!.formatEventTime()
            uploadImageLabel.hidden = true
            self.eventPriceLabel.text = "$" + String(event!["cost"])
            let isPrivateEvent = event!["isPrivate"] as? Bool
            if isPrivateEvent == true {
                self.eventPrivacyLabel.text = NSLocalizedString("Private event", comment: "Private event")
                self.isPrivateEvent = true
            }
            else {
                 self.eventPrivacyLabel.text = NSLocalizedString("Public event", comment: "Public event")
                self.isPrivateEvent = false
            }
            
            let picture = event!["picture"] as? PFObject
            PictureManager().loadPicture(picture, inButton: uploadImageButton)
            uploadImageButton.layer.cornerRadius = uploadImageButton.frame.width / 2
            uploadImageButton.layer.masksToBounds = true

            PictureManager().loadPicture(picture, inImageView: eventPictureImageView)
            eventPictureImageView.layer.cornerRadius = eventPictureImageView.frame.width / 2
            eventPictureImageView.layer.masksToBounds = true
            eventAddressLabel.text = event!["address"] as? String
            eventAddress = eventAddressLabel.text!
            hostedBy.text = NSLocalizedString("Hosted by", comment: "Hosted by")
            if PulseNotification.PulseNotificationIsEveentCreate.rawValue != "" && isPrivateEvent == false {
                self.checkMarkImageView.hidden = false
            }
        }
        else {
            title = NSLocalizedString("Event Name", comment: "Event Name")
            labelDateEvent.text = NSLocalizedString("Choose a Start Date", comment: "Choose a Start Date")
            labelDateEventEnd.text = NSLocalizedString("Choose an End Date", comment: "Choose an End Date")
            let eventDescriptionText = "You can write a description up to 250 characters."
            eventDescriptionTextView.placeholder = NSLocalizedString(eventDescriptionText, comment: eventDescriptionText)
            eventDescriptionTextView.placeholderColor = UIColor.lightGrayColor()
            labelTimeEvent.text = NSLocalizedString("Choose a Time", comment: "Choose a Time")
            uploadImageLabel.text = NSLocalizedString("Upload Image", comment: "Upload Image")
            eventPriceLabel.text = NSLocalizedString("Choose Price", comment: "Choose Price")
            eventPrivacyLabel.text = NSLocalizedString("Choose Privacy", comment: "Choose Privacy")
            eventAddressLabel.text = NSLocalizedString("Choose an Address", comment: "Choose an Address")
            hostedBy.text = NSLocalizedString("Hosted by", comment: "Hosted by")
        }
        
        scrollView.or_enableKeyboardInsetHandling()
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        view.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if wereInvitationsSent {
            wereInvitationsSent = false
            titleMessage = NSLocalizedString("Success", comment: "Success")
            message = NSLocalizedString("You successfully sent invitation(s) to your Event", comment: "You successfully sent invitation(s) to your Event")
            let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            titleMessage = NSLocalizedString("OK", comment: "OK")
            alertController.addAction(UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonSendInvitation.enabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    func emptyFields() -> Bool {
        var emptyFields = false
        if eventName == "" {
            emptyFields = true
        }
        if dayEvent == nil {
            emptyFields = true
            buttonChooseDate.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseDate.backgroundColor = UIColor.clearColor()
            })
        }
        
        if dayEventEnd == nil {
            emptyFields = true
            buttonChooseDateEnd.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseDateEnd.backgroundColor = UIColor.clearColor()
            })
        }
        if (dayEvent?.timeIntervalSince1970 > dayEventEnd?.timeIntervalSince1970) {
            emptyFields = true
            buttonChooseDate.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseDate.backgroundColor = UIColor.clearColor()
            })
            emptyFields = true
            buttonChooseDateEnd.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseDateEnd.backgroundColor = UIColor.clearColor()
            })

        }
        
        if(dayEvent?.timeIntervalSince1970 == dayEventEnd?.timeIntervalSince1970){
            if (startTime != nil && finishTime != nil){
                if (( startTime!.earlierDate(finishTime!)) ==  finishTime){
                    emptyFields = true
                    buttonChooseTime.backgroundColor = warningColor
                    UIView.animateWithDuration(0.35, animations: {
                        self.buttonChooseTime.backgroundColor = UIColor.clearColor()
                    })
                }
            } else { emptyFields = true }
        }
        
        if startTime == nil || finishTime == nil {
            emptyFields = true
            buttonChooseTime.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseTime.backgroundColor = UIColor.clearColor()
            })
        }
        if eventDescriptionTextView.text == defaultEventDescirption {
            emptyFields = true
            eventDescriptionTextView.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.eventDescriptionTextView.backgroundColor = UIColor.clearColor()
            })
        }
        if eventAddressLabel.text == "Choose an Address" {
            emptyFields = true
            buttonChooseAddress.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChooseAddress.backgroundColor = UIColor.clearColor()
            })
        }
        if eventPrivacyLabel.text == "Choose Privacy" {
            emptyFields = true
            buttonChoosePrivacy.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChoosePrivacy.backgroundColor = UIColor.clearColor()
            })
        }
        if eventPriceLabel.text == "Choose Price" {
            emptyFields = true
            buttonChoosePrice.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.buttonChoosePrice.backgroundColor = UIColor.clearColor()
            })
        }
        if eventPictureImageView.image == nil {
            emptyFields = true
            eventPictureImageView.backgroundColor = warningColor
            UIView.animateWithDuration(0.35, animations: {
                self.eventPictureImageView.backgroundColor = UIColor.whiteColor()
            })
        }
        if emptyFields == true {
            self.titleMessage = NSLocalizedString("Error", comment: "Error")
            self.message = NSLocalizedString("The event was not created. Please, fill in all the fields", comment: "The event was not created. Please, fill in all the fields")
            self.showAlert(self.titleMessage, message: self.message)
        }
        return emptyFields
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == defaultEventDescirption {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = defaultEventDescirption
            textView.textColor = UIColor.lightGrayColor()
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let sumLength = text.characters.count + textView.text.characters.count
        return sumLength < maxLengthEventDescription || text.characters.count < 1
    }
    
    func textViewDidChange(textView: UITextView) {
        // scroll to textview's cursor if needed
//        textView.scrollRangeToVisible(textView.selectedRange)
        guard let selectedTextRange = textView.selectedTextRange else {
            return
        }
        let caretRect = textView.caretRectForPosition(selectedTextRange.end)
        let convertedCaretRect = scrollView.convertRect(caretRect, fromView: textView)
        
        scrollView.scrollRectToVisible(CGRect(x: convertedCaretRect.origin.x, y: convertedCaretRect.origin.y, width: convertedCaretRect.width, height: convertedCaretRect.height + 20), animated: false)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        eventDescriptionTextView.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            let separator = NSNumberFormatter().decimalSeparator ?? "."
            if textField.text?.rangeOfString(separator) != nil && string == separator {
                return false
            }
            lengthEventName = 7
        }
        else {
            lengthEventName = 46
        }
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength < lengthEventName
        
        //return sumLength < lengthEventName || string.characters.count < 1
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { [weak self] in
            let mediaItem = info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]
            
            guard let image: UIImage = mediaItem as? UIImage else {
                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                self!.message = NSLocalizedString("Image is lost", comment: "Image is lost")
                self!.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
                return;
            }
            
            self!.showImageEditScreen(withImage: image, frameType: .Circle, maxSize: CGSize(width: 320.0, height: 320.0))
        }
        uploadImageLabel.hidden = true
    }
    
    // ORCropImageControllerDelegate
    
    override func cropVCDidFinishCrop(withImage image: UIImage?) {
        guard let img = image else {
            titleMessage = NSLocalizedString("Fail", comment: "Fail")
            message = NSLocalizedString("Failed to crop image!", comment: "Failed to crop image!")
            showAlert("Fail".localized(), message: "Failed to crop image!".localized())
            return
        }
        
        refreshAvatarImage(withImage: img)
    }

    
    // MARK: - Actions
    
    @IBAction func showEventDayViewTouched(sender: AnyObject) {
        hideKeyboard()
        layoutHeightEventDate.constant = layoutHeightEventDate.constant == heightEventDateView ? 0 : heightEventDateView
        UIView.animateWithDuration(0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func showEventDayEndViewTouched(sender: AnyObject) {
        hideKeyboard()
        layoutHeightEventDateEnd.constant = layoutHeightEventDateEnd.constant == heightEventDateView ? 0 : heightEventDateView
        UIView.animateWithDuration(0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveEventDayTouched(sender: AnyObject) {
        hideKeyboard()
        let currentDate: NSDate = NSDate()
        showEventDayViewTouched(sender)
        let compareDate = NSCalendar.currentCalendar().compareDate( datePickerDateEvent.date, toDate: currentDate,
                                                             toUnitGranularity: .Day)
        
        if (compareDate == .OrderedDescending) || (compareDate == .OrderedSame) {
            dayEvent = datePickerDateEvent.date
            labelDateEvent.text = datePickerDateEvent.date.formatEventDay()
        }
        else {
            titleMessage = NSLocalizedString("Please, choose another date for this event", comment: "Please, choose another date for this event")
            message = NSLocalizedString("Selected date must be after the current date", comment: "Selected date must be after the current date")
            self.showAlert(titleMessage, message: message)
        }
    }
    
    @IBAction func saveEventDayEndTouched(sender: AnyObject) {
        hideKeyboard()
        let currentDate: NSDate = NSDate()
        showEventDayEndViewTouched(sender)
        let compareDate = NSCalendar.currentCalendar().compareDate( dataPickerEndEvent.date, toDate: currentDate,
                                                                    toUnitGranularity: .Day)
        
        if (compareDate == .OrderedDescending) || (compareDate == .OrderedSame) {
            dayEventEnd = dataPickerEndEvent.date
            labelDateEventEnd.text = dataPickerEndEvent.date.formatEventDay()
        }
        else {
            titleMessage = NSLocalizedString("Please, choose another date for this event", comment: "Please, choose another date for this event")
            message = NSLocalizedString("Selected date must be after the current date", comment: "Selected date must be after the current date")
            self.showAlert(titleMessage, message: message)
        }
        
    }
    @IBAction func showEventTimeTouched(sender: AnyObject) {
        hideKeyboard()
        layoutHeightEventTime.constant = layoutHeightEventTime.constant == heightEventDateView ? 0 : heightEventDateView
        UIView.animateWithDuration(0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveEventTimeTouched(sender: AnyObject) {
        hideKeyboard()
        showEventTimeTouched(sender)
        startTime = datePickerStartTime.date
        finishTime = datePickerFinishTime.date
        if (( startTime!.earlierDate(finishTime!)) !=  finishTime)||(dayEvent?.timeIntervalSince1970 != dayEventEnd?.timeIntervalSince1970) {
            labelTimeEvent.text = startTime!.formatEventTime() + "-" + finishTime!.formatEventTime()
        }
        else{
            titleMessage = NSLocalizedString("Please, choose a valid period of time for this event.", comment: "Please, choose a valid period of time for this event.")
            self.showAlert(titleMessage, message: "")
        }
    }
    
    @IBAction func chooseAddressTouched(sender: AnyObject) {
        if (buttonChooseDate.enabled == false) {
                var titleMessage = NSLocalizedString("Address", comment: "Address")
                let message = NSLocalizedString("Would you like to see it on map?", comment: "Would you like to see it on map?")
                let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
                titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
                let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in }
                titleMessage = NSLocalizedString("OK", comment: "OK")
                let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
                    if self == nil {
                        return
                    }
                    self?.showAddressViewController(self!.event!)
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            hideKeyboard()
            titleMessage = NSLocalizedString("Address", comment: "Address")
            message = NSLocalizedString("Please, choose event address", comment: "Please, choose address")
            let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
                textField.placeholder = NSLocalizedString("Address", comment: "Address")
                textField.tag = 2
                textField.delegate = self
            }
            
            titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
            let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in }
            
            titleMessage = NSLocalizedString("OK", comment: "OK")
            let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
                if self == nil {
                    return
                }
                let length = 17
                var eventAddressString =  alertController.textFields?.first?.text
                if  eventAddressString!.characters.count > length {
                    eventAddressString = eventAddressString!.substringToIndex(eventAddressString!.startIndex.advancedBy(length)) + "..."
                }
                if eventAddressString!.isEmpty {
                    self!.eventAddressLabel.text = "Choose an Address"
                    self!.eventAddress = "Choose an Address"

                }
            
                else {
                    self!.eventAddressLabel.text = eventAddressString
                    self!.eventAddress = (alertController.textFields?.first?.text)!
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func choosePrivacyTouched(sender: AnyObject) {
        hideKeyboard()
        titleMessage = NSLocalizedString("Privacy", comment: "Privacy")
        message = NSLocalizedString("Please, select type privacy", comment: "Please, select type privacy")
        let actionController = UIAlertController(title: titleMessage, message: message, preferredStyle: .ActionSheet)
        titleMessage = NSLocalizedString("Public", comment: "Public")
        let publicAction = UIAlertAction(title: titleMessage, style: .Default, handler: {[weak self] (alert: UIAlertAction) -> Void in
            self?.isPrivateEvent = false
            self?.eventPrivacyLabel.text = NSLocalizedString("Public event", comment: "Public event")
        })
        titleMessage = NSLocalizedString("Private", comment: "Private")
        let privateAction = UIAlertAction(title: titleMessage, style: .Default, handler: {[weak self] (alert: UIAlertAction) -> Void in
            self?.isPrivateEvent = true
            self?.checkMarkImageView.hidden = true
            self?.eventPrivacyLabel.text = NSLocalizedString("Private event", comment: "Private event")
        })
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: titleMessage, style: .Cancel, handler: { (alert: UIAlertAction!) -> Void in })
        actionController.addAction(publicAction)
        actionController.addAction(privateAction)
        actionController.addAction(cancelAction)
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    @IBAction func choosePriceTouched(sender: AnyObject) {
        hideKeyboard()
        titleMessage = NSLocalizedString("Price", comment: "Price")
        message = NSLocalizedString("Please, enter event price", comment: "Please, enter event price")
        let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Price", comment: "Price")
            textField.keyboardType = .DecimalPad
            textField.tag = 1
            textField.delegate = self
        }
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in }
        titleMessage = NSLocalizedString("OK", comment: "OK")
        let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
            if self == nil {
                return
            }
            if let textPrice = alertController.textFields?.first?.text {
                let formatter = NSNumberFormatter()
                formatter.locale = NSLocale.currentLocale()
                formatter.numberStyle = .DecimalStyle
                //let price = NSString(string: textPrice).floatValue
                if let price = formatter.numberFromString(textPrice) {
                    let tmp = Int(price.floatValue * 10)
                    self?.priceEvent = Float(tmp) / 10
                    self?.eventPriceLabel.text = "$" + "\(Float(tmp) / 10)"
                } else {
                    self?.choosePriceTouched(self!)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func uploadImageTouched(sender: AnyObject) {
        hideKeyboard()
        message = NSLocalizedString("Select image source", comment: "Select image source")
        let actionSheetOptions = UIAlertController(title: nil, message: message.localized(), preferredStyle: .ActionSheet)
        
        
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            titleMessage = NSLocalizedString("Camera", comment: "Camera")
            actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
                self!.showImagePicker(withSourceType: .Camera)
                })
        }
        
        titleMessage = NSLocalizedString("Album", comment: "Album")
        actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
            self!.showImagePicker(withSourceType: .SavedPhotosAlbum)
            })
        
        titleMessage = NSLocalizedString("Library", comment: "Library")
        actionSheetOptions.addAction(withTitle: titleMessage.localized(), handler: { [weak self] (action) in
            self!.showImagePicker(withSourceType: .PhotoLibrary)
            })
        
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        actionSheetOptions.addCancelAction(withTitle: titleMessage)
        self.presentViewController(actionSheetOptions, animated: true, completion: nil)
    }
    
    func editNameTouched(sender: AnyObject) {
        uploadImageButton.enabled = true
        buttonChooseDate.enabled = true
        buttonChooseDateEnd.enabled = true
        buttonChooseTime.enabled = true
        buttonChooseAddress.enabled = true
        buttonChoosePrivacy.enabled = true
        buttonChoosePrice.enabled = true
        eventDescriptionTextView.editable = true
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneNameTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton
        
        titleMessage = NSLocalizedString("Event Name", comment: "Event Name")
        message = NSLocalizedString("Please, write the event name", comment: "Please, write the event name")
        let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Event Name", comment: "Event Name")
            textField.delegate = self
        }
        
        titleMessage = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in}
        
        titleMessage = NSLocalizedString("OK", comment: "OK")
        let okAction = UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default) {[weak self] (result : UIAlertAction) -> Void in
            self?.eventName = (alertController.textFields?.first?.text)!
            self?.title = self?.eventName
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func doneNameTouched(sender: AnyObject) {
        uploadImageButton.enabled = false
        buttonChooseDate.enabled = false
        buttonChooseDateEnd.enabled = false
        buttonChooseTime.enabled = false
        buttonChooseAddress.enabled = false
        buttonChoosePrivacy.enabled = false
        buttonChoosePrice.enabled = false
        eventDescriptionTextView.editable = false
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editNameTouched(_:)))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.enabled = false
        
        if (emptyFields() == false) {
            showActivityIndicator()
            var coordinate = CLLocationCoordinate2DMake(0, 0)
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(eventAddress) { (placemarks: [CLPlacemark]?, error: NSError?) in
                if error != nil {
                    print("Error, \(error?.description)")
                    coordinate = CLLocationCoordinate2DMake(0, 0)
                } else {
                    coordinate.latitude = (placemarks?.first?.location?.coordinate.latitude)!
                    coordinate.longitude = (placemarks?.first?.location?.coordinate.longitude)!
                }
                if coordinate.latitude == 0 || coordinate.longitude == 0 {
                    self.titleMessage = NSLocalizedString("Error", comment: "Error")
                    self.message = NSLocalizedString("The address can not be found.", comment: "The event was not created. The address can not be found.")
                    self.showAlert((self.titleMessage), message: (self.message))
                    self.hideActivityIndicator()
                } else {
                    if self.event == nil {
                        self.postPulsingButton.enabled = false
                        let newEvent = PFObject(className: "Events")
                        if self.eventCreating {
                            return
                        }
                        
                        self.eventCreating = true
                        EventManager().createEvent(self.organization!, event: newEvent, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, picture: self.eventPictureImageView.image!, description: self.eventDescriptionTextView.text, address: self.eventAddress, coordinate: coordinate) {[weak self] (success, event) in
                            self?.eventCreating = false
                            
                            if success {
                                self?.event = newEvent
                            }
                            self?.hideActivityIndicator()
                            self?.postPulsingButton.enabled = true
                        }
                    } else {
                        if self.eventCreating {
                            return
                        }
                        
                        self.eventCreating = true
                        self.postPulsingButton.enabled = false
                        EventManager().createEvent(self.organization!, event: self.event!, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, picture: self.eventPictureImageView.image!, description: self.eventDescriptionTextView.text, address: self.eventAddress, coordinate: coordinate) {[weak self] (success, event) in
                            self?.eventCreating = false
                            self?.hideActivityIndicator()
                            self?.postPulsingButton.enabled = true
                        }
                    }
                }
            }

        }
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.view.endEditing(true)
    }
    
    @IBAction func postToWhatsPulsingTouched(sender: AnyObject) {
        if emptyFields() == false {
            postPulsingButton.enabled = false
            
            if isPrivateEvent {
                titleMessage = NSLocalizedString("Error", comment: "Error")
                message = NSLocalizedString("You can not post private events", comment: "You can not post private events")
                let alertController = UIAlertController(title: titleMessage, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                titleMessage = NSLocalizedString("OK", comment: "OK")
                alertController.addAction(UIAlertAction(title: titleMessage, style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                self.postPulsingButton.enabled = true
            } else {
                postPulsingButton.enabled = false
                showActivityIndicator()
                var coordinate = CLLocationCoordinate2DMake(0, 0)
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(eventAddress) {[weak self] (placemarks: [CLPlacemark]?, error: NSError?) in
                    if error != nil {
                        print("Error, \(error?.description)")
                        coordinate = CLLocationCoordinate2DMake(0, 0)
                    } else {
                        coordinate.latitude = (placemarks?.first?.location?.coordinate.latitude)!
                        coordinate.longitude = (placemarks?.first?.location?.coordinate.longitude)!
                    }
                    
                    if coordinate.latitude == 0 || coordinate.longitude == 0 {
                        self?.hideActivityIndicator()
                        self?.titleMessage = NSLocalizedString("Error", comment: "Error")
                        self?.message = NSLocalizedString("The address can not be found.", comment: "The event was not created. The address can not be found.")
                        self?.showAlert((self?.titleMessage), message: (self?.message))
                        self?.postPulsingButton.enabled = true
                    } else {
                        if self?.event != nil {
                            
                            if self?.isPrivateEvent == false {
                                self?.checkMarkImageView.hidden = false
                            }
                                
                            or_postNotification(PulseNotification.PulseNotificationIsEveentCreate.rawValue)
                            self?.postPulsingButton.enabled = true
                        } else {
                            self?.postPulsingButton.enabled = false
                            self?.createNewEvent({ (success) in
                                self?.postPulsingButton.enabled = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendInvitationsTouched(sender: AnyObject) {
        buttonSendInvitation.enabled = false
        if event != nil {
            //self.createNewEvent({ (success) in
                self.showInviteUsersViewController(nil, event: self.event)
            //})
        } else if emptyFields() == false {
            createNewEvent({[weak self] (success) in
                if success {
                    self?.showInviteUsersViewController(nil, event: self?.event)
                }
            })
        }
    }
    
    //MARK: - Notifications
    
    func onEventSendInvitationsNotification() {
        wereInvitationsSent = true
    }
    
    //MARK: -
    
    func hideKeyboard() {
        view.endEditing(true)
    }

    //MARK: -
    
    func createNewEvent(completion: (success: Bool) -> Void) {
        showActivityIndicator()
        var coordinate = CLLocationCoordinate2DMake(0, 0)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(eventAddress) { (placemarks: [CLPlacemark]?, error: NSError?) in
            if error != nil {
                print("Error, \(error?.description)")
                coordinate = CLLocationCoordinate2DMake(0, 0)
            } else {
                coordinate.latitude = (placemarks?.first?.location?.coordinate.latitude)!
                coordinate.longitude = (placemarks?.first?.location?.coordinate.longitude)!
            }
            
            if coordinate.latitude == 0 || coordinate.longitude == 0 {
                self.titleMessage = NSLocalizedString("Error", comment: "Error")
                self.message = NSLocalizedString("The address can not be found.", comment: "The event was not created. The address can not be found.")
                self.showAlert((self.titleMessage), message: (self.message))
                self.hideActivityIndicator()
            } else {
                let newEvent = PFObject(className: "Events")
                
                if self.eventCreating {
                    return
                }
                self.eventCreating = true
                EventManager().createEvent(self.organization!, event: newEvent, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, picture: self.eventPictureImageView.image!, description: self.eventDescriptionTextView.text, address: self.eventAddress, coordinate: coordinate) {[weak self] (success, event) in
                    self?.hideActivityIndicator()
                    self?.eventCreating = false
                    
                    if success {
                        if (self?.isPrivateEvent == false) {
                            self?.checkMarkImageView.hidden = false
                        }
                        
                        self?.event = event
                        or_postNotification(PulseNotification.PulseNotificationIsEveentCreate.rawValue)
                        completion(success: true)
                    } else {
                        self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                        self!.message = NSLocalizedString("The event was not created. Please, try again later", comment: "The event was not created. Please, try again later")
                        self?.showAlert(self?.titleMessage, message: self?.message)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper
    
    func forwardGeocoding (address: String, completion: (CLLocationCoordinate2D) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if placemarks!.count > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    let location = placemark.location
                    completion(location!.coordinate)
                }
            }
        }
    }
    // MARK: - Internal operations
    
    func updateAvatar(withNewAvatarURL avatarURL: NSURL, storagePath: String, completion: ((updated: Bool, error: NSError?) -> Void)?) {
        let picture = PFObject(className: "Pictures")
        picture["imageURL"] = avatarURL.absoluteString
        
        picture.saveInBackgroundWithBlock { (saved, error) in
            if (error != nil) {
                return
            }
        }
    }
    
    func refreshAvatarImage(withImage image: UIImage) {
        self.eventPictureImageView.image = image
    }
}
