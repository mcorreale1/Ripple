//
//  RegistrationController.swift
//  Ripple
//
//  Created by Adam Gluck on 9/7/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class RegistrationViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegistrationViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegistrationViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        firstNameTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password")
        firstNameTextField.placeholder = NSLocalizedString("FirstNameLastName", comment: "FirstNameLastName")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "Email")
        registrationLabel.text = NSLocalizedString("Registration", comment: "Registration")
        doneButton.titleLabel?.text = NSLocalizedString("Done", comment: "Done")
        backButton.titleLabel?.text = NSLocalizedString("Back", comment: "Back")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxLength
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -40
    }
    
    func keyboardWillHide(sender: NSNotification) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func processSignOut() {
        //PFUser.logOut()
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            if textField == firstNameTextField {
                emailTextField.becomeFirstResponder()
            }
            else if textField == emailTextField {
                passwordTextField.becomeFirstResponder()
            }
            else if textField == passwordTextField
            {
                showActivityIndicator()
                self.view.frame.origin.y = 0
                
                API().signUp(passwordTextField.text!, email: emailTextField.text!, fullName: firstNameTextField.text!) { (signUpComplete, errorMessage) in
                    self.hideActivityIndicator()
                    
                    if signUpComplete {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.loginComplete()
                    } else {
                        self.showAlert("Failed SignUp", message: errorMessage)
                    }
                }

            }

        return true
    }

    
    // MARK: - Actions
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func continueTouched(sender: UIButton) {
        showActivityIndicator()
        UserManager().userPassword = passwordTextField.text!
        API().signUp(passwordTextField.text!, email: emailTextField.text!, fullName: firstNameTextField.text!) { (signUpComplete, errorMessage) in
            self.hideActivityIndicator()
            
            if signUpComplete {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loginComplete()
            } else {
                self.showAlert("Failed SignUp", message: errorMessage)
                self.view.frame.origin.y = 0
            }
        }
    }
}
