//
//  MessageCell.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2019/10/31.
//  Copyright © 2019 DaidoujiChen. All rights reserved.
//

import Foundation

class MessageCell: UICollectionViewCell {

    // MARK: Property
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = false
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
        layer.shadowOffset = .zero
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
}
