//
//  VideoMessage.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/31/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class VideoMessage: JSQMediaItem {
    
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        videoImageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        
        //if video is ready to play or not
        if let st = status {
            
            if st == 1 {
                //status #1 means not ready to play
                return nil
            }
            
            if st == 2 && (self.videoImageView == nil) {
                
                let size = self.mediaViewDisplaySize()
                //check if video is outgoing or incoming
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                
                //play button
                let icon = UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: .white)
                
                let iconView = UIImageView(image: icon)
                
                iconView.frame = CGRect(x: 0, y:0, width: size.width, height: size.height)
                iconView.contentMode = .center
                
                let imageView = UIImageView(image: self.image!)
                
                //frame for thumbnail image view
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                
                self.videoImageView = imageView
                //created thumbnail with contraints to fill the view and places a play button over the top of it in the center
            }
        }
        return self.videoImageView
    }
}
