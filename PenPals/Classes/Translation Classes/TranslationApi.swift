//
//  TranslationApi.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/8/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

enum TranslationAPI {
    case detectLanguage
    case translate
    case supportedLanguages
    
    
    func getURL() -> String {
        var urlString = ""
        
        switch self {
        case .detectLanguage:
            urlString = "https://translation.googleapis.com/language/translate/v2/detect"
            
        case .translate:
            urlString = "https://translation.googleapis.com/language/translate/v2"
            
        case .supportedLanguages:
            urlString = "https://translation.googleapis.com/language/translate/v2/languages"
        }
        
        return urlString
    }
    
    
    func getHTTPMethod() -> String {
        if self == .supportedLanguages {
            return "GET"
        } else {
            return "POST"
        }
    }
}
