//
//  ChatsViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 3/5/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    
    //for lsitening for new messages
    var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadRecentChats()
    }
    

    //MARK: IBActions
    
    @IBAction func createNewChat(_ sender: Any) {
        
        //segue to contact user's profile view once cell is tapped
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactsTableView") as! ConactsTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
        
        
        
    }
    
    //MARK: TableViewDataSource (functions required for table view)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        let recent = recentChats[indexPath.row]
        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        
        
        return cell
    }
    
    //MARK: LoadRecentChats
    
    func loadRecentChats() {
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            //stops duplicating the recent messages
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                // sort recent messages by date
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    
                    // if last message is empty, if there is a chatroomID and
                    //if recent has an ID to make sure it isnt a corrupt file
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        
                        //add it to recent chat array
                        self.recentChats.append(recent)
                    }
                }
                
                self.tableView.reloadData()
            }
            
        })
        
    }
    
    
    
}
