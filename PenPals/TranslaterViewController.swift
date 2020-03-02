//
//  TranslaterViewController.swift
//  PenPals
//
//  Created by Eric Alves on 2/28/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TranslaterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var translatedTextLabel: UILabel!
    
    @IBAction func translateButton(_ sender: Any) {
        //Code to use on-device translater to French
        //1
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .fr)
        let englishFrenchTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
        //2
        englishFrenchTranslator.downloadModelIfNeeded { (error) in
        guard error == nil else {
            return }
        }
        //3
        englishFrenchTranslator.translate(self.translateTextField.text ?? "") { (translatedText, error) in
            guard error == nil, let translatedText = translatedText else {
                return }
            self.translatedTextLabel.text = translatedText
            }
    }
    
}//End Class
