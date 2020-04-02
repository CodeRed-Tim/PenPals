//
//  Recent.swift
//  PenPals
//
//  Created by MaseratiTim on 3/24/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    
    var chatRoomId = ""
    
    let value = userId1.compare(userId2).rawValue
    
    // whether user1 starts convo with user 2 or vice verse that
    //chatroom id will equal the same
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    
    
    //create recent chats
    createRecentChat(members: members, chatRoomId: chatRoomId, withUserName: "", type: kPRIVATE, users: [user1, user2], avatarOfGroup: nil)
    
    return chatRoomId
    
}

func createRecentChat(members: [String], chatRoomId: String, withUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    var tempMembers = members
    
    // when the chatRoomId is equal to the chatRoomId stored in firebase
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        
        guard let snapshot = snapshot else { return }
        
        // if there is message data
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                // let the most recently shown messge be the
                //most recent message from firebase
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserId = currentRecent[kUSERID] {
                    
                    if tempMembers.contains(currentUserId as! String) {
                        
                        // remove the most recent message object
                        tempMembers.remove(at: tempMembers.index(of: currentUserId as! String)!)
                    }
                    
                }
                
            }
            
        }
        
        for userId in tempMembers {
            //create recent items
            // takes on whatever objects was given in the CreateRecenChat method
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserName: withUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
        
    }
    
}

func createRecentItems(userId: String, chatRoomId: String, members: [String], withUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    // creates reference to Recent in firebase
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent: [String : Any]!
    
    if type == kPRIVATE {
        //private chat
        
        var withUser: FUser?
        
        if users != nil && users!.count > 0 {
            
            // check which user you are creating the chat for
            if userId == FUser.currentId() {
                //for current user
                
                withUser = users!.last!
            } else {
                
                withUser = users!.first
            }
        }
        
        // every object needed to create a recent chat
        recent = [kRECENTID : recentId, kUSERID : userId, kCHATROOMID : chatRoomId, kMEMBERS : members, kMEMBERSTOPUSH : members, kWITHUSERFULLNAME : withUser!.fullname, kWITHUSERUSERID : withUser!.objectId, kLASTMESSAGE : "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR : withUser!.avatar] as [String : Any]
        
    } else {
        // group chaat
        
        if avatarOfGroup != nil {
            recent = [kRECENTID : recentId, kUSERID : userId, chatRoomId : chatRoomId, kMEMBERS : members, kMEMBERSTOPUSH : members, kWITHUSERFULLNAME : withUserName, kLASTMESSAGE : "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR : avatarOfGroup!] as [String : Any]
        }
    }
    
    //save recent chat in firebase
    localReference.setData(recent)
    
}


//Restart Chat

func restartRecentChat(recent: NSDictionary) {
    
    if recent[kTYPE] as! String == kPRIVATE {
        
        createRecentChat(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    
    if recent[kTYPE] as! String == kGROUP {
        
        createRecentChat(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: recent[kWITHUSERUSERNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
    
}

//update last message in recent

//called everytime we send a message (called in OUtgoingMessages)
func updateRecents(chatRoomId: String, lastMessage: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if currentRecent[kUSERID] as? String == FUser.currentId() {
                    
                    updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
                }
            }
        }
    }
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatter().string(from: Date())
    
    //set counter
    //check if there are any unread messages
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as? String != FUser.currentId() {
        counter += 1
    }
    
    //acces what we need to update
    let values = [kLASTMESSAGE : lastMessage, kCOUNTER : counter, kDATE : date] as [String : Any]
    
    reference(.Recent)
        .document(recent[kRECENTID] as! String).updateData(values)
}


// Delete recent chat

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    
    // check for recent ID
    if let recentId = recentChatDictionary[kRECENTID] {
        
        reference(.Recent).document(recentId as! String).delete()
    }
}

//clear counter

//give chatroom acces to Recent class
func clearRecentCounter(chatRoomId: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if currentRecent[kUSERID] as? String == FUser.currentId() {
                    
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
        }
    }
}

func clearRecentCounterItem(recent: NSDictionary) {
    
    //update message counter
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER : 0])
}

func updateExistingRecentWithNewValues(chatRoomId: String, members: [String], withValues: [String : Any]) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let recent = recent.data() as NSDictionary
                
                updateRecent(recentId: recent[kRECENTID] as! String, withValues: withValues)
            }
        }
    }
}

func updateRecent(recentId: String, withValues: [String : Any]) {
    
    reference(.Recent).document(recentId).updateData(withValues)
    
}

//Block user

func blockUser(userToBlock: FUser) {
    
    let userId = FUser.currentId()
    let blockedUserId = userToBlock.objectId
    
    var chatRoomId = ""
    
    let value = userId.compare(blockedUserId).rawValue
    
    // whether user1 starts convo with user 2 or vice verse that
    //chatroom id will equal the same
    if value < 0 {
        chatRoomId = userId + blockedUserId
    } else {
        chatRoomId = blockedUserId + userId
    }
    
    getRecentsFor(chatRoomId: chatRoomId)
}

func getRecentsFor(chatRoomId: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
           
           guard let snapshot = snapshot else { return }
           
           if !snapshot.isEmpty {
               
               for recent in snapshot.documents {
                   
                   let recent = recent.data() as NSDictionary
                   
                    //when user is bloked the chats get deleted
                deleteRecentChat(recentChatDictionary: recent)
               }
           }
       }

}



