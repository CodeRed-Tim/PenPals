//
//  RegisterViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD
import ImagePicker

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    var languageList = ["Arabic", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Italian", "Japenese", "Korean", "Porteguese", "Romanian", "Russian", "Spanish"]
    
    var startIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(email, password)
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
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: languageList[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.yellow]) 
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering You...")
        
        var languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        
        if emailTextField.text != "" && firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            
            //validates both passwords match
            if passwordTextField.text == confirmPasswordTextField.text {
                
                //                FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (error) in
                
                FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, language: languageSelect(langIndex: languageIndex)) { (error) in
                    
                    
                    
                    if error != nil {
                        ProgressHUD.dismiss()
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    self.registerUser()
                    
                }
                
                
                //                self.languageSelect()
                self.registerUser()
                
            } else {
                
                ProgressHUD.showError("Passwords Don't Match!")
            }
            
        } else {
            
            ProgressHUD.showError("All Field are Required!")
            
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Helper Functions
    
    func registerUser() {
        
        let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
        var languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        //
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
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
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
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func languageSelect(langIndex: Int) -> String {
        
//        ["Arabic", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Italian", "Japenese", "Korean", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        var langIndex = langIndex
        
        langIndex = languagePicker.selectedRow(inComponent: 0)
        
        var languageValue = ""
        
        if langIndex == 0 {
            //arabic
            languageValue = "ar"
        } else if langIndex == 1 {
            //chinese
            languageValue = "zh"
        } else if langIndex == 2 {
            //dutch
            languageValue = "nl"
        } else if langIndex == 3 {
            //english
            languageValue = "en"
        } else if langIndex == 4 {
            //french
            languageValue = "fr"
        } else if langIndex == 5 {
            //german
            languageValue = "de"
        } else if langIndex == 6 {
            //hatian
            languageValue = "ht"
        } else if langIndex == 7 {
            //italian
            languageValue = "it"
        } else if langIndex == 8 {
            //japense
            languageValue = "ja"
        } else if langIndex == 9 {
            //korean
            languageValue = "ko"
        } else if langIndex == 10 {
            //porteguese
            languageValue = "pt"
        } else if langIndex == 11 {
            //romanian
            languageValue = "ro"
        } else if langIndex == 12 {
            //russian
            languageValue = "ru"
        } else if langIndex == 13 {
            //spanish
            languageValue = "es"
        }
        return languageValue
    }
    
    
    //MARK: GoToApp
    
    func goToApp() {
        
        // clear progress message
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        if segue.identifier == "registerToFinishRegistration" {
    //
    //            let vc = segue.destination as! FinishRegistrationViewController
    //            vc.email = emailTextField.text!
    //            vc.password = passwordTextField.text!
    //        }
    //    }
    
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
}

//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return languageList.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return languageList[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedLanguage = languageList[row]
//        languageDropDown.text = selectedLanguage
//    }
//
//    func createPickerView() {
//           let languagePicker = UIPickerView()
//           languagePicker.delegate = self
//           languageDropDown.inputView = languageDropDown
//    }
//
//    func dismissPickerView() {
//       let toolBar = UIToolbar()
//       toolBar.sizeToFit()
//        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
//       toolBar.setItems([button], animated: true)
//       toolBar.isUserInteractionEnabled = true
//       languageDropDown.inputAccessoryView = toolBar
//    }
//
//    @objc func action() {
//          view.endEditing(true)
//    }
