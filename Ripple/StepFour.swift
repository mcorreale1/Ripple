//
//  StepFour.swift
//  Ripple
//
//  Created by jesse pelzar on 2/23/17.
//  Copyright © 2017 Adam Gluck. All rights reserved.
//

import UIKit


class StepFour : UIViewController {
    var window: UIWindow?
    @IBOutlet weak var startButton: UIButton!
    
   
    
    @IBAction func startButtonPressed(sender: AnyObject) {
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarfromStart = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! BaseTabBarViewController
         self.tabBarSelectIndex(2)
       // mainTabBarController
       // mainTabBarController.selectedIndex = 2
        self.navigationController?.pushViewController(tabBarfromStart, animated: true)
    }
    
    func tabBarSelectIndex(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! BaseTabBarViewController
        window?.rootViewController = mainTabBarController
        mainTabBarController.selectedIndex = index
    }
}
   
