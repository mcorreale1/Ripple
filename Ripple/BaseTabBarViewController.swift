//
//  BaseTabBarViewController.swift
//  Ripple
//
//  Created by evgeny on 26.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    
    //Look into what the tabbar view controller does
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for tabBarItem in tabBar.items! {
            //tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.tabBarSelectIndex((tabBar.items?.indexOf(item))!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
