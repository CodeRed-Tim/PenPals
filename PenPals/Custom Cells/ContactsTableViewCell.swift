//
//  ContactsTableViewCell.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/24/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

protocol ContactsTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class ContactsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath: IndexPath!
    
    var delegate: ContactsTableViewCellDelegate?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        self.fullNameLabel.text = fUser.fullname
        
        if fUser.avatar != "" {
            
            imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    @objc func avatarTap() {
        delegate!.didTapAvatarImage(indexPath: indexPath)
        print("avatar tap at \(indexPath)")
    }

}
