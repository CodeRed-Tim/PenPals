//
//  BackgroundCollectionViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 4/22/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD

private let reuseIdentifier = "Cell"

class BackgroundCollectionViewController: UICollectionViewController {

    var hud = JGProgressHUD(style: .dark)
    
    var backgrounds: [UIImage] = []
    let userDefaults = UserDefaults.standard
    
    private let imageNamesArray = ["bg0", "bg1", "bg2", "bg3", "bg4", "bg5", "bg6", "bg7", "bg8", "bg9", "bg10", "bg11", "bg12", "bg13", "bg14"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetToDefault))
        self.navigationItem.rightBarButtonItem = resetButton
        
        setupImageArray()
    }

    

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BackgroundCollectionViewCell
        
            cell.generateCell(image: backgrounds[indexPath.row])
        
            return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        userDefaults.set(imageNamesArray[indexPath.row], forKey: kBACKGROUNDIMAGE)
        userDefaults.synchronize()

        hud.dismiss()
        hud.textLabel.text = "Set!"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss()
    }
    
    //MARK: IBActions
    
    @objc func resetToDefault() {
        userDefaults.removeObject(forKey: kBACKGROUNDIMAGE)
        userDefaults.synchronize()

        hud.dismiss()
        hud.textLabel.text = "Set!"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss()
    }


    //MARK: Helpers
    
    func setupImageArray() {
        
        for imageName in imageNamesArray {
            let image = UIImage(named: imageName)
            
            if image != nil {
                backgrounds.append(image!)
            }
        }
    }


}

