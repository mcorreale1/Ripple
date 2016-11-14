//
//  SettingPrivacyPolicy.swift
//  Ripple
//
//  Created by Adam Gluck on 1/5/16.
//  Copyright (c) 2016 Adam Gluck. All rights reserved.
//

import UIKit
import QuickLook

class SettingPrivacyPolicy: BaseViewController, QLPreviewControllerDataSource,QLPreviewControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy Policy"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func backTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func setPrivacyPolicy() {
        let preview = QLPreviewController()
        preview.dataSource = self
        preview.delegate = self
        self.presentViewController(preview, animated: true, completion: nil)
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let path = NSBundle.mainBundle().pathForResource("privacy", ofType: "docx")
        let url = NSURL.fileURLWithPath(path!)
        
        return url
    }
}
