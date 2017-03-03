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

   static let cellId = "OrganizationTableViewCell"
    
    var organizationArray : [Organizations]?
    var tempOrg : [Organizations] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gotta figure this out
        
        self.tableView.registerNib(UINib.init(nibName: "OrganizationTableViewCell", bundle: nil), forCellReuseIdentifier: ChooseYourOrg.cellId)
        
        let nibActionCell = UINib(nibName: "ActionTableViewCell", bundle: nil)
        tableView.registerNib(nibActionCell, forCellReuseIdentifier: "ActionTableViewCell")
        tableView.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        OrganizationManager().organizationsForUser(UserManager().currentUser(), completion: {[weak self] (org) in
            self?.tempOrg = org
            if self?.tempOrg.count != 0{
            self?.tempOrg.sortInPlace { (org1: Organizations, org2: Organizations) -> Bool in
                let name1 = org1.name
                let name2 = org2.name
                return name1?.lowercaseString < name2?.lowercaseString
            }
            self!.organizationArray = self!.tempOrg
             print(self!.organizationArray)
            self?.tableView.reloadData()
            }
            })
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("Organizations", comment: "Organizations")
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return organizationArray?.count ?? 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return organizationArray?.count ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if organizationArray != nil
        {
            print("not here")
        let cell = tableView.dequeueReusableCellWithIdentifier(ChooseYourOrg.cellId) as! OrganizationTableViewCell
        let org = organizationArray![indexPath.row]
        
        cell.nameOrganizationLabel.text = org.name
        let picture = org.picture
            cell.roleInOrganizationLabel.text = nil
        PictureManager().loadPicture(picture, inImageView: cell.organizationPictureImageView)
        
        return cell
        }
        else
        {
        print("got here")
        let cell = tableView.dequeueReusableCellWithIdentifier("ActionTableViewCell") as! ActionTableViewCell
        cell.titleLabel.text = NSLocalizedString("Make an organization", comment: "Make an organization")
        
        return cell
        }
    }
    

    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if organizationArray != nil
        {
        if let org = organizationArray?[indexPath.row] {
            showCreateEventViewController(org)
        }
        }
        else
        {
        showOrganizationProfileViewController(nil, isNewOrg: true, fromInvite: false)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }


}
