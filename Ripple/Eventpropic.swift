//
//  Eventpropic.swift
//  Ripple
//
//  Created by Adam Gluck on 2/10/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class EventPictureViewController: BaseViewController {
    
    @IBOutlet weak var showImagePickerButton: UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    
    var event: RippleEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextTouched(sender: AnyObject) {
        if showImagePickerButton.hidden == true {
            performSegueWithIdentifier("showSendInvitations", sender: self)
        } else {
            showAlert("Error", message: "Please upload a profile picture!")
        }
    }
    
    @IBAction func showImagePickerControllerTouched(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        showImagePickerButton.hidden = true
        eventImageView.image = image
        
        
        // TODO here is some imageFile prop
//        let imageData = UIImageJPEGRepresentation(eventImageView.image!, 0.5)
//        let imageFile = PFFile(name: "image.png", data: imageData!) // TODO Parce Files
//        event?.imageFile = imageFile
    }
}
