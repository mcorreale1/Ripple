//
//  OnboardingPager.swift
//  Ripple
//
//  Created by jesse pelzar on 2/23/17.
//  Copyright © 2017 Adam Gluck. All rights reserved.
//


import UIKit
class OnboardingPager : UIPageViewController {
    
    func getStepZero() -> StepZero {
        return storyboard!.instantiateViewControllerWithIdentifier("StepZero") as! StepZero
    }
    
    func getStepOne() -> StepOne {
        return storyboard!.instantiateViewControllerWithIdentifier("StepOne") as! StepOne
    }
    
    func getStepTwo() -> StepTwo {
        return storyboard!.instantiateViewControllerWithIdentifier("StepTwo") as! StepTwo
    }
    
    func getStepThree() -> StepThree {
        return storyboard!.instantiateViewControllerWithIdentifier("StepThree") as! StepThree
    }
    
    func getStepFour() -> StepFour {
        return storyboard!.instantiateViewControllerWithIdentifier("StepFour") as! StepFour
    }
    
    
    override func viewDidLoad() {
        view.backgroundColor = .whiteColor()
        dataSource = self
        setViewControllers([getStepZero()], direction: .Forward, animated: false, completion: nil)
    }
    
}

extension OnboardingPager : UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController.isKindOfClass(StepFour) {
            return getStepThree()
        } else if viewController.isKindOfClass(StepThree){
            return getStepTwo()
        } else if viewController.isKindOfClass(StepTwo){
            return getStepOne()
        } else if viewController.isKindOfClass(StepOne) {
            return getStepZero()
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController.isKindOfClass(StepZero) {
            return getStepOne()
        } else if viewController.isKindOfClass(StepOne) {
            return getStepTwo()
        } else if viewController.isKindOfClass(StepTwo) {
            return getStepThree()
        } else if viewController.isKindOfClass(StepThree) {
            return getStepFour()
        } else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
