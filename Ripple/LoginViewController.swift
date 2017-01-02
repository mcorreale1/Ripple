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
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -200
    }
    
    func login() {
        showActivityIndicator()
        UserManager().userPassword = passwordTextField.text!
        API().loginToApp(usernameTextField.text!, password: passwordTextField.text!, completion:  { (onLogin, error) in
            self.hideActivityIndicator()
            
            if onLogin {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loginComplete()
            } else {
                self.view.endEditing(true)
                self.view.frame.origin.y = 0
                self.view.userInteractionEnabled = true
                self.showAlert(NSLocalizedString("FailedLogin", comment: "FailedLogin"), message: error?.localizedDescription)
            }
        })
    }
    
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
        API().loginWithFacebook(fromViewController: self, completion: { [weak self] (user, error) in
            if error != nil {
                self?.showAlert("Error".localized(), message: error?.localizedDescription)
            }
            if let currentUser = user {
                currentUser.isPrivate = false
                
                currentUser.save( { [weak self] (success, error) in
                    if !success && error != nil {
                        self?.hideWhaitView()
                        self?.showAlert("Error".localized(), message: "Failed to save user profile".localized())
                        return
                    }
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.loginComplete()
                })
            } else {
                self?.hideWhaitView()
            }
        } , onCancel: { [weak self] () in
            self?.hideWhaitView()
            self?.hideActivityIndicator()
        })
    }
    
    @IBAction func forgotPasswordTouch(sender: UIButton) {
        let title = "Your password will be sent to you email."
        let message = ""
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Don't allow", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
            API().resetPassword(self.usernameTextField.text!)
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
