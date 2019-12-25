//
//  GalleryCollectionViewHandler.swift
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/16.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

import Foundation


@objc protocol GalleryCollectionViewHandlerDelegate {
    func totalCount() -> Int
    func toggleLoadPages()
    func toggleDisplayImage(at indexPath: IndexPath?, in cell: GalleryCell?)
    func cellSize(at indexPath: IndexPath?, in collectionView: UICollectionView?) -> CGSize
    func userCurrentIndex(_ index: Int)
}


@objc class GalleryCollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @objc var delegate: GalleryCollectionViewHandlerDelegate?
    
// MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.totalCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        delegate?.toggleLoadPages()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.toggleDisplayImage(at: indexPath, in: cell as? GalleryCell)
    }

// MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return delegate?.cellSize(at: indexPath, in: collectionView) ?? CGSize()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

// MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        delegate?.userCurrentIndex((userCurrentIndexPath(collectionView)?.row ?? 0) + 1)
    }

// MARK: - Private Instance Method
    
    // 算出使用者正看到幾頁
    func userCurrentIndexPath(_ collectionView: UICollectionView?) -> IndexPath? {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView?.contentOffset ?? CGPoint.zero
        visibleRect.size = collectionView?.bounds.size ?? CGSize.zero
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView?.indexPathForItem(at: visiblePoint)
        return visibleIndexPath
    }
}
