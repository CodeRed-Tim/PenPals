//
//  IncomingMessages.swift
//  PenPals
//
//  Created by MaseratiTim on 3/30/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        // set the variable
        collectionView = collectionView_
    }
    
    //MARK: Create Message
    
    // ass through message from Firbase, see if message if text, video, picture
    // creates required JSQ message
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        //check message type
        
        switch type {
        case kTEXT:
            // possible location to run translation method here
            // example: translateMessage(message);
            // create text message
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            //create a picture message
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            //create a video message
            message = createVideoMessage(messageDictionary: messageDictionary)
        default:
            print("Unknown message type")
        }
        
        // message has been created
        if message != nil {
            return message
        }
        
        return nil
    }
    
    //MARK: Create Message types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        // does the date exist
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                // create new date
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            // create new date
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        // possible location to run translation method here
        // example: translateMessage(message);
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    func createPictureMessage(messageDictionary: NSDictionary)
        -> JSQMessage {
            
            let name = messageDictionary[kSENDERNAME] as? String
            let userId = messageDictionary[kSENDERID] as? String
            
            var date: Date!
            
            // does the date exist
            if let created = messageDictionary[kDATE] {
                if (created as! String).count != 14 {
                    // create new date
                    date = Date()
                } else {
                    date = dateFormatter().date(from: created as! String)
                }
            } else {
                // create new date
                date = Date()
            }
            
            let mediaItem = PhotoMediaItem(image: nil)
            //outgoing or incoming
            mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
            
            //download image
            downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
                if image != nil {
                    //set image
                    mediaItem?.image = image!
                    //refresh collection view
                    self.collectionView.reloadData()
                    
                }
            }
            return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createVideoMessage(messageDictionary: NSDictionary)
        -> JSQMessage {
            
            let name = messageDictionary[kSENDERNAME] as? String
            let userId = messageDictionary[kSENDERID] as? String
            
            var date: Date!
            
            // does the date exist
            if let created = messageDictionary[kDATE] {
                if (created as! String).count != 14 {
                    // create new date
                    date = Date()
                } else {
                    date = dateFormatter().date(from: created as! String)
                }
            } else {
                // create new date
                date = Date()
            }
            
            let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
            
            let mediaItem =  VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
            
            //download video
            downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
                
                let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                mediaItem.status = kSUCCESS
                mediaItem.fileURL = url
                
                imageFromData(pictureData: messageDictionary[kPICTURE] as! String) { (image) in
                    
                    if image != nil {
                        mediaItem.image = image!
                        self.collectionView.reloadData()
                    }
                }
                self.collectionView.reloadData()
            }
            
            
            return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    //MARK: Helper
    
    //cheks if it is outgoing or incoming message
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        return senderId == FUser.currentId()
    }
}
