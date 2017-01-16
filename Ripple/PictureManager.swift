//
//  PictureManager.swift
//  Ripple
//
//  Created by evgeny on 29.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//com

import UIKit
import SDWebImage

class PictureManager: NSObject {
    
    func loadPicture(picture: Pictures?, inImageView imageView: UIImageView?) {
        guard let picture = picture, let imageView = imageView else {
            return
        }

        imageView.image = UIImage(named: "user_dafault_picture")
        
        dispatch_async(dispatch_get_main_queue(), { [weak imageView] in
            guard let imageView = imageView else {
                return
            }
            
            guard picture.imageURL != nil else {
                return
            }
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = CGPointMake(imageView.width * 0.5, imageView.height * 0.5)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            activityIndicator.startAnimating()
            imageView.addSubview(activityIndicator)
            
            imageView.sd_setImageWithURL(NSURL(string: picture.imageURL!), completed: { [weak activityIndicator] (image, error, casheType, url) in
                activityIndicator?.stopAnimating()
                activityIndicator?.removeFromSuperview()
                
                if error != nil {
                    imageView.image = UIImage(named: "user_dafault_picture")
                }
            })
        })
    }

    func loadPicture(picture: Pictures?, inButton button: UIButton?) {
        button!.setBackgroundImage(UIImage(named: "user_dafault_picture"), forState: .Normal)
        
        guard let pic = picture else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), { [weak button] in
            guard let button = button else {
                return
            }
            
            guard pic.imageURL != nil else {
                return
            }
            
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = CGPointMake(button.width * 0.5, button.height * 0.5)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            activityIndicator.startAnimating()
            button.addSubview(activityIndicator)
            
            button.sd_setBackgroundImageWithURL(NSURL(string: pic.imageURL!), forState: .Normal, completed: { (image, error, cacheType, url) in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            })
        })
    }
    
    func downloadImage(fromURL url: String, completion: ((UIImage?, NSError?) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            guard let imageURL = NSURL(string: url), let imageData = NSData(contentsOfURL: imageURL), let image = UIImage(data: imageData) else {
                completion(nil, nil)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(image, nil)
            })
        }
    }
    
    // MARK: - Remote Image Storage handlers
    
    func uploadImage(image: UIImage, withCompletion completion: (String?, String?, NSError?) -> Void) {
        let imgData = UIImagePNGRepresentation(image)
        let path = "images/\(NSUUID().UUIDString)"
        
        Backendless.sharedInstance().fileService.upload(path, content: imgData, overwrite: true, response: { (backendlessFile) in
            completion(backendlessFile.fileURL, path, nil)
        }, error: { (fault) in
            completion(nil, nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func deleteImage(withStoragePath storagePath: String, completion: (Bool, NSError?) -> Void) {
        Backendless.sharedInstance().fileService.remove(storagePath, response: { (_) in
            completion(true, nil)
        }, error:  { (fault) in
            completion(false, ErrorHelper().convertFaultToNSError(fault))
        })
    }
}
