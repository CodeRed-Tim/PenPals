//
//  IncomingMessages.swift
//  PenPals
//
//  Created by MaseratiTim on 3/30/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    
    
    init(collectionView_: JSQMessagesCollectionView) {
        // set the variable
        collectionView = collectionView_
    }
    
    
    //MARK: CreateMessage
    
    // pass through message from Firbase, see if message if text, video, picture
    // creates required JSQ message
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        //check message typ
        switch type {
        case kTEXT:
            // possible location to run translation method here
            // example: translateMessage(message);
            // create text message
            //translate here
            //                print(message)
            var temp = messageDictionary[kMESSAGE]
            temp = "Hellooo"
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
    
    //    var messageDictionary: NSDictionary
    //    var text = messageDictionary[kMESSAGE] as! String
    
    
    //MARK: Create Message types
    var code = FUser.currentUser()?.language

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
        
        
        //            let decryptedText = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: messageDictionary[kMESSAGE] as! String)
        
        // IMPORTAN
        
        var text = messageDictionary[kMESSAGE] as! String
        
        detectlanguage(text: text)
        initiateTranslation(text: text)
        
        
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
        //            return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: decryptedText)
    }
    
    
    
//    Mark: Translation Code
    
//            var text = "Merci beaucoup"
//     this will get the language code
//    for example if text="Good morning" it will get en
    func detectlanguage(text: String) {

        TranslationManager.shared.detectLanguage(forText: text) { (language) in

            if let language = language {
                print("The detected language was \(language)")
            } else {
                print("Oops! It seems that something went wrong and language cannot be detected.... detetcLanguage()")
            }

        }
    }

    func getTargetLangCode() {

        //works if you hard code it i.e. "fr"
        TranslationManager.shared.targetLanguageCode = code
        print("getTargetLanguage(\(code!))")
    }

    func translate(text: String) {
        //            checkForLanguagesExistence()
        getTargetLangCode()
        TranslationManager.shared.textToTranslate = text
        print("translate(\(text))")

    }

    func initiateTranslation(text: String) {

        var text = text

        //has the correct code

        translate(text: text)
    print("this the current text message \(text) !!!!!")

        //this code is not being called
        TranslationManager.shared.translate { (translation) in
            if let translation = translation {

                text = translation
                print("Th translation is... \(text)")
            } else {
                print("Oops! It seems that something went wrong and translation cannot be done... initiateTranslation()")
            }

        }

    }
    
    
    //    // Create an English-German translator:
    //    func translate() {
    //        text="good morning"
    //
    //        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .de)
    //        let englishGermanTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
    //
    //        let conditions = ModelDownloadConditions(
    //            allowsCellularAccess: false,
    //            allowsBackgroundDownloading: true
    //        )
    //        englishGermanTranslator.downloadModelIfNeeded(with: conditions) { error in
    //            guard error == nil else { return }
    //        }
    //
    //        englishGermanTranslator.translate(text) { translatedText, error in
    //            guard error == nil, let translatedText = translatedText else { return }
    //
    //            text = translatedText
    //        }
    //        print(text)
    //    }
    //
    
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
