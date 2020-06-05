//
//  BackgroundCollectionViewCell.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/22/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
    
    
}
