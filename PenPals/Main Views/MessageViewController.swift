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
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class MessageViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    //listeners
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    
    let legitTypes = [kPICTURE, kVIDEO, kTEXT]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    //store messages variables
    var typingCounter = 0
    
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    //checks if first 11 message have been loaded
    var initialLoadComplete = false
    
    var jsqAvatarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    
    //apple may have issues with blue bubble bc it
    //is too similar to imessage
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //MARK: Custom Message View Header
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 10, width: 33, height: 33))
        return button
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 40, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 18)
        return title
    }()
    
    let subtitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 40, y: 30, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 14)
        return subTitle
    }()

    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoomId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoomId)
    }
    
    
    //UI fix for iphone X
    override func viewDidLayoutSubviews() {
        
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    // end UI fix
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create typing observer
        createtypingObserver()
        
        //for deleting indivudal messages
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(delete))
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        jsqAvatarDictionary = [ : ]
        
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        var avatar: JSQMessageAvatarImageDataSource
        
        if let testAvatar = jsqAvatarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        
        return avatar
        
    }
    
    
    
    //MARK: JSQMessages Delegate Functions (required)
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        //create instance of camera class
        let camera = Camera(delegate_: self)
        
        // creates option menu (photo, video, photo from library)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // set option menu values
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.PresentMultyCamera(target: self, canEdit: false)
        }
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        }
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            camera.PresentVideoLibrary(target: self, canEdit: false)
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
    
    //for when user tapes on messages, pictures, videos
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
                
        let messageDictionary = objectMessages[indexPath.row]
        let messageType = messageDictionary[kTYPE] as! String
        
        switch messageType {
        case kPICTURE:
            //open picture to its own photo browser view controller
            //get correct picture tapped on
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            //get the one image from the array
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.present(browser!, animated: true, completion: nil)
        case kVIDEO:
            //opening video
            // find the correct message tapped
            let message = messages[indexPath.row]
            let mediaItem = message.media as! VideoMessage
            //create an avplayer
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            //open video to its own avplayer view controller
            let moviePlayer = AVPlayerViewController()
            //create session to play audio
            let session = AVAudioSession.sharedInstance()
            
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            
            moviePlayer.player = player
            //present video
            self.present(moviePlayer, animated: true) {
                moviePlayer.player!.play()
            }
        default:
            print("unknown message type tapped")
        }
    }
    
    //when user taps on other user's avatar
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
        let senderId = messages[indexPath.row].senderId
        var selectedUser: FUser?
        
        //if user taps on their own avatar
        if senderId == FUser.currentId() {
            selectedUser = FUser.currentUser()
        } else {
            for user in withUsers {
                //check whos avatar is being tapped
                if user.objectId == senderId {
                    selectedUser = user
                }
            }
        }
        
        //show user profile
        presentUserProfile(forUser: selectedUser!)
    }
    
    //for deleting individual media messages
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if messages[indexPath.row].isMediaMessage {
            
            if action.description == "delete:" {
                return true
            } else {
                return false
            }
        } else {
            if action.description == "delete:" || action.description == "copy:" {
                return true
            } else {
                return false
            }
        }
        
    }
    
    //called everytime user deletes message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        // remove message from collecitonview and firebase
        
        let messageId = objectMessages[indexPath.row][kMESSAGEID] as! String
        
        //remove from collection view
        objectMessages.remove(at: indexPath.row)
        messages.remove(at: indexPath.row)
        
        //delete from firebase
        OutgoingMessages.deleteMessage(withId: messageId, chatRoomId: chatRoomId)

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
                    
                    let text = "[\(kPICTURE)]"
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            return
        }
        
        //send video
        if let video = video {
            
            let videoData = NSData(contentsOfFile: video.path!)
            
            //need to convert thumnbail to data to save it in firebase
            let dataThumbnail = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
            
            uploadVideo(video: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (videoLink) in
                
                if videoLink != nil {
                    let text = "[\(kVIDEO)]"
                    
                    outgoingMessage = OutgoingMessages(message: text, video: videoLink!, thumbNail: dataThumbnail! as NSData, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kVIDEO)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            return
        }
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage?.sendMessage(chatRoomID: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    //MARK: LoadMessages
    
    func loadMessages() {
        
        // to update message status delivered/read
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
           //check for difference in documents
                snapshot.documentChanges.forEach({ (diff) in
                    
                    if diff.type == .modified {
                        //update local message
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                })
            }
        })
        
        //get last 11 messages to display (max amount VC can display
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                //initial loading is done (get 11 messages)
                self.initialLoadComplete = true
                // start lsitening for new incoming messages
                self.listenForNewChats()
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
            
            //get picture message
            self.getPictureMessages()
            
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
                                    self.addNewPictureMessageLink(link: item[kPICTURE] as! String)
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
                self.getPictureMessages()
                   
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
            OutgoingMessages.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        //if there is a message ad it to the message dictionary and array
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    func updateMessage(messageDictionary: NSDictionary) {
        //update message locally
        //go through all the messages
        for index in 0 ..< objectMessages.count {
            let temp = objectMessages[index]
            //compare to see which message is the updated one
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objectMessages[index] = messageDictionary
                self.collectionView!.reloadData()
            }
        }
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
        
        clearRecentCounter(chatRoomId: chatRoomId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoButtonPressed() {
        let mediaVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "mediaView") as! PicturesCollectionViewController
        
        mediaVC.allImageLinks = allPictureMessages
        
        self.navigationController?.pushViewController(mediaVC, animated: true)
    }
    
    @objc func showGroup() {
        print("show group")
    }
    
    @objc func showUserProfile() {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func presentUserProfile(forUser: FUser) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = forUser
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK: Typing indicator
    func createtypingObserver() {
        
        typingListener = reference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                // if it does
                
                for data in snapshot.data()! {
                    
                    // if the current user is not typing
                    if data.key != FUser.currentId() {
                        
                        let typing = data.value as! Bool
                        self.showTypingIndicator = typing
                        
                        if typing {
                            //if other user starts typing bring the current user's view down to the bottom
                            self.scrollToBottom(animated: true)
                        }
                    }
                }
                
            } else {
                //if there is no snapshot set typing indicator to false
                reference(.Typing).document(self.chatRoomId).setData([FUser.currentId() : false])
            }
            
        })
        
    }
    
    func typingCounterStart() {
        
        typingCounter += 1
        typingCounterSave(typing: true)
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingCounterStop() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            typingCounterSave(typing: false)
        }
    }
    
    func typingCounterSave(typing: Bool) {
        reference(.Typing).document(chatRoomId).updateData([FUser.currentId() : typing])
        
    }
    
    //MARK: UI Text View Delegate
    
    //notify user everytime other user starts typing
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        typingCounterStart()
        
        return true
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
        
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            
            self.withUsers = withUsers
            // get avatars
            self.getAvatarImages()
            
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
            //subtitleLabel.textColor = UIColor.green
            //sea green rgb
            subtitleLabel.textColor = UIColor(red: (60/255.0), green: (179/255.0), blue: (5/255.0), alpha: 1.0)
            // set text color to green
        } else {
            subtitleLabel.text = "Offline"
            subtitleLabel.textColor = UIColor.red
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
    
    //MARK: get avatars
    
    func getAvatarImages() {
        
        //check to see if we can show avatars
        
        if showAvatars {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            //get avatar of current user
            avatarImageFrom(fUser: FUser.currentUser()!)
            
            //get avatar for everyone in message
            for user in withUsers {
                avatarImageFrom(fUser: user)
            }
            
            
        }
    }
    
    func avatarImageFrom(fUser: FUser) {
        
        //user has an avatar
        if fUser.avatar != "" {
            dataImageFromString(pictureString: fUser.avatar) { (imageData) in
                
                if imageData == nil { return }
                
                if self.avatarImageDictionary != nil {
                    //update avatar if user has one
                    //remove avatar from dictionary
                    self.avatarImageDictionary!.removeObject(forKey: fUser.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: fUser.objectId as NSCopying)
                    
                } else {
                    //creat one
                    self.avatarImageDictionary = [fUser.objectId : imageData!]
                }
                
                //create JSQ avatars
                createJSQAvatars(avatarDictionary: self.avatarImageDictionary)
            }
        }
        
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?) {
        
        //set default avatar if user doesnt have one
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if avatarDictionary != nil {
            
            for userId in memberIds {
                //access avatar image data
                if let avatarImageData = avatarDictionary![userId] {
                    
                    //create jsq avatar
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImageData as! Data), diameter: 70)
                    
                    //set avatar and put it in dictionary
                    self.jsqAvatarDictionary!.setValue(jsqAvatar, forKey: userId)
                } else {
                    self.jsqAvatarDictionary!.setValue(defaultAvatar, forKey: userId)

                }
            }
            
            //refresh collectionview and display avatars
            self.collectionView.reloadData()
        }
        
    }
    
    //MARK: Helper Functions
    
    func addNewPictureMessageLink(link: String) {
        
        allPictureMessages.append(link)
    }
    
    func getPictureMessages() {
        
        //clean array
        allPictureMessages = []
        
        //loop through every message in firebase
        for message in loadedMessages {
            
            if message[kTYPE] as! String == kPICTURE {
                //add to array
                allPictureMessages.append(message[kPICTURE] as! String)
            }
        }
        
    }
    
    func readTimeFrom(dateString: String) -> String {
        
        let date = dateFormatter().date(from: dateString)
        
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        
        return currentDateFormat.string(from: date!)
        
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
    
    //stop listening for chats when user is not in caht view
    func removeListeners() {
        
        if typingListener != nil {
            typingListener!.remove()
        }
        
        if newChatListener != nil {
            newChatListener!.remove()
        }
        if updatedChatListener != nil {
            updatedChatListener!.remove()
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
