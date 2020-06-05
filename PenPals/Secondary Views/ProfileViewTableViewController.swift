//
//  ProfileViewTableViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/21/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

class ProfileViewTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    // user that is passed through to get the correct contact view
    var user: FUser?
    var hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when view is opened..
        setupUI()
        
    }
    
    
    ///MARK: IBActions
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
            let messageVC = MessageViewController()
            messageVC.titleName = user!.firstname
            messageVC.membersToPush = [FUser.currentId(), user!.objectId]
            messageVC.memberIds = [FUser.currentId(), user!.objectId]
            
            messageVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            messageVC.isGroup = false
            messageVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(messageVC, animated: true)
            
        } else {
            
            self.hud.textLabel.text = "This user is not available for chat!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 1.5, animated: true)
            
        }
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId) {
            
            // find the index of the currently blocked user in the blockedUsers array
            currentBlockedIds.remove(at: currentBlockedIds.index(of: user!.objectId)!)
        } else {
            // or add them to the blocked array
            currentBlockedIds.append(user!.objectId)
        }
        
        //
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error updating user \(error!.localizedDescription)")
                return
            }
            
            self.updateBlockStatus()
        }
        
        blockUser(userToBlock: user!)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // remove tableview cell section headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    //initalize an empty view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //get rid of first cell header so theres no space between top of the view and the first cell
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //0 = first cell section
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: Setup UI
    
    func setupUI() {
        
        //make sure there is a user clicked on
        if user != nil {
            
            self.title = "Profile"
            
            
            //get currently selected user's information from database
            fullNameLabel.text = user!.fullname
            
            getLanguage(user: user)

            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    
                    // check if image is the same as user's real image and then make it round
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    func updateBlockStatus() {
        
        // if it is not the current user logged in
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
        }
        
        // if the user is in the current user's array of blocked users
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }
    
    func getLanguage(user: FUser?) {
        
        var lang = user?.language
        
        //        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        if lang == "ar" {
            languageLabel.text = "Arabic"
        } else if lang == "bn" {
            languageLabel.text = "Bengal"
        } else if lang == "zh" {
            languageLabel.text = "Chinese"
        } else if lang == "nl" {
            languageLabel.text = "Dutch"
        } else if lang == "en" {
            languageLabel.text = "English"
        } else if lang == "fr" {
            languageLabel.text = "French"
        } else if lang == "de" {
            languageLabel.text = "German"
        } else if lang == "ht" {
            languageLabel.text = "Haitian"
        } else if lang == "hi" {
            languageLabel.text = "Hindi"
        } else if lang == "it" {
            languageLabel.text = "Italian"
        } else if lang == "ja" {
            languageLabel.text = "Japenese"
        } else if lang == "ko" {
            languageLabel.text = "Korean"
        } else if lang == "ms" {
            languageLabel.text = "Malay"
        } else if lang == "pt" {
            languageLabel.text = "Porteguese"
        } else if lang == "ro" {
            languageLabel.text = "Romanian"
        } else if lang == "ru" {
            languageLabel.text = "Russian"
        } else if lang == "es" {
            languageLabel.text = "Spanish"
        }
    }
    
}
