//
//  SettingsChangePasswordViewController.swift
//  
//
//  Created by HeroinoOp on 21.09.16.
//
//

import UIKit
import Parse
import Firebase
import ORLocalizationSystem

class SettingsChangePasswordViewController: BaseViewController, UITextFieldDelegate {

   
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    var editButton = UIBarButtonItem()
    var titleMessage :String = ""
    var message :String = ""
    var startViewPositionY :CGFloat = 0
    
    var labelWasUp :Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ProfileViewController.editProfileTouched(_:)))
        navigationItem.rightBarButtonItem = editButton
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        let oldPassword = NSLocalizedString("OldPassword", comment: "OldPassword")
        let newPassword = NSLocalizedString("NewPassword", comment: "NewPassword")
        let confirmPassword = NSLocalizedString("ConfirmNewPassword", comment: "ConfirmNewPassword")
        self.title = NSLocalizedString("ChangePassword", comment: "ChangePassword")
        editButton.title = NSLocalizedString("Edit", comment: "Edit")
        self.view.backgroundColor = UIColor.lightGrayColor()
        let titleColor = UIColor.init(red: 46/255, green:49/255, blue: 146/255, alpha: 1)
        oldPasswordTextField.attributedPlaceholder = NSAttributedString(string: oldPassword, attributes: [NSForegroundColorAttributeName: titleColor])
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: newPassword, attributes: [NSForegroundColorAttributeName: titleColor])
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: confirmPassword, attributes: [NSForegroundColorAttributeName: titleColor])
        oldPasswordTextField.textAlignment = NSTextAlignment.Center
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.userInteractionEnabled = true
        //startViewPositionY = self.view.frame.origin.y
        startViewPositionY = self.view.bounds.origin.y
        print("\(self.view.bounds.origin.y)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(false)
        self.view.userInteractionEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if !labelWasUp {
            self.view.bounds.origin.y = startViewPositionY + 60
            labelWasUp = true
        }
        print("\(self.view.bounds.origin.y)")
    }
    
    func keyboardWillHide(sender: NSNotification) {
        //labelWasUp = false
        //self.view.frame.origin.y = startViewPositionY
        print("\(self.view.frame.origin.y)")
    }
    

    override func viewDidDisappear(animated: Bool) {
        self.view.endEditing(false)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.bounds.origin.y = startViewPositionY
        self.view.endEditing(true)
        labelWasUp = false
        print("\(self.view.bounds.origin.y)")
    }
    
    func editProfileTouched(sender: AnyObject) {
        self.view.bounds.origin.y = startViewPositionY
        self.view.endEditing(true)
        labelWasUp = false
        showActivityIndicator()
        changePassword()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == oldPasswordTextField {
            newPasswordTextField.becomeFirstResponder()
        } else if textField == newPasswordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            self.view.bounds.origin.y = startViewPositionY
            labelWasUp = false
            self.showActivityIndicator()
            changePassword()
        }
        
        return true
    }
    
    func changePassword() {
        if !(oldPasswordTextField!.text!.isEmpty) && !(confirmPasswordTextField!.text!.isEmpty) && !(newPasswordTextField!.text!.isEmpty){
            if newPasswordTextField.text! == confirmPasswordTextField.text! {
                if oldPasswordTextField.text! == UserManager().userPassword {
                    if newPasswordTextField.text?.or_length >= 6 {
                        // update password firebase
                        self.navigationItem.rightBarButtonItem?.enabled = false
                        if (FIRAuth.auth()?.currentUser) != nil {
                            FIRAuth.auth()?.currentUser!.updatePassword(self.newPasswordTextField.text!) { error in
                                if error == nil {
                                    print("Fira update password")
                                    PFUser.currentUser()?.password = self.newPasswordTextField.text!
                                    PFUser.currentUser()?.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if success {
                                            print("parse has changed password")
                                            UserManager().userPassword = self.newPasswordTextField.text!
                                            self.login()
                                        } else {
                                            print("parse has not changed password")
                                            self.hideActivityIndicator()
                                            self.navigationItem.rightBarButtonItem?.enabled = true
                                            return
                                        }
                                    }
                                } else {
                                    self.titleMessage = NSLocalizedString("Error", comment: "Error")
                                    self.message = NSLocalizedString("Your password was not updated in the database", comment: "Your password was not updated in the database")
                                    self.showAlert(self.titleMessage, message: self.message)
                                    self.hideActivityIndicator()
                                    self.navigationItem.rightBarButtonItem?.enabled = true
                                }
                            }
                        }else {
                            self.titleMessage = NSLocalizedString("Error", comment: "Error")
                            self.message = NSLocalizedString("This account was not registered in the database", comment: "This account was not registered in the database")
                            self.showAlert(self.titleMessage, message: self.message)
                            self.hideActivityIndicator()
                            self.navigationItem.rightBarButtonItem?.enabled = true
                        }
                    } else {
                        self.titleMessage = NSLocalizedString("Error", comment: "Error")
                        self.message = NSLocalizedString("Your password must contain at least 6 characters", comment: "Your password must contain at least 6 characters")
                        showAlert(self.titleMessage, message: self.message)
                        self.hideActivityIndicator()
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    }
                } else {
                    print("UserManager().userPassword = " + UserManager().userPassword)
                    self.titleMessage = NSLocalizedString("Error", comment: "Error")
                    self.message = NSLocalizedString("Your old password is incorrect", comment: "Your old password is incorrect")
                    showAlert(self.titleMessage, message: self.message)
                    self.hideActivityIndicator()
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
                
            } else {
                self.titleMessage = NSLocalizedString("Error", comment: "Error")
                self.message = NSLocalizedString("Confirm password failed", comment: "Confirm password failed")
                showAlert(self.titleMessage, message: self.message)
                self.hideActivityIndicator()
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
        } else {
            self.titleMessage = NSLocalizedString("Error", comment: "Error")
            self.message = NSLocalizedString("Empty field", comment: "Empty field")
            showAlert(self.titleMessage, message: self.message)
            self.hideActivityIndicator()
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func login()
    {
        PFUser.logInWithUsernameInBackground((PFUser.currentUser()?.username)!, password: self.newPasswordTextField.text!, block: { (user, error) -> Void in
            if user != nil {
                print("Parse has been login")
                FIRAuth.auth()?.signInWithEmail((PFUser.currentUser()?.username)!, password: self.newPasswordTextField.text!) { (userFB,  error) in
                    print("Firebase has been login")
                    self.titleMessage =  NSLocalizedString("ChangePassword", comment: "ChangePassword")
                    self.message = NSLocalizedString("Passwordhasbeenchanged", comment: "Passwordhasbeenchanged")
                    self.showAlert(self.titleMessage, message: self.message)
                    self.oldPasswordTextField.text = ""
                    self.newPasswordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    self.hideActivityIndicator()
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        })
    }

}

