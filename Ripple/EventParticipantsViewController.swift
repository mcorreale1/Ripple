//
//  EventParticipantsViewController.swift
//  Ripple
//
//  Created by Alexander Kurbanov on 05/09/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation
import Parse
import ORLocalizationSystem

class EventParticipantsViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let cellId = "participantId"
    
    var participants: [PFUser]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib.init(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: EventParticipantsViewController.cellId)
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("Going", comment: "Going")
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(EventParticipantsViewController.cellId) as! FollowingTableViewCell
        let user = self.participants![indexPath.row]
        
        cell.titleLabel.text = user["fullName"] as? String
        cell.descriptionLabel.text = nil
        let picture = user["picture"] as? PFObject
        PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = participants?[indexPath.row] {
            showProfileViewController(user)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
}
