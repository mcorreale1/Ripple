//
//  SettingsMain.swift
//  Ripple
//
//  Created by Adam Gluck on 1/5/16.
//  Copyright (c) 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem
import QuickLook

class SettingsMain: UITableViewController, QLPreviewControllerDataSource,QLPreviewControllerDelegate {
    
    @IBOutlet weak var accountPrivacyLabel: UILabel!
    @IBOutlet weak var pushNotificationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var changePassword: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var termsOfUseLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!
    
    @IBOutlet weak var logOutLabel: UILabel!
   
    var docName: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        
    }
    
    func prepareView() {
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.whiteColor()
        let titleColor = UIColor.init(red: 0/255, green:0/255, blue: 0/255, alpha: 1)
        nav?.tintColor = titleColor
        nav?.titleTextAttributes = ([NSForegroundColorAttributeName: titleColor])
        privacySwitch.on = UserManager().currentUser().isPrivate
        self.title = NSLocalizedString("Settings", comment: "Settings")
        accountPrivacyLabel.text = NSLocalizedString("Accountprivacy", comment: "Accountprivacy")
        pushNotificationLabel.text = NSLocalizedString("Pushnotification", comment: "Pushnotification")
        languageLabel.text = NSLocalizedString("Language", comment: "Language")
        changePassword.text = NSLocalizedString("ChangePassword", comment: "ChangePassword")
        termsOfUseLabel.text = NSLocalizedString("TermsofUse", comment: "TermsofUse")
        contactUsLabel.text = NSLocalizedString("ContactUs", comment: "ContactUs")
        logOutLabel.text = NSLocalizedString("LofOut", comment: "LofOut")
    }
    


    @IBOutlet weak var privacySwitch: UISwitch!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let path = NSBundle.mainBundle().pathForResource(docName, ofType: "docx")
        let url = NSURL.fileURLWithPath(path!)
        
        return url
    }
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6.0
    }
  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                self.showChangeLanguageViewController()
            }
            if indexPath.row == 3 {
                if FBSDKAccessToken.currentAccessToken() != nil{
                    showErrorChangePasswordAlert()
                    tableView.reloadData()
                } else {
                    self.showChangePasswordViewController()
                }
            }
            if indexPath.row == 4 {
                docName = "Privacy Policy"
                let preview = QLPreviewController()
                 preview.dataSource = self
                 preview.delegate = self
                self.presentViewController(preview, animated: false, completion: nil)
            }
            if indexPath.row == 5 {
                docName = "Terms of Use"
                let preview = QLPreviewController()
                preview.dataSource = self
                preview.delegate = self
                self.presentViewController(preview, animated: false, completion: nil)
                
                //self.showTermsOfUseViewController()
            }
            if indexPath.row == 6 {
                let email = "jettiinc123@gmail.com"
                let url = NSURL(string: "mailto:\(email)")
                UIApplication.sharedApplication().openURL(url!)
            }
        }
        if indexPath.row == 0 && indexPath.section == 1 {
            API().logout()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.toLogin()
        }
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  
    @IBAction func privacyChanged(sender: AnyObject) {
        UserManager().currentUser().isPrivate = privacySwitch.on
        UserManager().currentUser().save { (_, _) in }
    }
    
    func showChangeLanguageViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let changeLanguageViewController = storyboard.instantiateViewControllerWithIdentifier("ChangeLanguageViewController") as! SettingsTheLanguageViewController
        navigationController?.showViewController(changeLanguageViewController, sender: self)
    }
    
    func showChangePasswordViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let changePasswordViewController = storyboard.instantiateViewControllerWithIdentifier("ChangePasswordViewController") as! SettingsChangePasswordViewController
        navigationController?.showViewController(changePasswordViewController, sender: self)
    }
    
    func showPrivacyPolicyViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let privacyPolicyViewController = storyboard.instantiateViewControllerWithIdentifier("PrivacyPolicyViewController") as! SettingPrivacyPolicy
        navigationController?.showViewController(privacyPolicyViewController, sender: self)
    }
    
    func showTermsOfUseViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let termsOfUseViewController = storyboard.instantiateViewControllerWithIdentifier("TermsOfUseViewController") as! SettingsTermofUse
        navigationController?.showViewController(termsOfUseViewController, sender: self)
    }

    
    func showErrorChangePasswordAlert(){
        let title = "Error"
        let message = "You can not change your password"
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default   , handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
}
