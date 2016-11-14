//
//  ORCropImageViewControllerDefaultDownloadDelegate.swift
//  ORCropImageExample
//
//  Created by Nikita Egoshin on 03.05.16.
//  Copyright © 2016 Omega-R. All rights reserved.
//

import UIKit

class ORCropImageViewControllerDefaultDownloadDelegate: NSObject, ORCropImageViewControllerDownloadDelegate {
    
    func downloadImage(fromURL url: NSURL, completion: (image: UIImage?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            guard let data = NSData(contentsOfURL: url) else {
                completion(image: nil, error: nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(image: nil, error: nil)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image, error: nil)
            })
        }
    }
}
