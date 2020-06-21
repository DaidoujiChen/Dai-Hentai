//
//  LoginViewController.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/11/20.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    // MARK: - Property
    
    private var completion: () -> ()
    private var checkTimer: Timer?
    
    // MARK: - Life Cycle
    
    @objc init(completion: @escaping () -> ()) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
    }
    
    // MARK: - Private Function
    
    private func initValues() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = cancelButton
        
        // 開一個登入網頁
        if let url = URL(string: "https://forums.e-hentai.org/index.php?act=Login&CODE=01") {
            let request = URLRequest(url: url)
            let webView = WKWebView(frame: view.bounds)
            webView.load(request)
            view.addSubview(webView)
        }
        
        // 用一個 timer 等到有正確的 cookie
        checkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkingLoop), userInfo: nil, repeats: true)
    }
    
    @objc private func cancelAction() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.checkTimer?.invalidate()
        }
    }
    
    @objc private func checkingLoop() {
        if ExCookie.isExist() {
            completion()
            cancelAction()
        }
    }
    
}
