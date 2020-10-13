//
//  PushNotifications.swift
//  PenPals
//
//  Created by MaseratiTim on 10/12/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import OneSignal

func sendPushNotification(memberToPush: [String], message: String) {
    
    let updatedMembers = removeCurrentUserFromMemberArray(members: memberToPush)
    
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        
        let currentUser = FUser.currentUser()!
        
        var message: String
        
        message = NSLocalizedString("Notification", comment: "")
        
        //where push notifcation happens
        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \(currentUser.lastname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1", "include_player_ids" : userPushIds])
        
    }
    
}

func removeCurrentUserFromMemberArray(members: [String]) -> [String] {
    
    var updatedMembers : [String] = []
    
    // check if same id as current user
    for memberId in members {
        
        if memberId != FUser.currentId() {
            updatedMembers.append(memberId)
        }
        
    }
    
    return updatedMembers
    
}

func getMembersToPush(members: [String], completion: @escaping (_ usersArray: [String]) -> Void) {
    
    var pushIds: [String] = []
    var count = 0
    
    for memberId in members {
        
        reference(.User).document(memberId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else { completion(pushIds); return }
            
            if snapshot.exists {
                
                let userDictionary = snapshot.data() as! NSDictionary
                
                let fUser = FUser.init(_dictionary: userDictionary)
                
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count {
                    //gone through whole array
                    completion(pushIds)
                }
                
            } else {
                
                completion(pushIds)
                
            }
        }
    }
    
}
