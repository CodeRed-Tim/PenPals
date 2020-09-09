//
//  BlockedUsersViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/22/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD

class BlockedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactsTableViewCellDelegate {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var blockedUsersArray: [FUser] = []
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        self.title = NSLocalizedString("Blocked Users", comment: "")
        notificationLabel.text = NSLocalizedString("Notifcation Label", comment: "")
        
        loadUsers()

    }
    
    //MARK: TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        notificationLabel.isHidden = blockedUsersArray.count != 0
        
        return blockedUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactsTableViewCell
        
        cell.delegate = self
        cell.generateCellWith(fUser: blockedUsersArray[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return NSLocalizedString("Unblock", comment: "")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var tempBlockedUsers = FUser.currentUser()!.blockedUsers
        
        let userIdToUnblock = blockedUsersArray[indexPath.row].objectId
        
        tempBlockedUsers.remove(at: tempBlockedUsers.index(of: userIdToUnblock)!)
        
        blockedUsersArray.remove(at: indexPath.row)
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : tempBlockedUsers]) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = "\(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 1.5, animated: true)
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: Load all blocked users
    
    func loadUsers() {
        
        ///access current user
        if FUser.currentUser()!.blockedUsers.count > 0 {
            
            hud.show(in: self.view)
            
            getUsersFromFirestore(withIds:  FUser.currentUser()!.blockedUsers) { (allBlockedUsers) in
                
                self.hud.dismiss()
                
                self.blockedUsersArray = allBlockedUsers
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    //MARK: User TableView Cell Delegate
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "prfileView") as! ProfileViewTableViewController
        
        profileVC.user = blockedUsersArray[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}
