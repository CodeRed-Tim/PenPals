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

class MessageViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var chatRoomId: String!
    var memeberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    //listeners
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updateedChatListener: ListenerRegistration?
    
    let legitTypes = [kPICTURE, kVIDEO, kTEXT]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    //store messages variables
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    //checks if first 11 message have been loaded
    var initialLoadComplete = false
    
    //apple may have issues with blue bubble bc it
    //is too similar to imessage
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //MARK: Custom Message View Header
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subtitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        return subTitle
    }()

    
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
        
        setCustomTitle()
        
        loadMessages()
        
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
    
    //MARK: JSQMessages Data Source functions (required)
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get message cell from our collectionview and turn it into a jsqmessagecollectioviewcell
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        //if its an outgoing message set text color to white
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = .white
        } else {
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    //displays the message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    //displays number of messages in array
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        // if its an outgoing message make the message bubble blue
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        } else {
            return incomingBubble
        }
        
    }
    
    //time stamp
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        //shows time stamp every 3 messages
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        } else {
            return nil
        }
        
    }
    
    // sets postion of timestamp
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
            
        } else {
            return 0.0
        }
        
    }
    
    //bottom label for delivered/read status
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objectMessages[indexPath.row]
        
        let status: NSAttributedString
        
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "✔️")
        }
        
        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    
    // status positioning
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        //check if it is the last row
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    
    
    //MARK: JSQMessages Delegate Functions (required)
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        //create instance of camera class
        let camera = Camera(delegate_: self)
        
        // creates option menu (photo, video, photo from library)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // set option menu values
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
        self.collectionView.reloadData()
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
        
        //picture message
        
        if let pic = picture {
            //recieved a picture
            
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    //have an image
                    
                    let text = kPICTURE
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memeberIds, memberToPush: self.membersToPush)
                }
            }
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memeberIds, memberToPush: membersToPush)
    }
    
    //MARK: LoadMessages
    
    func loadMessages() {
        
        //get last 11 messages to display (max amount VC can display
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                //initial loading is done (get 11 messages)
                self.initialLoadComplete = true
                // start lsitening for new incoming messages
                return
            }
            
            // get all messages and sort them using the date from most recent to least
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            //remove bad messages from sorted array
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            
            //insert messages
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            print("we have \(self.messages.count) messages loaded")
            
            //get picture messages
            
            //get old messages in background
            self.getOldMessagesInBackground()
            //start listening for new chats
            self.listenForNewChats()
        }
    }
    
    func listenForNewChats() {
        
        var lastMessageDate = "0"
        
        //atleast some message have already been loaded from firebase
        if loadedMessages.count > 0 {
            //set last message date to be the date of our last message
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        //create listener
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            //if there is a snapshot
            if !snapshot.isEmpty {
                
                //change the difference made in the database
                for diff in snapshot.documentChanges {
                    
                    // if data has been added
                    if diff.type == .added {
                        
                        //item is the new chat message
                        let item = diff.document.data() as NSDictionary
                        
                        if let type = item[kTYPE] {
                            
                            //check if type is a real message type
                            if self.legitTypes.contains(type as! String) {
                                // add to chat
                                
                                //for picture messages
                                if type as! String == kPICTURE {
                                    // add to pictures
                                }
                                
                                if self.insertInitialLoadedMessages(messageDictionary: item) {
                                    //play message recieved sound
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                self.finishReceivingMessage()
                            }
                        }
                        
                    }
                }
            }
        })
    }
    
    func getOldMessagesInBackground() {
           
           if loadedMessages.count > 10 {
               
               //check if there is any older messages then the most recent one
               let firstMessageDate = loadedMessages.first![kDATE] as! String
               reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                   
                   //check if we got  snapshot
                   guard let snapshot = snapshot else { return }
                   
                   let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                   
                   // add messages to very beginning of array
                   //get rid of bad message then add exsiting messages to array
                   self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                   
                   //get the picture messages

                   
                   self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                   self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
               }
           }
       }
    
    //MARK: Insert Messages
    
    // take loaded messages and convert them to type JSQMessage
    func insertMessages() {
        
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            //to avoid negative value
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            
            let messageDictionary = loadedMessages[i]
            
            //insert message into array
            insertInitialLoadedMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        //checking if we've loaded more messages then we show
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
        
    }
    
    func insertInitialLoadedMessages(messageDictionary: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessages(collectionView_: self.collectionView!)
        
        //check if message is incoming or outgoing
        // if incoming
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            
            //update message read status
            
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        //if there is a message ad it to the message dictionary and array
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    //MARK: Load More messages
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOld {
            maxMessageNumber = minMessageNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            //avoid negative message count
            minMessageNumber = 0
        }
        
        // go through every message in reverse 1 by 1
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        
        let incomingMessage = IncomingMessages(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
        
    }
    
    //MARK: IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoButtonPressed() {
        print("show image messages")
    }
    
    @objc func showGroup() {
        print("show group")
    }
    
    @objc func showUserProfile() {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
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
    
    
    //MARK: Update UI
    
    func setCustomTitle() {
        
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
        
        // set info button
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        } else {
            // 1 on 1 chat
            avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memeberIds) { (withUsers) in
            
            self.withUsers = withUsers
            // get avatars
            if !self.isGroup! {
                //update user info
                self.setUIForSingleChat()
            }
            
        }
        
    }
    
    func setUIForSingleChat() {
        
        // grabs the user from array of users
        let withUser = withUsers.first!
        
        //get their profile picture
        imageFromData(pictureData: withUser.avatar) { (image) in
            
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        
        // sets the header title to their first name
        titleLabel.text = withUser.fullname
        
        //sets the header subtitle to their onlne status
        if withUser.isOnline {
            subtitleLabel.text = "Online"
            // set text color to green
        } else {
            subtitleLabel.text = "Offline"
            // set text color to red
        }
        
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        
    }
    
    //MARK: UIImage Picker Controller Delegate
    
    //called everytime user picks a picture or video from picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, video: video)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helper Functions
    
    func readTimeFrom(dateString: String) -> String {
        
        let date = DateFormatter().date(from: dateString)
        
        let currentdateFormat = DateFormatter()
        currentdateFormat.dateFormat = "HH:mm"
        
        return currentdateFormat.string(from: date!)
    }
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages {
            
            if message[kTYPE] != nil {
                
                //if message isnt a text, picture, or video
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    
                    //remove the message from array
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.index(of: message)!)

            }
        }
        return tempMessages
        
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        
        // if current message is coming from the logged in user it is outgoing
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
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
