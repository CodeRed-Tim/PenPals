//
//  NSAttributedSTringExtension.swift
//  PenPals
//
//  Created by MaseratiTim on 10/15/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    
    static func makeHyperLink(for path: String, in string: String, as substring: String) -> NSAttributedString {
        
        let nsString = NSString(string: string)
        let substringRange = nsString.range(of: substring)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.link, value: path, range: substringRange)
        return attributedString
    }
}
