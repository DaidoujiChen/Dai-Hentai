//
//  CheckPageViewController.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/12/10.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class CheckPageViewController: UIViewController {
    
    // MARK: - Property
    
    private let urlString: String
    
    // MARK: - Life Cycle
    
    @objc init(urlString: String) {
        self.urlString = urlString
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
        
        guard let url = URL(string: urlString) else {
            return
        }
        // 開一個頁面
        let webView = WKWebView(frame: view.bounds)
        webView.load(URLRequest(url: url))
        view.addSubview(webView)
    }
    
    @objc private func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
