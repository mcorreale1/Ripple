//
//  ViewController.swift
//  Ripple
//
//  Created by Adam Gluck on 8/10/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import QuickLook

class LoginViewController: BaseViewController, UITextFieldDelegate, QLPreviewControllerDataSource,QLPreviewControllerDelegate {
    
    
    
    /* code for ignoring events while wheel spins
     
     wheel = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) //makes a spinner on the screen
     wheel.center = self.view.center // puts spinner in middle of screen
     wheel.hidesWhenStopped = true //self explanatory
     wheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray // sets the color
     view.addSubview(wheel) // adds activity indicator to the view
     wheel.startAnimating() // starts the acitivty indicator
     UIApplication.sharedApplication().beginIgnoringInteractionEvents() // pauses the app when the spinner appears
     
     
     
     self.wheel.stopAnimating()
     
     UIApplication.sharedApplication().endIgnoringInteractionEvents()
 
 
 */
    
    // Creates variables for the text fields and the buttons
    
    
    @IBOutlet weak var signFBButton: UIButton!

    /* 
       used as the title of the documents for Terms of Use and Privacy Policy
       for first login by user
    */
    var docName: String = ""

     weak var waitView: UIImageView? = nil

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoLogin()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        signFBButton.titleLabel?.text = NSLocalizedString("Log in with Facebook", comment: "Log in with Facebook")
        
    }
    


    
    /*The first time a user uses the app they are forced to
    look at the privacy policy/terms of use
    */
    override func viewWillAppear(animated: Bool) {
        self.showUserAgree()
    }
    //User is on "wait" i.e. loading screen
    func showWaitView() {
       
        self.signFBButton.enabled = false
        let waitViewImage = UIImageView(frame: view.bounds)
        waitViewImage.image = UIImage(named: "headpiece")
        self.waitView = waitViewImage
        self.view.addSubview(self.waitView!)
    }
    
    /*can interact again with the loginView controller page after accepting
    the privacy policy and terms of use for the first time
     */
    func hideWaitView() {
        self.waitView?.removeFromSuperview()
                self.signFBButton.enabled = true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -200
    }
    
// DEPRECATED
//    func login() {
//        showActivityIndicator()
//        UserManager().userPassword = passwordTextField.text!
//        API().loginToApp(usernameTextField.text!, password: passwordTextField.text!, completion:  { (onLogin, error) in
//            self.hideActivityIndicator()
//            
//            if onLogin {
//                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                appDelegate.loginComplete()
//            } else {
//                self.view.endEditing(true)
//                self.view.frame.origin.y = 0
//                self.view.userInteractionEnabled = true
//                self.showAlert(NSLocalizedString("FailedLogin", comment: "FailedLogin"), message: error?.localizedDescription)
//            }
//        })
//    }
        /*Only happens the first time a user uses the app,
        forces the user to accept privacy policy/terms of use
        */
//    func subscribe() {
//        do {
//            let responder = Responder(responder: self, selResponseHandler: #selector(MessagesManager.sharedInstance.responseHandles(_:)), selErrorHandler: #selector(MessagesManager.sharedInstance.errorHandler(_:)))
//            let subscriptionOptions = SubscriptionOptions()
//            let subscription = Backendless.sharedInstance().messagingService.subscribe("Messages", subscriptionResponder: responder, subscriptionOptions: subscriptionOptions)
//            print("SUBSCRIPTION: \(subscription)")
//        }
//    }
    
    func showUserAgree() {
        if UserManager().launchedBefore == false {
            let title = "Welcome to Pulse!"
            let message = "By using this app you agree to the following"
            let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Privacy Policy", style: .Default, handler: { (action: UIAlertAction!) in
                self.docName = "Privacy Policy"
                let preview = QLPreviewController()
                preview.dataSource = self
                preview.delegate = self
                self.presentViewController(preview, animated: false, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Terms of Use", style: .Default, handler: { (action: UIAlertAction!) in
                self.docName = "Terms of Use"
                let preview = QLPreviewController()
                preview.dataSource = self
                preview.delegate = self
                self.presentViewController(preview, animated: false, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
                UserManager().launchedBefore = true
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        
    }

    
    override func viewDidAppear(animated: Bool) {
        self.view.userInteractionEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(false)
        self.view.userInteractionEnabled = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.endEditing(false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("Here")
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    // MARK: - UITextFieldDelegate
//DEPRECATED
//    func textFieldShouldReturn(textField:UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if textField == usernameTextField {
//            passwordTextField.becomeFirstResponder()
//        }
//        else if textField == passwordTextField {
//            if (usernameTextField.text == "")
//            {
//                usernameTextField.becomeFirstResponder()
//                self.view.frame.origin.y = 0
//                self.login()
//            }
//            else
//            {
//                self.view.frame.origin.y = 0
//                self.login()
//            }
//        }
//        return true
//    }

    // MARK: - Actions
    
    
    //FB login
    @IBAction func facebookLoginTouched(sender: AnyObject) {
        self.view.endEditing(false)
        self.showWaitView()
        API().loginWithFacebook(fromViewController: self, completion: { [weak self] (user, error) in
            if error != nil {
                self?.showAlert("Error".localized(), message: error?.localizedDescription)
            }
            if let currentUser = user {
                currentUser.isPrivate = false
                currentUser.authData = self!.generateAuthData(FBSDKAccessToken.currentAccessToken())
                currentUser.save( { [weak self] (success, error) in
                    if !success && error != nil {
                        self?.hideWaitView()
                        self?.showAlert("Error".localized(), message: "Failed to save user profile".localized())
                        return
                    }
                    Backendless.sharedInstance().userService.setPersistentUser()
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.loginComplete() { (success) in
                        if(!success) {
                            self?.showAlert("Login failed", message: "Login failed, please try again")
                        }
                    }
                })
            } else {
                self?.hideWaitView()
            }
        } , onCancel: { [weak self] () in
            self?.hideWaitView()
            self?.hideActivityIndicator()
        })
    }
    
    //(DEPRECATED)
//    @IBAction func forgotPasswordTouch(sender: UIButton) {
//        let title = "Your password will be sent to you email."
//        let message = ""
//        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        refreshAlert.addAction(UIAlertAction(title: "Don't allow", style: .Default, handler: { (action: UIAlertAction!) in
//        }))
//        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
//            API().resetPassword(self.usernameTextField.text!)
//        }))
//        
//        presentViewController(refreshAlert, animated: true, completion: nil)
//
//    }
    
    //Makes one item for the preview view controller (privacy policy/terms of use documentation)
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    //Creates the view controller for the policy documentation
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let path = NSBundle.mainBundle().pathForResource(docName, ofType: "docx")
        let url = NSURL.fileURLWithPath(path!)
        return url
    }
    
    //Formates the AuthData string into a json-like format
    func generateAuthData(token: FBSDKAccessToken) -> String {
        return "{\"facebook\":{\"access_token\":\"\(token.tokenString)\",\"expiration_date\":\"\(token.expirationDate)\",\"id\":\"\(token.userID)\"}}"
        
    }
    
    //Calls auto login from API class
    func autoLogin() {
        self.showWaitView()
        if (API().autoLogin()) {
            self.showActivityIndicator()
            print("Auto login worked \(UserManager().currentUser().name)")
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.loginComplete() { (success) in
                if(!success) {
                    self.showAlert("Login failed", message: "Login failed, please try again")
                }
            }
        } else {
            self.hideWaitView()
        }
        
    }
}
