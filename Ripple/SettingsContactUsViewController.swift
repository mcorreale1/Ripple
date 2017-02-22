//
//  SettingsContactUsViewController.swift
//  Ripple
//
//  Created by evgeny on 15.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import ORLocalizationSystem

class SettingsContactUsViewController: BaseViewController {


    @IBOutlet weak var emailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailButton.titleLabel?.text = "info@jettiapps.com"
        emailButton.setTitle("info@jettiapps.com", forState: UIControlState.Normal)
        emailButton.sizeToFit()
        emailButton.height = emailButton.height * 1.1
        emailButton.width = emailButton.width * 1.1
        emailButton.center.x = self.view.centerX
        emailButton.center.y = CGFloat(self.view.center.y / 2)
        emailButton.backgroundColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        /*let email = "foo@bar.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url)*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.title = NSLocalizedString("ContactUs", comment: "ContactUs")
    }
    
    // MARK: - Actions
    
    @IBAction func emailButtonTouch(sender: UIButton) {
        let email = "info@jettiapps.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
}
