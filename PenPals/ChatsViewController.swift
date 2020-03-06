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
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
        
        
        
    }
    
}
