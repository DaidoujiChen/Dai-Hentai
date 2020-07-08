//
//  ExCookie.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/11/14.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation
import WebKit

class ExCookie: NSObject {
    
    // MARK: - Property
    
    private static let ehDomain = ".e-hentai.org"
    private static let exDomain = ".exhentai.org"
    
    // MARK: - Static Function
    
    @objc static func isExist() -> Bool {
        
        if isCookiesInStorage() {
            return true
        }
        
        findCookiesInWKDataStore()
        
        return false
    }
    
    @objc static func clean() {
        
        // 一般的 request 用的 cookies 放在 HTTPCookieStorage
        let shared = HTTPCookieStorage.shared
        for cookie in shared.cookies ?? [] {
            shared.deleteCookie(cookie)
        }
        
        // WKWebView 的 cookie 放在 WKWebsiteDataStore
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {
            $0.forEach {
                WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0]) {
                }
            }
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
            
            properties[.domain] = ehDomain // 將同樣的Cookie也添加到表站
            if let newCookie = HTTPCookie(properties: properties) {
                HTTPCookieStorage.shared.setCookie(newCookie)
            }
        }
    }
    
    // MARK: - Private Static Function
    
    private static func replace() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            cookies.filter { $0.domain == ehDomain }.forEach { (cookie) in
                if var newProperties = cookie.properties {
                    newProperties[.domain] = exDomain
                    
                    if let newCookie = HTTPCookie(properties: newProperties) {
                        
                        // 一般的 request 用的 cookies 放在 HTTPCookieStorage
                        HTTPCookieStorage.shared.setCookie(newCookie)
                        
                        // WKWebView 的 cookie 放在 WKWebsiteDataStore
                        WKWebsiteDataStore.default().httpCookieStore.setCookie(newCookie, completionHandler: nil)
                    }
                }
            }
        }
    }
    
    private static func createCookie(name: String, value: String) -> HTTPCookie {
        return HTTPCookie(properties: [
            .domain: exDomain,
            .name: name,
            .value: value,
            .path: "/",
            .expires: Date(timeInterval: 157784760, since: Date())
        ])! // 5年後過期
    }
    
    private static func isCookiesInStorage() -> Bool {
        var isInStorage = false
        
        guard
            let cookies = HTTPCookieStorage.shared.cookies?.filter({ $0.domain == exDomain }),
            !cookies.isEmpty else {
                
                return isInStorage
        }
        
        for cookie in cookies {
            if let expiresDate = cookie.expiresDate, cookie.name == "ipb_pass_hash" {
                if NSDate().compare(expiresDate) != .orderedAscending {
                    isInStorage = false
                } else {
                    isInStorage = true
                }
            }
        }
        return isInStorage
    }
    
    private static func findCookiesInWKDataStore() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            
            var isInDataStore = false
            cookies.filter { $0.domain == ehDomain }.forEach { (cookie) in
                if cookie.name == "ipb_pass_hash", let expiresDate = cookie.expiresDate {
                    if Date().compare(expiresDate) != .orderedAscending {
                        isInDataStore = false
                    } else {
                        isInDataStore = true
                    }
                }
            }
            
            if isInDataStore {
                replace()
            }
        }
    }
    
}
