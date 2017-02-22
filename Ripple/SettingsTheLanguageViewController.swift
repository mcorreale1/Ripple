//
//  SettingsTheLanguageViewController.swift
//  
//
//  Created by HeroinoOp on 21.09.16.
//
//

import UIKit
import ORLocalizationSystem

class SettingsTheLanguageViewController: UITableViewController {

    let languageList :[String] = ["English", "Dutch", "Russian", "French", "Spanish", "Swedish", "Polish", "English", "Korean", "Italian", "Suomi", "German"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ORLocalizationSystem.sharedInstanse().getLanguage()
        //ORLocalizationSystem.sharedInstanse().setLanguage("ru")
        //NSLocalizedString("test", comment: "test")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("Language", comment: "Language")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return languageList.count
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        cell.textLabel?.text = languageList[indexPath.row]
        if indexPath.row == 0 {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        for index in 0...languageList.count - 1 {
//            let cellTmp  = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
//            cellTmp?.accessoryType = .None
//        }
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        cell?.accessoryType = .Checkmark
//        if languageList[indexPath.row] == "English" {
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            appDelegate.changeLaguageApp()
//        }
    }

}
