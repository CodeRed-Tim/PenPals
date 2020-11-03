//
//  EditProfileTableViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/22/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD
import ImagePicker
import Gallery

class EditProfileTableViewController: UITableViewController,  UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tapPpLabel: UILabel!
    @IBOutlet weak var firstNametextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet var avatarTapGesturerecognizer: UITapGestureRecognizer!
    
    var imagePicker = UIImagePickerController()
    var images: [UIImage] = []
    var gallery: GalleryController!
    var avatarImage: UIImage?
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = UIView()
        
        self.title = NSLocalizedString("Edit Profile", comment: "")
        tapPpLabel.text = NSLocalizedString("Tap Profile Picture", comment: "")
        firstNametextField.placeholder = NSLocalizedString("First Name", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
        
        setUpUI()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    //MARK: IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if firstNametextField.text != "" && lastNameTextField.text != "" {
            
            hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Saving..."
            hud.show(in: self.view)
            
            //block save button
            saveButtonOutlet.isEnabled = false
            
            let fullName = firstNametextField.text! + " " + lastNameTextField.text!
            
            var withValues = [kFIRSTNAME : firstNametextField.text!, kLASTNAME : lastNameTextField.text!, kFULLNAME : fullName]
            
            //avatar change
            if avatarImage != nil {
                //avatarImage?.circleMasked
                let avatarData = avatarImage!.jpegData(compressionQuality: 0.5)
                //convert to string
                let avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                withValues[kAVATAR] = avatarString
            }
            
            //update current user
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                
                if error != nil {
                    
                    DispatchQueue.main.async {
                        self.hud.textLabel.text = "\(error!.localizedDescription)"
                        self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud.show(in: self.view)
                        print("Couldn't update user \(error!.localizedDescription)")
                    }
                    self.saveButtonOutlet.isEnabled = true
                    return
                }
                
                self.hud.dismiss()
                self.hud.textLabel.text = "Saved"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
                
            }
            
        } else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5)
        }
        
    }
    
    @IBAction func avatarTap(_ sender: Any) {
        presentPicker()
    }
    
    func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            avatarImage = imageSelected
            avatarImageView.image = imageSelected
            avatarImageView.image = avatarImage?.circleMasked
            
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatarImage = imageOriginal
            avatarImageView.image = imageOriginal
            avatarImageView.image = avatarImage?.circleMasked
        }
        
        avatarImageView.image = avatarImage!.fixedOrientation()
        avatarImageView.image = avatarImageView.image?.circleMasked
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: SetUpUI
    
    func setUpUI() {
        
        let currentUser = FUser.currentUser()!
        
        avatarImageView.isUserInteractionEnabled = true
        
        firstNametextField.text = currentUser.firstname
        lastNameTextField.text = currentUser.lastname
        
        if currentUser.avatar != "" {
            
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
}
