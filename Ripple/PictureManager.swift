//
//  PictureManager.swift
//  Ripple
//
//  Created by evgeny on 29.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import Parse
import SDWebImage
class PictureManager: NSObject {
    
    /*func loadPicture(picture: PFObject?, withCompletion completion: ((pictureImage: UIImage?) -> Void), prepareBlock: (() -> Void)? = nil) {
        
        func onLoadingFail() {
            let img = UIImage(named: "user_dafault_picture")
            completion(pictureImage: img);
        }
        
        guard let pic = picture else {
            onLoadingFail()
            return;
        }
        
        if let block = prepareBlock {
            block();
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
            do {
                try pic.fetchIfNeeded()
            } catch {
                onLoadingFail()
            }
            
            if let urlStr = picture!["imageURL"] as? String, let url = NSURL(string: urlStr) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { 
                    guard let imageData = NSData(contentsOfURL: url), let image = UIImage(data: imageData) else {
                        dispatch_async(dispatch_get_main_queue(), {
                            onLoadingFail()
                        })
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        completion(pictureImage: image)
                    })
                })
            }
        })
    }*/
    
    
    func loadPicture(picture: PFObject?, inImageView imageView: UIImageView?) {
        guard let picture = picture, let imageView = imageView else {
            return
        }

        imageView.image = UIImage(named: "user_dafault_picture")

        var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = CGPointMake(imageView.width * 0.5, imageView.height * 0.5)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        imageView.addSubview(activityIndicator)

        picture.fetchIfNeededInBackgroundWithBlock({ (pic, error) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { [weak imageView] in
                    guard let picture = pic, let imageView = imageView else {
                        return
                    }

                    imageView.sd_setImageWithURL(NSURL(string: (picture["imageURL"] as? String)!)) { [weak activityIndicator] (image, error, casheType, url) in
                        activityIndicator?.stopAnimating()
                        activityIndicator?.removeFromSuperview()
                        
                        if error != nil {
                            imageView.image = UIImage(named: "user_dafault_picture")
                        }
                    }
                })
            } else {
                 imageView.image = UIImage(named: "user_dafault_picture")
            }
        })
    }

    func loadPicture(picture: PFObject?, inButton button: UIButton?) {
        button!.setBackgroundImage(UIImage(named: "user_dafault_picture"), forState: .Normal)
        guard let pic = picture else {
            return
        }
        do {
            try pic.fetchIfNeeded()
        } catch {
            return
        }
        
        button?.sd_setBackgroundImageWithURL(NSURL(string: (picture!["imageURL"] as? String)!), forState:  .Normal)
    }
}
