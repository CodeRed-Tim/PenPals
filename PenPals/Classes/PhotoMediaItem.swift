//
//  PhotoMediaItem.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/31/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import JSQMessagesViewController


//For formatting incoming/outgoing images to make them look better whether their landscape or protrait

class PhotoMediaItem: JSQPhotoMediaItem {
    
    override func mediaViewDisplaySize() -> CGSize {
        
        let defaultSize: CGFloat = 256
        
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        
        //if we have a valid image
        if self.image != nil && self.image.size.height > 0 && self.image.size.width > 0 {
            
            let aspect: CGFloat = self.image.size.width / self.image.size.height
            
            // if width > height then image = landscape
            if (self.image.size.width > self.image.size.height) {
                
                thumbSize = CGSize(width: defaultSize, height: defaultSize / aspect)
            } else {
                //portrait
                thumbSize = CGSize(width: defaultSize * aspect, height: defaultSize)
            }
        }
        return thumbSize
    }
}
