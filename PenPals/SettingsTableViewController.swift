//
//  SettingsTableViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 3/3/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    //MARK: IBActions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
    
    
        
        FUser.logOutCurrentUser { (success) in
            
            if success {
                self.showLoginView()
            }
        }
        
    }
    // take user back to welcome scrren
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstView")

        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    
    
}
