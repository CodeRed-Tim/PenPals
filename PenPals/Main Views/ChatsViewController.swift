//
//  ChatsViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 3/5/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    //MARK: IBActions
    
    @IBAction func createNewChat(_ sender: Any) {
        
        //segue to contact user's profile view once cell is tapped
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactsTableView") as! ConactsTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
        
        
        
    }
    
}
