//
//  PicturesCollectionViewCell.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/1/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
}
