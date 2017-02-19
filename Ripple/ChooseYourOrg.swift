//
//  ChooseYourOrg.swift
//  Ripple
//
//  Created by Adam Gluck on 2/17/17.
//  Copyright © 2017 Adam Gluck. All rights reserved.
//

import Foundation
import ORLocalizationSystem

class ChooseYourOrg : BaseViewController, UITableViewDataSource, UITableViewDelegate {

    static let cellId = "chooseOrgId"
    
    var organizationArray = [Organizations]?()
    var tempOrg = [Organizations]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.tableView.registerNib(UINib.init(nibName: "ChooseOrg", bundle: nil), forCellReuseIdentifier: ChooseYourOrg.cellId)
        
        OrganizationManager().organizationForUser(UserManager().currentUser(), completion: {[weak self] (org) in
            self!.tempOrg = org
            self?.tempOrg.sortInPlace { (org1: Organizations, org2: Organizations) -> Bool in
                let name1 = org1.name
                let name2 = org2.name
                return name1?.lowercaseString < name2?.lowercaseString
            }
            self!.organizationArray = self!.tempOrg
             print(self!.organizationArray)
            self?.tableView.reloadData()
            })
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("Organizations", comment: "Organizations")
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizationArray!.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(EventParticipantsViewController.cellId) as! FollowingTableViewCell
        let org = organizationArray![indexPath.row]
        
        cell.titleLabel.text = org.name
        cell.descriptionLabel.text = nil
        let picture = org.picture
        PictureManager().loadPicture(picture, inImageView: cell.pictureImageView)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let org = organizationArray?[indexPath.row] {
            showCreateEventViewController(org)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }


}
