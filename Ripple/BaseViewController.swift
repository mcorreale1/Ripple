//
//  BaseViewController.swift
//  Ripple
//
//  Created by evgeny on 08.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import commoncode_ios
import ORCropImageController

class BaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ORCropImageViewControllerDelegate {
    
    //Controls the other view controllers, methods are created in this baseviewcontroller to be used to segue and prepare other view controllers

    var chatSegueIdentifier: String { return "chat" }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    weak var shadeView: UIView?
    
    var isPerformingSegueToChat = false
    var createdRoomID: String?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActivityIndicator()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showOrganizationProfileViewController(organization: Organizations?, isNewOrg: Bool, fromInvite: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let orgProfileViewController = storyboard.instantiateViewControllerWithIdentifier("OrganizationProfileViewController") as! OrganizationProfileViewController
        orgProfileViewController.editOrganization = isNewOrg
        orgProfileViewController.fromInviteScreen = fromInvite
        orgProfileViewController.organization = organization
        //navigationController?.presentViewController(orgProfileViewController, animated: true, completion: nil)
        navigationController?.showViewController(orgProfileViewController, sender: self)
    }
    
    func showEventDescriptionViewController(event: RippleEvent) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let eventDescriptionController = storyboard.instantiateViewControllerWithIdentifier("EventDescriptionViewController") as! EventDescriptionViewController
        eventDescriptionController.event = event
        navigationController?.showViewController(eventDescriptionController, sender: self)
    }
    
    func showProfileViewController(user: Users, delegate: ProfileViewControllerDelegate? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileViewController.delegate = delegate
        profileViewController.selectedUser = user
        navigationController?.showViewController(profileViewController, sender: self)
    }
    
    func showInviteUsersViewController(organization: Organizations?, event: RippleEvent?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let inviteUsersViewController = storyboard.instantiateViewControllerWithIdentifier("InviteUsersViewController") as! InviteUsersViewController
        inviteUsersViewController.event = event
        inviteUsersViewController.organization = organization
        navigationController?.showViewController(inviteUsersViewController, sender: self)
    }
    
    func showCreateEventViewController(organization: Organizations?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createEventViewController = storyboard.instantiateViewControllerWithIdentifier("CreateEventViewController") as! CreateEventViewController
        createEventViewController.organization = organization
        navigationController?.showViewController(createEventViewController, sender: self)
    }
    
    func showEditVentViewController(organization: Organizations?, event: RippleEvent?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createEventViewController = storyboard.instantiateViewControllerWithIdentifier("CreateEventViewController") as! CreateEventViewController
        createEventViewController.organization = organization
        createEventViewController.event = event
        navigationController?.showViewController(createEventViewController, sender: self)
    }
    
    func showAddressViewController(event: RippleEvent) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chooseAddressViewController = storyboard.instantiateViewControllerWithIdentifier("ChooseAddressViewController") as! ChooseAddressViewController
        chooseAddressViewController.event = event
        chooseAddressViewController.address = event.address ?? ""
        navigationController?.showViewController(chooseAddressViewController, sender: self)
    }
    
    func showSearchVIewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chooseSearchViewController = storyboard.instantiateViewControllerWithIdentifier("SearchVC") as! SearchViewController
        navigationController?.showViewController(chooseSearchViewController, sender: self)
    }
    
    // MARK: - Notifications setup
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboardWillShowNotifications(_:)),
        name: UIKeyboardWillShowNotification,
        object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboardWillHideNotification(_:)),
        name: UIKeyboardWillHideNotification,
        object: nil)
    }
        
    func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
        
    
    // MARK: - Helpers
    
    
    private func prepareActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.tintColor = UIColor.whiteColor()
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.alpha = 0
    }
    
    //test ignoring interactions
    func showActivityIndicator(allowInteraction allowInteraction:Bool = false) {
        if(!allowInteraction) {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        activityIndicator.hidden = false
        activityIndicator.alpha = 0
        
            UIView.animateWithDuration(0.5) {
            self.activityIndicator.alpha = 1.0
                self.activityIndicator.color = UIColor.grayColor()
        }
    }
   //should end interaction events
    func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        UIView.animateWithDuration(0.3, animations: {
            self.activityIndicator.alpha = 0.0
            self.shadeView?.alpha = 0.0
        }) { (finished) in
            self.activityIndicator.hidden = true
            self.shadeView?.removeFromSuperview()
        }
    }
    
    func showAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        let userAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        userAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            completion?()
        }))
        self.presentViewController(userAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Picker
    
    func pickImage() {
        let actionSheetOptions = UIAlertController(title: nil, message: "Select image source".localized(), preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheetOptions.addAction(withTitle: "Camera".localized(), handler: { [weak self] (action) in
                self!.showImagePicker(withSourceType: .Camera)
            })
        }
        
        actionSheetOptions.addAction(withTitle: "Album".localized(), handler: { [weak self] (action) in
            self!.showImagePicker(withSourceType: .SavedPhotosAlbum)
        })
        
        actionSheetOptions.addAction(withTitle: "Library".localized(), handler: { [weak self] (action) in
            self!.showImagePicker(withSourceType: .PhotoLibrary)
        })
        
        
        actionSheetOptions.addCancelAction(withTitle: "Cancel".localized())
        self.presentViewController(actionSheetOptions, animated: true, completion: nil)
    }
    
    func showImagePicker(withSourceType sourceType: UIImagePickerControllerSourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = sourceType
        vc.delegate = self;
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    //allows manipulation of chosen photo
    func showImageEditScreen(withImage image: UIImage, frameType: ORCropImageViewController.CursorType, maxSize: CGSize? = nil) {
        let bundle: NSBundle = NSBundle(forClass: ORCropImageViewController.self)
        let vc = ORCropImageViewController(nibName: "ORCropImageViewController", bundle: bundle, image: image)
        vc.cursorType = frameType
        vc.destImageMaxSize = maxSize
        vc.delegate = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    }
    
    
    // MARK: - ORCropImageViewControllerDelegate
    
    func cropVCDidFailToPrepareImage(error: NSError?) {
        showAlert("Fail".localized(), message: "Failed to crop image!".localized())
    }
    
    //SHOULD RETURN A CROPPED IMAGE
    func cropVCDidFinishCrop(withImage image: UIImage?) {
        // TODO Use edited image
    }
    
    func titleForCropVCCancelButton() -> String {
        return "Cancel".localized()
    }
    
    func titleForCropVCSubmitButton() -> String {
        return "Save".localized()
    }
    
    func usingButtonsInCropVC() -> ORCropImageViewController.Button {
        return [.Cancel, .Submit]
    }
    
    // MARK: - UIKeyboardNotifications
    
    func keyboardAnimationDetails(fromNotificationUserInfo userInfo: [NSObject : AnyObject]) -> (kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let animDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        return (kbFrame: keyboardFrame, duration: animDuration.doubleValue, animationOptionCurve: UInt(animCurve))
    }
    
    @objc private func onKeyboardWillShowNotifications(notif: NSNotification) {
        guard let userInfo = notif.userInfo else {
            return
        }
        
        let animDetails = keyboardAnimationDetails(fromNotificationUserInfo: userInfo)
        willShowKeyboard(withFrame: animDetails.kbFrame, duration: animDetails.duration, animationOptionCurve: animDetails.animationOptionCurve)
    }
    
    @objc private func onKeyboardWillHideNotification(notif: NSNotification) {
        guard let userInfo = notif.userInfo else {
            return
        }
        
        let animDetails = keyboardAnimationDetails(fromNotificationUserInfo: userInfo)
        willHideKeyboard(withFrame: animDetails.kbFrame, duration: animDetails.duration, animationOptionCurve: animDetails.animationOptionCurve)
    }
    
    
    // MARK: - Keyboard show/hide handlers
    
    func willShowKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
    }
    
    func willHideKeyboard(withFrame kbFrame: CGRect, duration: NSTimeInterval, animationOptionCurve: UInt) {
    }
    
    
    // MARK: - Chat
    
    func addChatWithUser(user: Users) {
        performSegueWithIdentifier(chatSegueIdentifier, sender: user)
    }
}
