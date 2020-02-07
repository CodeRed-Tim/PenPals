//
//  FinishRegistrationViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(email, password)
    }

    //MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        // if statment that checks all field are filled in
        
        FUser.registerUserWith(email: email!, password: password!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (error) in
            
            if error != nil {
                
                ProgressHUD.dismiss()
                ProgressHUD.showError(error!.localizedDescription)
                return
                
            } else {
                
                self.registerUser()
                
            }
        }
        
        
    }

    //MARK: Helper Functions
    
    func registerUser() {
        
        let fullName = lastNameTextField.text! + " " + lastNameTextField.text!
        
        //
        var tempDictionary : Dictionary = [kFIRSTNAME : lastNameTextField.text!, kLASTNAME : lastNameTextField.text!]
        
        //if user doesn't pick a profile picture make the picture their intials
        if avatarImage == nil {
            
            // get intials then return them
            imageFromInitials(firstName: lastNameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
                
                // converts image into a string so it can be saved in database
                let avatarImg = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarImg!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
            
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            self.finishRegistration(withValues: tempDictionary)

        }
    }
    
    // pass dictionary and add info locally and to database
    func finishRegistration(withValues: [String : Any]) {
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            
            ProgressHUD.dismiss()
            // go to app
        }
    }
    
    func goToApp() {
        cleanTextFields()
        dismissKeyboard()
        
        // takes you to main view
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }

    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }

    // gets rid of any text in textFields
    func cleanTextFields() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
    }

    
}
