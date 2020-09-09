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
import PasswordTextField
import FlagPhoneNumber
import CountryPickerView

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ImagePickerDelegate {

    
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRulesLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var selectPpLabel: UILabel!
    @IBOutlet weak var tapPpLabel: UILabel!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var languageDropDown: UITextField!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var registerButton: UIButton!
    
    weak var cpvTextField: CountryPickerView!
    let cpvInternal = CountryPickerView()
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    var selectedLanguage: String?
    
    var languageList = [NSLocalizedString("Arabic", comment: ""), NSLocalizedString("Bengali", comment: ""), NSLocalizedString("Chinese", comment: ""), NSLocalizedString("Dutch", comment: ""), NSLocalizedString("English", comment: ""), NSLocalizedString("French", comment: ""), NSLocalizedString("German", comment: ""), NSLocalizedString("Haitian", comment: ""), NSLocalizedString("Hindi", comment: ""), NSLocalizedString("Italian", comment: ""), NSLocalizedString("Japenese", comment: ""), NSLocalizedString("Korean", comment: ""), NSLocalizedString("Malay", comment: ""), NSLocalizedString("Portuguese", comment: ""), NSLocalizedString("Romanian", comment: ""), NSLocalizedString("Russian", comment: ""), NSLocalizedString("Spanish", comment: "")]
    
    var startIndex: Int?
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Localization
        signUpLabel.text = NSLocalizedString("Sign Up", comment: "")
        firstNameLabel.text = NSLocalizedString("First Name", comment: "")
        firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "")
        
        lastNameLabel.text = NSLocalizedString("Last Name", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
        
        emailLabel.text = NSLocalizedString("Email", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        
        phoneNumberLabel.text = NSLocalizedString("Phone Number", comment: "")
        phoneNumberTextField.placeholder = NSLocalizedString("Phone Number", comment: "")
        
        passwordLabel.text = NSLocalizedString("Passsword", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        passwordRulesLabel.text = NSLocalizedString("Password Rules", comment: "")
        
        confirmPasswordLabel.text = NSLocalizedString("Confirm Password", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        
        selectLabel.text = NSLocalizedString("Select Language", comment: "")
        selectPpLabel.text = NSLocalizedString("Select Profile Picture", comment: "")
        tapPpLabel.text = NSLocalizedString("Tap Profile Picture", comment: "")
        
        registerButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
        
        avatarImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        languagePicker.delegate = self as UIPickerViewDelegate
        languagePicker.dataSource = self as UIPickerViewDataSource
        
        startIndex = languageList.count / 2
        
        languagePicker.selectRow(startIndex!, inComponent: 0, animated: true)
        
        let cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 1000, height: 200))
//        cp.delegate = self
//        cp.dataSource = self
        [ cpvTextField, cpvInternal].forEach {
            $0?.dataSource = self
        }
        
        cpvInternal.delegate = self
        
//        cellImageViewSize(in: cp)
        
        phoneNumberTextField.leftView = cp
        phoneNumberTextField.leftViewMode = .always
        
        self.cpvTextField = cp
        
        cpvTextField.tag = 2

        
    }
    
    func cellImageViewSize(in countryPickerView: CountryPickerView) -> CGSize {
        return cpvTextField.flagImageView.sizeThatFits(CGSize(width: 2000, height: 2000))
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
        return NSAttributedString(string: languageList[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    
    //MARK: IBActions
    
    @IBAction func avatarImageTapped(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
        
    }
    
    func validatePhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    func validatePass(value: String) -> Bool {
        let PASS_REGEX = "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$"
        let passTest = NSPredicate(format: "SELF MATCHES %@ ", PASS_REGEX)
        let result = passTest.evaluate(with: value)
        return result
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        
        if emailTextField.text != "" && firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            
            //validates both passwords match
            if passwordTextField.text == confirmPasswordTextField.text {
                
                if validatePhone(value: phoneNumberTextField.text!) == true {
                    
                    if validatePass(value: passwordTextField.text!) == true {
                    
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
                        hud.textLabel.text = "Password must contain atleast 1 uppercase, 1 lowercase, 1 special character and be 6 letters or longer"
                        hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        hud.show(in: self.view)
                        hud.dismiss(afterDelay: 1.5)
                    }
                    
                } else {
                    hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    hud.textLabel.text = "Invalid Phone Number Format!"
                    hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 1.5)
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
        
        let firstName = firstNameTextField.text?.capitalizingFirstLetter()
        let lastName = lastNameTextField.text?.capitalizingFirstLetter()
        
        
        let fullName = firstName! + " " + lastName!
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        var tempDictionary : Dictionary = [kFIRSTNAME : firstName!, kLASTNAME : lastName!, kFULLNAME : fullName, kPHONE : phoneNumberTextField.text!, kLANGUAGE : languageSelect(langIndex: languageIndex)] as [String : Any]
        
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

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension RegisterViewController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        // Only countryPickerInternal has it's delegate set
        let title = "Selected Country"
        let message = "Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)"
//        showAlert(title: title, message: message)
    }
}

extension RegisterViewController: CountryPickerViewDataSource {
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
        
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }
}


extension UITextField {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}
