//
//  GalleryCollectionViewHandler.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/16.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

import Foundation

@objc protocol GalleryCollectionViewHandlerDelegate: AnyObject {
    
    func totalCount() -> Int
    func loadPages()
    func displayImage(at indexPath: IndexPath, in cell: GalleryCell)
    func cellSize(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize
    func currentIndex(_ index: Int)
    
}

class GalleryCollectionViewHandler: NSObject {
    
    @objc weak var delegate: GalleryCollectionViewHandlerDelegate?
    
    // 算出使用者正看到幾頁
    private func userCurrentIndexPath(_ collectionView: UICollectionView?) -> IndexPath? {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView?.contentOffset ?? CGPoint.zero
        visibleRect.size = collectionView?.bounds.size ?? CGSize.zero
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView?.indexPathForItem(at: visiblePoint)
        return visibleIndexPath
    }
    
}

// MARK: - UICollectionViewDataSource
extension GalleryCollectionViewHandler: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.totalCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        delegate?.loadPages()
        return collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
    }
    
}

// MARK: - UICollectionViewDelegate
extension GalleryCollectionViewHandler: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.displayImage(at: indexPath, in: cell as! GalleryCell)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GalleryCollectionViewHandler: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return delegate?.cellSize(at: indexPath, in: collectionView) ?? CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - UIScrollViewDelegate
extension GalleryCollectionViewHandler: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        delegate?.currentIndex((userCurrentIndexPath(collectionView)?.row ?? 0) + 1)
    }
    
}
