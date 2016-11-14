//
//  ViewController.swift
//  Ripple
//
//  Created by Adam Gluck on 8/10/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import FirebaseAuth
import ORLocalizationSystem
import FBSDKLoginKit
import ParseFacebookUtilsV4
import  QuickLook

class LoginViewController: BaseViewController, UITextFieldDelegate, QLPreviewControllerDataSource,QLPreviewControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signFBButton: UIButton!

    var docName: String = ""

     weak var whaitView: UIImageView? = nil

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        usernameTextField.placeholder = NSLocalizedString("Email", comment: "Email")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password")
        registerButton.titleLabel?.text = NSLocalizedString("Register", comment: "Register")
        signFBButton.titleLabel?.text = NSLocalizedString("Log in with Facebook", comment: "Log in with Facebook")
        autoLogin()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.showUserAgree()
    }
    func showWhaitView() {
        self.usernameTextField.enabled = false
        self.passwordTextField.enabled = false
        self.registerButton.enabled = false
        self.loginButton.enabled = false
        self.signFBButton.enabled = false
        let whaitView = UIImageView(frame: view.bounds)
        whaitView.image = UIImage(named: "headpiece")
        self.whaitView = whaitView
        self.view.addSubview(self.whaitView!)
    }
    func hideWhaitView() {
        self.whaitView?.removeFromSuperview()
        self.usernameTextField.enabled = true
        self.passwordTextField.enabled = true
        self.registerButton.enabled = true
        self.loginButton.enabled = true
        self.signFBButton.enabled = true
    }
    func autoLogin() {
        self.view.frame.origin.y = 0
        if PFUser.currentUser()!.username != nil {
            showWhaitView()
            
            let fbToken = FBSDKAccessToken.currentAccessToken()
            if fbToken != nil {
                PFFacebookUtils.logInInBackgroundWithAccessToken(fbToken) { (user, error) in
                    if error == nil {
                        print("facebook parse autologin complete")
                        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                        FIRAuth.auth()?.signInWithCredential(credential, completion: {(result, error) in
                            if error == nil {
                                print("facebook firebase autologin complete")
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.loginComplete()
                            } else {
                                print("facebook firebase autologin failed")
                            }
                             self.hideWhaitView()
                        })
                    }
                }
            } else {
                API().loginToApp((PFUser.currentUser()?.username)!, password: UserManager().userPassword) { (onLogin, errorMessage) in
                    if onLogin {
                        self.hideWhaitView()
                        print("AutologinComplete")
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.loginComplete()
                    }
                    self.hideWhaitView()
                }
            }
        }
            
    }

        func keyboardWillShow(sender: NSNotification) {
          self.view.frame.origin.y = -200
    }
    
    func login()
    {
        showActivityIndicator()
        UserManager().userPassword = passwordTextField.text!
        API().loginToApp(usernameTextField.text!, password: passwordTextField.text!) { (onLogin, errorMessage) in
            self.hideActivityIndicator()
            
            if onLogin {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loginComplete()
            } else {
                self.view.endEditing(true)
                self.view.frame.origin.y = 0
                self.view.userInteractionEnabled = true
                self.showAlert(NSLocalizedString("FailedLogin", comment: "FailedLogin"), message: errorMessage)
            }
        }
    }
    
    func copyImage(fromExternalURL url: String, completion: ((imageURL: NSURL?, storagePath: String?, error: NSError?) -> Void)?) {
        
        func downloadImage(fromURL url: String, completion: ((image: UIImage?, error: NSError?) -> Void)) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { 
                guard let imageURL = NSURL(string: url), let imageData = NSData(contentsOfURL: imageURL), let image = UIImage(data: imageData) else {
                    completion(image: nil, error: nil)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { 
                    completion(image: image, error: nil)
                })
            }
        }
        
        if let auth = FIRAuth.auth() {
            do {
                try auth.signOut()
            } catch {
            }
        }
        
        let onAvatarDownloaded = { [weak self] (image: UIImage?, error: NSError?) in
            if error != nil || image == nil {
                completion?(imageURL: nil, storagePath: nil, error: error)
                return
            }
            
            self!.uploadImage(image!, withCompletion: completion)
        }
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            if let err = error {
                completion?(imageURL: nil, storagePath: nil, error: err)
                return
            }
            //UserManager().fbToken = FBSDKAccessToken.currentAccessToken()
            downloadImage(fromURL: url, completion: onAvatarDownloaded)
        })
    }
    
    func loginWithFacebook(completion: ((user: PFUser!, error: NSError?) -> Void)?) {
        
        let facebookManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        func showFailAlert(withMessage message: String) {
            self.showAlert("Error".localized(), message: message)
        }
        
        func tryToUseFacebookProfileAvatar(forUser user: PFUser) {
            let params = ["redirect" : false, "type" : "normal"]
            let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: params)
            
            request.startWithCompletionHandler { (connection, result, error) in
                if let _ = error {
                    showFailAlert(withMessage: "Failed to get facebook profile avatar.")
                    completion?(user: user, error: nil)
                    return
                }
                
                guard let resultDict = result as? [String : AnyObject] else {
                    completion?(user: user, error: nil)
                    return
                }
                
                guard let dataDict = resultDict["data"] as? [NSObject : AnyObject], let imageURLStr = dataDict["url"] as? String else {
                    completion?(user: user, error: nil)
                    return
                }
                
                let user = PFUser.currentUser()!
                
                
                if let _ = user["picture"] as? PFObject {
                    completion?(user: user, error: nil)
                    return;
                }
                
                self.copyImage(fromExternalURL: imageURLStr, completion: { (imageURL, storagePath, error) in
                    if let _ = error {
                        showFailAlert(withMessage: "Failed to get facebook profile avatar.")
                        completion?(user: user, error: nil)
                        return
                    }
                    
                    let picture = PFObject(className: "Pictures")
                    picture["imageURL"] = imageURLStr
                    picture["storagePath"] = storagePath
                    
                    picture.saveInBackgroundWithBlock({ (success, error) in
                        if error == nil {
                            user["picture"] = picture
                        }
                        
                        completion?(user: user, error: nil)
                    })
                })
            }
        }
        
        func useFacebookProfileToFillUser(user: PFUser) {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            request.startWithCompletionHandler { (connection, result, error) in
                if let err = error {
                    showFailAlert(withMessage: "Failed to get facebook profile.")
                    PFUser.logOut()
                    completion?(user: nil, error: err)
                    return
                }
                
                guard let resultDict = result as? [String : AnyObject] else {
                    showFailAlert(withMessage: "Failed to get facebook profile.")
                    PFUser.logOut()
                    completion?(user: nil, error: nil)
                    return
                }
                guard resultDict["name"] != nil else {
                    showFailAlert(withMessage: "Failed to get facebook profile.")
                    PFUser.logOut()
                    completion?(user: nil, error: nil)
                    return
                }
                let user = PFUser.currentUser()!
                user["fullName"] = resultDict["name"]
                user["organizations"] = [PFObject]()
                user["events"] = [PFObject]()
                user["friends"] = [PFObject]()
                user["eventsBlackList"] = [PFObject]()
                tryToUseFacebookProfileAvatar(forUser: user)
            }
        }
        
        func authorizeInParse(withToken fbToken: FBSDKAccessToken) {
            PFFacebookUtils.logInInBackgroundWithAccessToken(fbToken) { (user, error) in
                if let err = error {
                    showFailAlert(withMessage: err.localizedDescription)
                    return
                }
                
                guard let currentUser = user else {
                    showFailAlert(withMessage: "Failed to fetch user".localized())
                    return
                }
                
                let fullName = currentUser["fullName"] as? String
                if fullName == nil || fullName!.characters.count <= 0 {
                    useFacebookProfileToFillUser(currentUser)
                } else {
                    completion?(user: currentUser, error: nil)
                }
            }
        }
        
        facebookManager.logOut()
        facebookManager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) in
            if let err = error {
                showFailAlert(withMessage: err.localizedDescription)
                completion?(user: nil, error: err)
                return
            }
            
            if !result.isCancelled {
                authorizeInParse(withToken: result.token)
            } else {
                self.hideWhaitView()
                self.hideActivityIndicator()
            }
        }
    }
    
    func showUserAgree(){
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
        //self.view.endEditing(false)
        //self.viewDidAppear(animated)
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
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            if (usernameTextField.text == "")
            {
                usernameTextField.becomeFirstResponder()
                self.view.frame.origin.y = 0
                self.login()
            }
            else
            {
                self.view.frame.origin.y = 0
                self.login()
            }
        }
        return true
    }

    // MARK: - Actions
    
    @IBAction func loginTouched(sender: UIButton) {
        self.view.frame.origin.y = 0
        self.view.endEditing(true)
        self.login()
    }
    
    @IBAction func facebookLoginTouched(sender: AnyObject) {
        self.view.endEditing(false)
        self.showWhaitView()
        self.loginWithFacebook { [weak self] (user, error) in
            if let currentUser = user {
                currentUser["isPrivate"] = false
                currentUser.saveInBackgroundWithBlock({ [weak self] (success, error) in
                    if error != nil {
                        self!.hideWhaitView()
                        self!.showAlert("Error".localized(), message: "Failed to save user profile".localized())
                        return
                    }
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.loginComplete()
                })
            } else {
                self!.hideWhaitView()
            }
        }
        //self.hideWhaitView()
    }
    
    @IBAction func forgotPasswordTouch(sender: UIButton) {
        let title = "Your password will be sent to you email."
        let message = ""
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Don't allow", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
            PFUser.requestPasswordResetForEmailInBackground(self.usernameTextField.text!)
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)

    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let path = NSBundle.mainBundle().pathForResource(docName, ofType: "docx")
        let url = NSURL.fileURLWithPath(path!)
        
        return url
    }
}
