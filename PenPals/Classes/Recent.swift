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
    createRecent(members: members, chatRoomId: chatRoomId, withUserUserName: "", type: kPRIVATE, users: [user1, user2], avatarOfGroup: nil)
    return chatRoomId
}



func createRecent(members: [String], chatRoomId: String, withUserUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
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
                    
                    // remove the most recent message object
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.index(of: currentUserId as! String)!)
                    }
                }
            }
            
        }
        
        
        for userId in tempMembers {
            
            //create recent items
            // takes on whatever objects was given in the CreateRecenChat method
            createRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserName: withUserUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
        
    }
 
}


func createRecentItem(userId: String, chatRoomId: String, members: [String], withUserUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    //creates reference to Recent in firebase
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent: [String : Any]!
    
    
    if type == kPRIVATE {
        //private
        
        var withUser: FUser?
        
        if users != nil && users!.count > 0 {
            
            // check which user you are creating the chat for
            if userId == FUser.currentId() {
                //for current user
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
        
        // every object needed to create a recent chat
        recent = [kRECENTID : recentId, kUSERID : userId, kCHATROOMID : chatRoomId, kMEMBERS : members, kMEMBERSTOPUSH : members, kWITHUSERFULLNAME : withUser!.fullname, kWITHUSERUSERID : withUser!.objectId, kLASTMESSAGE : "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR : withUser!.avatar] as [String:Any]
        
        
    } else {
        
        //group
        
        if avatarOfGroup != nil {
            
            recent = [kRECENTID : recentId, kUSERID : userId, kCHATROOMID : chatRoomId, kMEMBERS : members, kMEMBERSTOPUSH : members, kWITHUSERFULLNAME : withUserUserName, kLASTMESSAGE : "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR : avatarOfGroup!] as [String:Any]
        }
    }
    
    
    //save recent chat in firebase
    localReference.setData(recent)
}


//Restart Chat

func restartRecentChat(recent: NSDictionary) {
    
    if recent[kTYPE] as! String == kPRIVATE {

        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    
    if recent[kTYPE] as! String == kGROUP {

        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERFULLNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
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
                
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
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
    
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}


//Delete recent

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    
    // check for recent ID

    if let recentId = recentChatDictionary[kRECENTID] {
        
        reference(.Recent).document(recentId as! String).delete()
    }
}


//Clear counter

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

//group

//func startGroupChat(group: Group) {
//
//    let chatRoomId = group.groupDictionary[kGROUPID] as! String
//    let members = group.groupDictionary[kMEMBERS] as! [String]
//
//    createRecent(members: members, chatRoomId: chatRoomId, withUserUserName: group.groupDictionary[kNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: group.groupDictionary[kAVATAR] as? String)
//}

func createRecentsForNewMembers(groupId: String, groupName: String, membersToPush: [String], avatar: String) {
    
    createRecent(members: membersToPush, chatRoomId: groupId, withUserUserName: groupName, type: kGROUP, users: nil, avatarOfGroup: avatar)
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

//BlockUser

func blockUser(userToBlock: FUser) {
    
    let userId1 = FUser.currentId()
    let userId2 = userToBlock.objectId
    
    var chatRoomId = ""
    
    let value = userId1.compare(userId2).rawValue
    
    // whether user1 starts convo with user 2 or vice verse that
    //chatroom id will equal the same
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
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



