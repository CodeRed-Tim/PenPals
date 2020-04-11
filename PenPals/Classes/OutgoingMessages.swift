//
//  OutgoingMessages.swift
//  PenPals
//
//  Created by MaseratiTim on 3/29/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

class OutgoingMessages {
    
    var messageDictionary: NSMutableDictionary
        
        //MARK: Initializers
        
        //text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String, tMessage: String) {
            
            //changes messages for both people to "translated message
//            var message = message
//            message = "translated message"
            
            // intialize dictionary
            messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type, tMessage], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying, kTMESSAGE as NSCopying])
        
        }
    
//    func detectlanguage(text: String) {
//
//           TranslationManager.shared.detectLanguage(forText: text) { (language) in
//
//               if let language = language {
//                   print("The detected language was \(language)")
//               } else {
//                   print("Oops! It seems that something went wrong and language cannot be detected.... detetcLanguage()")
//               }
//
//           }
//       }
//
//
//       func translate(text: String) -> String {
//           //            checkForLanguagesExistence()
//           detectlanguage(text: text)
//           getTargetLangCode()
//           TranslationManager.shared.textToTranslate = text
//           print("translate(\(text))")
//
//           return text
//       }
//
//       func getTargetLangCode() {
//
//           TranslationManager.shared.targetLanguageCode = "fr"
//           //            print("getTargetLanguage()")
//       }
//
//           func initiateTranslation(text: String) -> String {
//
//               var text = text
//
//
//                   translate(text: text)
//
//                   TranslationManager.shared.translate { (translation) in
//
//                       if let translation = translation {
//
//                           text = translation
//                           print(text)
//                       } else {
//                           print("Oops! It seems that something went wrong and translation cannot be done... initiateTranslation()")
//                       }
//
//                   }
//
//               return text
//
//               }
//

        //picture message
        init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
            
            // intialize dictionary
            messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        }
        
        
        //video message
        init(message: String, video: String, thumbNail: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
            
            let picThumb = thumbNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            // intialize dictionary
            messageDictionary = NSMutableDictionary(objects: [message, video, picThumb, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        }
        
        
        //MARK: SendMessage
    
        
        func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {

            //generate unique ID for chat that will never be repeated
            let messageId = UUID().uuidString
            messageDictionary[kMESSAGEID] = messageId
            
            //loop to get all the members in the "chatroom"
            for memberId in memberIds {
               
                //create "Message" in firebase
                // creates a message copy for each person in chatroom
                reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String : Any])
                
            }
            
//            var text = messageDictionary[kMESSAGE] as! String
//            text = "Happy birthday"
//            detectlanguage(text: text)
//            text = initiateTranslation(text: text)
            
            
            //update recent to display the latest message
            updateRecents(chatRoomId: chatRoomID, lastMessage: messageDictionary[kMESSAGE] as! String)

            //send push notification to the reciever
    //        let pushText = "[\(messageDictionary[kTYPE] as! String) message]"
    //
    //        sendPushNotification(memberToPush: membersToPush, message: pushText)
        }

        
        class func deleteMessage(withId: String, chatRoomId: String) {
           
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).document(withId).delete()
        }
        
        class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {

            let readDate = dateFormatter().string(from: Date())
            
            let values = [kSTATUS : kREAD, kREADDATE : readDate]
            
            for userId in memberIds {
                
                reference(.Message).document(userId).collection(chatRoomId).document(withId).getDocument { (snapshot, error) in
                    
                    guard let snapshot = snapshot  else { return }
                    
                    if snapshot.exists {
                        
                        reference(.Message).document(userId).collection(chatRoomId).document(withId).updateData(values)
                    }
                }
            }
        }
    }
