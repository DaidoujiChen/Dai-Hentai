//
//  ExCookie.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/11/14.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation

class ExCookie: NSObject {
    
    // MARK: - Property
    
    private static let url = URL(string: "https://e-hentai.org")!
    
    // MARK: - Static Function
    
    @objc static func isExist() -> Bool {
        var isExist = false
        guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
            return isExist
        }
        
        for cookie in cookies {
            if let expiresDate = cookie.expiresDate, cookie.name == "ipb_pass_hash" {
                if NSDate().compare(expiresDate) != .orderedAscending {
                    isExist = false
                } else {
                    isExist = true
                }
            }
        }
        
        if isExist {
            replace()
        }
        return isExist
    }
    
    @objc static func clean() {
        let shared = HTTPCookieStorage.shared
        for cookie in shared.cookies ?? [] {
            shared.deleteCookie(cookie)
        }
    }
    
    // MARK: - Private Static Function
    
    private static func replace() {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
            return
        }
        
        for cookie in cookies {
            guard var properties = cookie.properties else {
                continue
            }
            
            properties[.domain] = ".exhentai.org"
            if let newCookie = HTTPCookie(properties: properties) {
                HTTPCookieStorage.shared.setCookie(newCookie)
            }
        }
    }

}
