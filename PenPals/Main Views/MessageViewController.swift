//
//  MessageViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 3/26/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class MessageViewController: JSQMessagesViewController {
    
    
    var chatRoomId: String!
    var memeberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    //apple may have issues with blue bubble bc it
    //is too similar to imessage
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //UI fix for iphone X
    override func viewDidLayoutSubviews() {
        
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    // end UI fix
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //required for jsqmessages or it will crash
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        //UI fix for iphone X
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        //z-index
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // end UI fix
        
        //custom send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "sendGray"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        
    }
    
    //MARK: JSQMessages Delegate Functions (required)
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        // creates option menu (photo, video, photo from library)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // set option menu values
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("photo library")
        }
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("video library")
        }
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        // share location? optional
        
        //set values to option menu
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(cancelAction)
        
        // ipad bug fix (required for app store success
        // check if it an ipad
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverPresentationcontroller = optionMenu.popoverPresentationController {
                
                // changes option menu location
                currentPopoverPresentationcontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverPresentationcontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                currentPopoverPresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            // if its an iphone
            self.present(optionMenu, animated: true, completion: nil)
        }
        // end bug fix
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("send")
        if text != "" {
            print(text!)
            self.sendMessage(text: text, date: date, picture: nil, video: nil)
            updateSendButton(isSend: false)
        } else {
            print("")
        }
    }
    
    //MARK: Send messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, video: NSURL?) {
        
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        //text message
        //if there is a text message
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memeberIds, memberToPush: membersToPush)
    }
    
    //MARK: IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Custom Send button
    
    override func textViewDidChange(_ textView: UITextView) {
        
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
        
    }
    
    func updateSendButton(isSend: Bool) {
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "sendGray"), for: .normal)
        }
        
    }
    
}

extension JSQMessagesInputToolbar {
    
    override open func didMoveToWindow() {
        
        super.didMoveToWindow()
        
        guard let window = window else { return }
        
        if #available(iOS 11.0, *) {
            
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
            
        }
        
    }
    
}
