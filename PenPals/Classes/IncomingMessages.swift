//
//  IncomingMessages.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/30/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase
import JGProgressHUD

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    var hud = JGProgressHUD(style: .dark)
    
    init(collectionView_: JSQMessagesCollectionView) {
        // set the variable
        collectionView = collectionView_
    }
    
    //MARK: Create Message types
    var code = FUser.currentUser()?.language
    let semaphore = DispatchSemaphore(value: 0)
    var translatedText = ""
    
    //MARK: CreateMessage
    // pass through message from Firebase, see if message if text, video, picture
    // creates required JSQ message
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        let type = messageDictionary[kTYPE] as! String
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            message = createVideoMessage(messageDictionary: messageDictionary)
        default:
            print("Unknown message type")
        }
        if message != nil {
            return message
        }
        return nil
    }

    
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
        //getTargetLangCode()
        let tempID = FUser.currentUser()?.objectId
        var isCurrentUser: Bool = false
        
        if userId == tempID {
            isCurrentUser = true
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        self.initiateTranslation(text: text, isCurrentUser: isCurrentUser) { (tText) in
            self.translatedText = tText
            self.semaphore.signal()
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: translatedText)
    }
    
    //MARK: Translation Code
    
    func detectlanguage(text: String, completion: @escaping ( _ result: String) -> ()) {

        TranslationManager.shared.detectLanguage(forText: text) { (language) in
            if let language = language {
                print("The detected language was \(language)")
                completion(language)
            } else {
                print("language code not detected")
            }
        }
    }
    
    func initiateTranslation(text: String, isCurrentUser: Bool, completion: @escaping ( _ result: String) -> ()) {
        var text = text
        if isCurrentUser {
            completion(text)
        } else {
            translate(text: text)
            TranslationManager.shared.translate { (translation) in
                if let translation = translation {
                    text = translation
                    print("The translation is... \(text)")
                    completion(text)
                } else {
                    print("language not translated")
                    self.semaphore.signal()
                }
                
            }
        }
    }
    
    func translate(text: String) {
        getTargetLangCode()
        TranslationManager.shared.textToTranslate = text
    }
    
    func getTargetLangCode() {
        if code == nil {
            code = FUser.currentUser()?.language
        }
        TranslationManager.shared.targetLanguageCode = code
    }
        
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        //doenload image
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
    
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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
        
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        
        //download video
        
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in
                
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
            })
            
            self.collectionView.reloadData()
        }
        
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    //MARK: Helper
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        
        return senderId == FUser.currentId()
    }

}


