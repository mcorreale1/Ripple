//
//  CreateEvent.swift
//  Ripple
//
//  Created by Adam Gluck on 1/16/16.
//  Copyright (c) 2016 Adam Gluck. All rights reserved.
//


//layouheighteventdate,dateend,time


import UIKit
import ORCommonUI_Swift
import ORLocalizationSystem
import UITextView_Placeholder
import ORCommonCode_Swift

protocol CreateEventViewDelegate {
    func writeBackEventLocation(latitude: Double,  longitude:Double, location:String)
}

class CreateEventViewController: BaseViewController, UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, CreateEventViewDelegate {

    @IBOutlet weak var eventPrivacy: UISwitch!
    @IBOutlet weak var isFreeSwitch: UISwitch!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var priceOfEvent: UITextField!
    @IBOutlet weak var datePickerDateEvent: UIDatePicker!
    @IBOutlet weak var datePickerStartTime: UIDatePicker!
    @IBOutlet weak var datePickerFinishTime: UIDatePicker!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var buttonSendInvitation: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
   // @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var postPulsingButton: UIBarButtonItem!
    //@IBOutlet weak var heughtPostPulse: NSLayoutConstraint!
   // @IBOutlet weak var hostedBy: UILabel!
    
    @IBOutlet weak var addressButton: UIButton!
    let warningColor = UIColor.init(red: 210/255, green: 36/255, blue: 22/255, alpha: 0.7)
    
    var organization: Organizations?
    var eventName = ""
    var dayEvent: NSDate?
    var dayEventEnd: NSDate?
    var startTime: NSDate?
    var finishTime: NSDate?
    var priceEvent = Double()
    var isPrivateEvent = true
    var eventAddress = ""
    var coordinate:CLLocationCoordinate2D!
    var event: RippleEvent?
    var wereInvitationsSent = false
    var zero = 0.0
    var location = ""
    var address = ""
    var city = ""
    
    
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
        eventPrivacy.on = true
        isFreeSwitch.on = true
        or_addObserver(self, selector: #selector(onEventSendInvitationsNotification), name: PulseNotification.PulseNotificationEventSendInvitations.rawValue)
        eventDescriptionTextView.delegate = self
//        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(CreateEventViewController.editNameTouched(_:)))
//        navigationItem.rightBarButtonItem = editButton
       // self.organizationNameLabel.text = organization!.name
        if event?.name != nil {
            //uploadImageButton.enabled = false
//            buttonChooseDate.enabled = false
//            buttonChooseDateEnd.enabled = false
//            buttonChooseTime.enabled = false
//            buttonChoosePrivacy.enabled = false
//            buttonChoosePrice.enabled = false
            //eventDescriptionTextView.isEditable = false
            eventName = event!.name!
            startTime =  event!.startDate
            finishTime = event!.endDate
            title = event!.name!
            priceEvent = event!.cost
            dayEvent = startTime
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE\nLLLL, dd"
            //self.labelDateEvent.text = dateFormatter.stringFromDate(startTime!)
           // self.labelDateEventEnd.text = dateFormatter.stringFromDate(finishTime!)
           // self.organizationNameLabel.text = event?.organization?.name ?? ""

            self.eventDescriptionTextView.text = event!.descr
//            self.labelTimeEvent.text = startTime!.formatEventTime() + "-" + finishTime!.formatEventTime()
//            //uploadImageLabel.hidden = true
//            self.eventPriceLabel.text = "$" + String(event!.cost)
            
//            if event!.isPrivate == true {
//                self.eventPrivacyLabel.text = NSLocalizedString("Private event", comment: "Private event")
//                self.isPrivateEvent = true
//            } else {
//                self.eventPrivacyLabel.text = NSLocalizedString("Public event", comment: "Public event")
//                self.isPrivateEvent = false
//            }
            
//            PictureManager().loadPicture(event!.picture, inImageView: eventPictureImageView)
//            eventPictureImageView.layer.cornerRadius = eventPictureImageView.frame.width / 2
//            eventPictureImageView.layer.masksToBounds = true
            
//            eventAddressLabel.text = event!.address
//            eventAddress = eventAddressLabel.text!
            //hostedBy.text = NSLocalizedString("Hosted by", comment: "Hosted by")
            if PulseNotification.PulseNotificationIsEventCreate.rawValue != "" && isPrivateEvent == false {
               // checkMarkImageView.hidden = false
                postPulsingButton.enabled = false
            }
        } else {
            title = NSLocalizedString("Event Name", comment: "Event Name")
            let eventDescriptionText = "You can write a description up to 250 characters."
            eventDescriptionTextView.placeholder = NSLocalizedString(eventDescriptionText, comment: eventDescriptionText)
            
        }
        
        //scrollView.or_enableKeyboardInsetHandling()
        
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
        eventPrivacy.on = false
        buttonSendInvitation.enabled = true
    }
    
    @IBAction func addressButtonClicked(sender: AnyObject) {
        let chooseAddressView = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseAddressViewController") as! ChooseAddressViewController
        chooseAddressView.event = self.event
        chooseAddressView.createEventDelegate = self
        self.navigationController?.pushViewController(chooseAddressView, animated: true)
        print("Returned to createEvent")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    func postEmptyFieldMessage(message:String, comment:String) {
        self.titleMessage = NSLocalizedString("Error Creating Event", comment: "Error")
        self.message = NSLocalizedString(message, comment: comment)
        self.showAlert(self.titleMessage, message: self.message)
    }
    
    
    @IBAction func isEventFree(sender: AnyObject) {
        if isFreeSwitch.on == true
        {
            priceOfEvent.hidden = true
        }
        else
        {
            priceOfEvent.hidden = false
        }
    }
    @IBAction func isPrivateEvent(sender: AnyObject) {
        if eventPrivacy.on == true
        {
            event?.isPrivate = true
        }
        else
        {
            event?.isPrivate = false
        }
    }
    @IBAction func priceOfEventTouched(sender: AnyObject) {
        
        let formatter = NSNumberFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.numberStyle = .DecimalStyle
        if let price = formatter.numberFromString(priceOfEvent.text!)
        {
            let tmp = Int(price.floatValue * 10)
            self.priceEvent = Double(tmp) / 10
            //self.eventPriceLabel.text = "$" + "\(Float(tmp) / 10)"
            event?.cost = priceEvent
        }
        else
        {
            event?.cost = zero
        }
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
        //should this be saved there
        if self.eventNameTextField.text != ""
        {
           self.eventName = self.eventNameTextField.text!
        }
        if self.eventDescriptionTextView.text != ""
        {
             event!.descr = self.eventDescriptionTextView.text
        }

              return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let sumLength = text.characters.count + textView.text.characters.count
        return sumLength < maxLengthEventDescription || text.characters.count < 1
    }
    
//    func textViewDidChange(textView: UITextView) {
//        // scroll to textview's cursor if needed
////        textView.scrollRangeToVisible(textView.selectedRange)
//        guard let selectedTextRange = textView.selectedTextRange else {
//            return
//        }
//        let caretRect = textView.caretRectForPosition(selectedTextRange.end)
//       // let convertedCaretRect = scrollView.convertRect(caretRect, fromView: textView)
//        
//       // scrollView.scrollRectToVisible(CGRect(x: convertedCaretRect.origin.x, y: convertedCaretRect.origin.y, width: convertedCaretRect.width, height: convertedCaretRect.height + 20), animated: false)
//    }
//    
//    // MARK: - UIScrollViewDelegate
//    
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        eventDescriptionTextView.resignFirstResponder()
//    }
    
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
    
    //DEPRECATED
//    override func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        picker.dismissViewControllerAnimated(true) { [weak self] in
//            let mediaItem = info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]
//            
//            guard let image: UIImage = mediaItem as? UIImage else {
//                self!.titleMessage = NSLocalizedString("Error", comment: "Error")
//                self!.message = NSLocalizedString("Image is lost", comment: "Image is lost")
//                self!.showAlert(self!.titleMessage.localized(), message: self!.message.localized())
//                return;
//            }
//            
//            self!.showImageEditScreen(withImage: image, frameType: .Circle, maxSize: CGSize(width: 320.0, height: 320.0))
//        }
//        //uploadImageLabel.hidden = true
//    }
    
    // ORCropImageControllerDelegate
    
//    override func cropVCDidFinishCrop(withImage image: UIImage?) {
//        guard let img = image else {
//            titleMessage = NSLocalizedString("Fail", comment: "Fail")
//            message = NSLocalizedString("Failed to crop image!", comment: "Failed to crop image!")
//            showAlert("Fail".localized(), message: "Failed to crop image!".localized())
//            return
//        }
//        
//        refreshAvatarImage(withImage: img)
//    }

    
    // MARK: - Actions
    

//    @IBAction func showEventDayViewTouched(sender: AnyObject) {
//        hideKeyboard()
//        layoutHeightEventDate.constant = layoutHeightEventDate.constant == heightEventDateView ? 0 : heightEventDateView
//        UIView.animateWithDuration(0.4) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func showEventDayEndViewTouched(sender: AnyObject) {
//        hideKeyboard()
//        layoutHeightEventDateEnd.constant = layoutHeightEventDateEnd.constant == heightEventDateView ? 0 : heightEventDateView
//        UIView.animateWithDuration(0.4) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
    
    @IBAction func saveEventNameTouched(sender: AnyObject) {
        hideKeyboard()
        if(eventNameTextField.text != nil) {
            eventName = eventNameTextField.text!
        }
    }
    
    @IBAction func saveEventDayTouched(sender: AnyObject) {
        hideKeyboard()
        let currentDate: NSDate = NSDate()
        //showEventDayViewTouched(sender)
        let compareDate = NSCalendar.currentCalendar().compareDate( datePickerDateEvent.date, toDate: currentDate,
                                                             toUnitGranularity: .Day)
        
        if (compareDate == .OrderedDescending) || (compareDate == .OrderedSame) {
            dayEvent = datePickerDateEvent.date
           // labelDateEvent.text = datePickerDateEvent.date.formatEventDay()
        }
        else {
            titleMessage = NSLocalizedString("Please, choose another date for this event", comment: "Please, choose another date for this event")
            message = NSLocalizedString("Selected date must be after the current date", comment: "Selected date must be after the current date")
            self.showAlert(titleMessage, message: message)
        }
    }
    
    @IBAction func saveEventDayEndTouched(sender: AnyObject) {
        hideKeyboard()
    }
    
    @IBAction func saveEventTimeTouched(sender: AnyObject) {
        hideKeyboard()
    }
    
    func editNameTouched(sender: AnyObject) {
        eventDescriptionTextView.editable = true
//        let rightButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneNameTouched(_:)))
//        navigationItem.rightBarButtonItem = rightButton
        
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
    
    
    @IBAction func doneNameTouched(sender: AnyObject) {
        postEvent()
        return
        /*
        navigationItem.rightBarButtonItem?.enabled = false
        if (validateFields() == true) {
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
                        let newEvent = RippleEvent()
                        if self.eventCreating {
                            return
                        }
                        
                        self.eventCreating = true
                        print("creating event")
                        EventManager().createEvent(self.organization!, event: newEvent, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, description: self.eventDescriptionTextView.text, address: self.streetAddressText.text!, city: self.cityStateZipText.text!, location: self.locationTextField.text!, coordinate: coordinate) {[weak self] (success, event) in
                            self?.eventCreating = false
                            
                            if success {
                                print("event was created")
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
                        EventManager().updateEvent(self.event!, organization: self.organization!, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, description: self.eventDescriptionTextView.text, address: self.streetAddressText.text!, city: self.cityStateZipText.text!, location: self.locationTextField.text!, coordinate: coordinate) { (success, event) in
                            self.eventCreating = false
                            self.hideActivityIndicator()
                            self.postPulsingButton.enabled = true
                            
                            if success {
                                self.event = event
                            }
                        }
                    }
                }
            }
            //hideActivityIndicator()
        }
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.view.endEditing(true)
    */
    }
    
    @IBAction func postToWhatsPulsingTouched(sender: AnyObject) {
        postEvent()
        return
        /*
        if validateFields() == true {
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
                                self?.hideActivityIndicator()
                               // self?.checkMarkImageView.hidden = false
                                self?.postPulsingButton.enabled = false
                            }
                                
                            or_postNotification(PulseNotification.PulseNotificationIsEventCreate.rawValue)
                            self?.postPulsingButton.enabled = true
                        } else {
                            self?.postPulsingButton.enabled = false
                            self?.createEvent({ (success) in
                                self?.postPulsingButton.enabled = false

                            })
//                            self?.createNewEvent({ (success) in
//                                self?.postPulsingButton.enabled = false
//                            })
                        }
                    }
                }
                hideActivityIndicator()
            }
        }
    */
    }
    
    
    @IBAction func sendInvitationsTouched(sender: AnyObject) {
        
        /*
        buttonSendInvitation.enabled = false
        if event != nil {
            //self.createNewEvent({ (success) in
            self.showInviteUsersViewController(nil, event: self.event)
            buttonSendInvitation.enabled = true
            //})
        } else if validateFields() == true {
            createNewEvent({[weak self] (success) in
                if success {
                    self?.showInviteUsersViewController(nil, event: self?.event)
                } else {
                    self!.buttonSendInvitation.enabled = true
                }
                })
        }
 
         */

    }
    
    
    //MARK: - Notifications
    
    func onEventSendInvitationsNotification() {
        wereInvitationsSent = true
    }
    
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - New functions for creating event
    
    func postEvent() {
        if validateFields() {
            createEvent() { (success) in
                if(success) {
                    self.eventCreating = false
                    self.navigationController!.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func validateFields() -> Bool {
        
        if eventName == "" {
            postEmptyFieldMessage("Please enter a valid name", comment: "Please enter a valid name")
            return false
        }
        if eventDescriptionTextView.text == "" {
            postEmptyFieldMessage("Please enter valid description", comment: "Please enter valid description")
            return false
        }
        if coordinate == nil {
            postEmptyFieldMessage("Please choose a valid location", comment: "Please choose a valid location")
            return false
        }
        
        if isFreeSwitch.on == false {
            if priceOfEvent.text == "" {
                postEmptyFieldMessage("Please choose a valid price, or set to free", comment: "Please choose a valid price, or set to free")
            }
        }
        
        //Refactor this eventually
        let calender = NSCalendar(calendarIdentifier: "gregorian")
        calender?.timeZone = NSTimeZone.systemTimeZone()
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Minute]
        let startTimeComponents = calender!.components(unitFlags, fromDate: datePickerStartTime.date)
        let endTimeComponents = calender!.components(unitFlags, fromDate: datePickerFinishTime.date)
        
        self.startTime = calender!.dateBySettingHour(startTimeComponents.hour, minute: startTimeComponents.minute, second: 0, ofDate: datePickerDateEvent.date, options: NSCalendarOptions())
        if(self.startTime!.earlierDate(NSDate()) == self.startTime!) {
            postEmptyFieldMessage("Please enter a later start time", comment: "Please enter a later start time")
            return false
        }
        self.finishTime = startTime!.copy() as! NSDate
        if(startTimeComponents.hour < endTimeComponents.hour) {
            self.finishTime? = self.finishTime!.tomorrow()
        }
        self.finishTime = calender!.dateBySettingHour(endTimeComponents.hour, minute: endTimeComponents.minute, second: 0, ofDate: self.finishTime!, options: NSCalendarOptions())
        
        let geoLocation = CLGeocoder()
        let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        geoLocation.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let place = placemarks?[0] else {
                return
            }
            if let city = place.addressDictionary!["City"] as? String {
                self?.city = city
            }
            if let address = place.addressDictionary!["Thoroughfare"] as? String {
                self?.address = address
            }
        }
        return true
    }
    
    func createEvent(completion: (success:Bool) -> Void) {
        showActivityIndicator()
        if(self.eventCreating) {
            return
        }
        self.eventCreating = true
        if(self.event == nil) {
            self.event = RippleEvent()
        }
        
        EventManager().createEvent(self.organization!,
                                   event: self.event!,
                                   name: self.eventName,
                                   start: self.startTime!,
                                   end: self.finishTime!,
                                   isPrivate: self.eventPrivacy.on,
                                   cost: priceEvent,
                                   description: self.eventDescriptionTextView.text,
                                   address: self.address,
                                   city: self.city,
                                   location: self.location,
                                   coordinate: self.coordinate,
                                   completion: {[weak self] (success, rippleEvent) in
                                    self?.hideActivityIndicator()
                                    self?.eventCreating = false
                                    if (success) {
                                        self?.event = rippleEvent
                                        or_postNotification(PulseNotification.PulseNotificationIsEventCreate.rawValue)
                                    } else {
                                        self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                                        self!.message = NSLocalizedString("The event was not created. Please, try again later", comment: "The event was not created. Please, try again later")
                                        self?.showAlert(self?.titleMessage, message: self?.message)
                                    }
                                    self?.navigationController?.popViewControllerAnimated(true)
                                    
        })
    }

    //MARK: - SOON TO BE DEPRECATED
    
    /*
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
                let newEvent = RippleEvent()
                
                if self.eventCreating {
                    return
                }
                self.eventCreating = true
                
                
                EventManager().createEvent(self.organization!, event: newEvent, name: self.eventName, start: self.dayEvent!.setTimeForDate(self.startTime!), end: self.dayEventEnd!.setTimeForDate(self.finishTime!), isPrivate: self.isPrivateEvent, cost: self.priceEvent, description: self.eventDescriptionTextView.text, address: self.streetAddressText.text!, city: self.cityStateZipText.text!, location: self.locationTextField.text!, coordinate: coordinate) {[weak self] (success, event) in
                    self?.hideActivityIndicator()
                    self?.eventCreating = false
                    
                    if success {
                        if (self?.isPrivateEvent == false) {
                           // self?.checkMarkImageView.hidden = false
                            //self?.postPulsingButton.hidden = false
                        }
                        
                        self?.event = event
                        or_postNotification(PulseNotification.PulseNotificationIsEventCreate.rawValue)
                        completion(success: true)
                    } else {
                        self!.titleMessage = NSLocalizedString("Error", comment: "Error")
                        self!.message = NSLocalizedString("The event was not created. Please, try again later", comment: "The event was not created. Please, try again later")
                        self?.showAlert(self?.titleMessage, message: self?.message)
                    }
                }
 
            }
        }
 
        hideActivityIndicator()
    }
    */
    
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
    
    func writeBackEventLocation(latitude: Double, longitude:Double, location:String) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.location = location
    }
     //MARK: - Internal operations
    
//    func updateAvatar(withNewAvatarURL avatarURL: String, storagePath: String, completion: ((Bool, NSError?) -> Void)?) {
//        let picture = event?.picture ?? Pictures()
//        picture.imageURL = avatarURL
//        picture.save { (_, _) in }
//    }
//    
//    func refreshAvatarImage(withImage image: UIImage) {
//        self.eventPictureImageView.image = image
//    }
}


