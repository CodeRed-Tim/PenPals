//
//  RecentChatTableViewCell.swift
//  PenPals
//
//  Created by MaseratiTim on 3/25/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit


protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterBackground: UIView!
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    
    var delegate: RecentChatTableViewCellDelegate?
    
    var code = FUser.currentUser()?.language
    let semaphore = DispatchSemaphore(value: 0)
    var translatedText = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        counterBackground.layer.cornerRadius = counterBackground.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    //MARK: Generate cell
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        let inputText: String = (recentChat[kLASTMESSAGE] as? String)!
        
        self.initiateTranslation(text: inputText) { (outText) in
            self.translatedText = outText
            self.semaphore.signal()
        }
        _ = self.semaphore.wait(wallTimeout: .distantFuture)
                                    
        
        self.indexPath = indexPath
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = self.translatedText
        //self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.counterLabel.text = recentChat[kCOUNTER] as? String
        
        // check if they have an avatar
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        //check if they have unread messages
        if recentChat[kCOUNTER] as! Int != 0 {
            self.counterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.counterBackground.isHidden = false
            self.counterLabel.isHidden = false
        } else {
            self.counterBackground.isHidden = true
            self.counterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            
            // date is saved as 14 digits
            if (created as! String).count != 14 {
                
                //message is set to new date
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            
            //if there is no recent chats saved
            // set the date to the date of the new message
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
        
    }
    
    func initiateTranslation(text: String, completion: @escaping ( _ result: String) -> ()) {
        
        var text = text
        translate(text: text)
        TranslationManager.shared.translate { (translation) in
            if let translation = translation {
                text = translation
                completion(text)
            } else {
                print("language not translated2")
                self.semaphore.signal()
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
    
    @objc func avatarTap() {
        print("avatar tap \(indexPath)")
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
    
}
