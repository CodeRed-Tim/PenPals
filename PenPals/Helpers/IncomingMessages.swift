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
            print("create picture message")
        case kVIDEO:
            //create a video message
            print("create video message")
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
    
}
