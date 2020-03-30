//
//  OutgoingMessages.swift
//  PenPals
//
//  Created by MaseratiTim on 3/29/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

class OutgoingMessages {
    
    let messageDictionary: NSMutableDictionary
    
    //MARK: Initializers
    
    //text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        // intialize dictionary
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARk: SendMessage
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], memberToPush: [String]) {
        
        //generate unique ID for chat that will neevr be repeated
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        //loop to get all the members in the "chatroom"
        for memberId in memberIds {
            
            //create "Message" in firebase
            // creates a message copy for each person in chatroom
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        //update recent to display the latest message
        
        
        
        //send push notification to the reciever
    }
}
