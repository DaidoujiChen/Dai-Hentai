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
        
    @objc static func manuallyAddCookie(exKey: String) {
        let exKeySplitted = exKey.components(separatedBy: "x")
        guard exKeySplitted.count == 2 else {
            return // 這不是一個合法的Exkey
        }
        
        let memberPart = exKeySplitted[0]
        let memberIdStartIndex = memberPart.index(memberPart.startIndex, offsetBy: 32)
        let memberIdCookie = createCookie(name: "ipb_member_id", value: String(memberPart[memberIdStartIndex...]))
        let passHashCookie = createCookie(name: "ipb_pass_hash", value: String(memberPart.prefix(32)))
        let igneous = createCookie(name: "igneous", value: exKeySplitted[1])
        
        let cookieList = [memberIdCookie, passHashCookie, igneous]
        
        for theCookie in cookieList {
            HTTPCookieStorage.shared.setCookie(theCookie)
            guard var properties = theCookie.properties else {
                continue
            }
            
            properties[.domain] = ".e-hentai.org" // 將同樣的Cookie也添加到表站
            if let newCookie = HTTPCookie(properties: properties) {
                HTTPCookieStorage.shared.setCookie(newCookie)
            }
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
    
    private static func createCookie(name: String, value: String) -> HTTPCookie {
        return HTTPCookie(properties: [.domain: ".exhentai.org",
        HTTPCookiePropertyKey.name: name,
        HTTPCookiePropertyKey.value: value,
        HTTPCookiePropertyKey.path: "/",
        HTTPCookiePropertyKey.expires: Date(timeInterval: 157784760, since: Date())])! // 5年後過期
    }
}
