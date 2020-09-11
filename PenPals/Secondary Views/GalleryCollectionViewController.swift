//
//  PicturesCollectionViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/1/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import IDMPhotoBrowser


class GalleryCollectionViewController: UICollectionViewController {

    var allImages: [UIImage] = []
    var allImageLinks: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Picture Gallery", comment: "")
        
        if allImageLinks.count > 0 {
            //download image
            downloadImages()
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PicturesCollectionViewCell
        
        cell.generateCell(image: allImages[indexPath.row])
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photos = IDMPhoto.photos(withImages: allImages)
        
        let browser = IDMPhotoBrowser(photos: photos)
        browser?.displayDoneButton = false
        //always users to slide from photo to photo
        browser?.setInitialPageIndex(UInt(indexPath.row))
        
        self.present(browser!, animated: true, completion: nil)
        
    }
    
    //MARK: Download images
    
    func downloadImages() {
        
        for imageLink in allImageLinks {
            
            downloadImage(imageUrl: imageLink) { (image) in
                
                if image != nil {
                    
                    // add image to array
                    self.allImages.append(image!)
                    //refresh
                    self.collectionView.reloadData()
                }
                
            }
            
        }
    }

}
