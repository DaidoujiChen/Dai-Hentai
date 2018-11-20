//
//  AuthHelper.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/11/20.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation
import LocalAuthentication

class AuthHelper: NSObject {
    
    // MARK - Property
    
    private static var context = LAContext()
    
    // MARK: - Static Function
    
    @objc static func refresh() {
        self.context = LAContext()
    }
    
    @objc static func canLock() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    @objc static func check(for reason: String, completion: @escaping (Bool) -> Void) {
        if canLock() {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, err) in
                if let err = err {
                    print(err)
                }
                
                DispatchQueue.main.async {
                    completion(success && err == nil)
                }
            }
        } else {
            print("鎖不住 o.o")
        }
    }
    
}
