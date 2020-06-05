//
//  RegisterViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD
import ImagePicker

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ImagePickerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var languageDropDown: UITextField!
    @IBOutlet weak var languagePicker: UIPickerView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    var selectedLanguage: String?
    
    var languageList = ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
    
    var startIndex: Int?
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        languagePicker.delegate = self as UIPickerViewDelegate
        languagePicker.dataSource = self as UIPickerViewDataSource
        
        startIndex = languageList.count / 2

        languagePicker.selectRow(startIndex!, inComponent: 0, animated: true)
        
    }
    
    //MARK: Picker menu functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = languageList[row]
        return row
    }
    // change text color
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: languageList[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    
    //MARK: IBActions
    
    @IBAction func avatarImageTapped(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
        
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        if emailTextField.text != "" && firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            
            //validates both passwords match
            if passwordTextField.text == confirmPasswordTextField.text {
                
                FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, language: languageSelect(langIndex: languageIndex)) { (error) in

                    if error != nil {
                        self.hud.dismiss()
                        self.hud.textLabel.text = "\(error!.localizedDescription)"
                        self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud.show(in: self.view)
                        self.hud.dismiss(afterDelay: 1.5)
                        return
                    }
                    self.registerUser()
                }
            } else {
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.textLabel.text = "Passwords don't match!"
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.5)
            }
        } else {
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "All Fields are Required!"
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.75)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Helper Functions
    
    func registerUser() {
        
        hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Registering you..."
        hud.show(in: self.view)
        
        let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        var tempDictionary : Dictionary = [kFIRSTNAME : firstNameTextField.text!, kLASTNAME : lastNameTextField.text!, kFULLNAME : fullName, kPHONE : phoneNumberTextField.text!, kLANGUAGE : languageSelect(langIndex: languageIndex)] as [String : Any]
        
        //if user doesn't pick a profile picture make the picture their intials
        if avatarImage == nil {
            
            // get intials then return them
            imageFromInitials(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
                
                // converts image into a string so it can be saved in database
                let avatarImg = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarImg!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
            
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.5)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary)
            
        }
        
    }
    
    // pass dictionary and add info locally and to database
    func finishRegistration(withValues: [String : Any]) {
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    self.hud.textLabel.text = "\(error!.localizedDescription)"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 1.5)
                    
                    print(error!.localizedDescription)
                }
                return
            }
            
            self.hud.dismiss()
            self.goToApp()
        }
    }
    
    func languageSelect(langIndex: Int) -> String {
        
//        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        var langIndex = langIndex
        
        langIndex = languagePicker.selectedRow(inComponent: 0)
        
        var languageValue = ""
        
        if langIndex == 0 {
            //arabic
            languageValue = "ar"
        } else if langIndex == 1 {
            //Bengali
            languageValue = "bn"
        } else if langIndex == 2 {
            //chinese
            languageValue = "zh"
        } else if langIndex == 3 {
            //dutch
            languageValue = "nl"
        } else if langIndex == 4 {
            //english
            languageValue = "en"
        } else if langIndex == 5 {
            //french
            languageValue = "fr"
        } else if langIndex == 6 {
            //german
            languageValue = "de"
        } else if langIndex == 7 {
            //hatian
            languageValue = "ht"
        } else if langIndex == 8 {
            //hindi
            languageValue = "hi"
        } else if langIndex == 9 {
            //italian
            languageValue = "it"
        } else if langIndex == 10 {
            //japense
            languageValue = "ja"
        } else if langIndex == 11 {
            //korean
            languageValue = "ko"
        } else if langIndex == 12 {
            //malay
            languageValue = "ms"
        } else if langIndex == 13 {
            //porteguese
            languageValue = "pt"
        } else if langIndex == 14 {
            //romanian
            languageValue = "ro"
        } else if langIndex == 15 {
            //russian
            languageValue = "ru"
        } else if langIndex == 16 {
            //spanish
            languageValue = "es"
        }
        return languageValue
    }
    
    
    //MARK: GoToApp
    
    func goToApp() {
        
        // clear progress message
        hud.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    
    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }
    
    // gets rid of any text in textFields
    func cleanTextFields() {
        emailTextField.text = ""
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        phoneNumberTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    //MARK: IMage PIcker Delegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

        if images.count > 0 {
            self.avatarImage = images.first!
            self.avatarImageView.image = self.avatarImage?.circleMasked
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
