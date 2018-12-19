//
//  GalleryCell.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/12/19.
//  Copyright © 2018 DaidoujiChen. All rights reserved.
//

import Foundation
import UIKit

class GalleryCell: UICollectionViewCell {
    
    // MARK: - Property
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var isPresenting = false
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    // MARK: - Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.minimumPressDuration = 1
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = .black
    }
    
    // MARK: - Function
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard
            let image = imageView.image,
            !isPresenting else {
            return
        }
        isPresenting = true
        
        let activityViewController = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (_, _, _, _) -> Void in
            guard let self = self else {
                return
            }
            self.isPresenting = false
        }
        rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
}
