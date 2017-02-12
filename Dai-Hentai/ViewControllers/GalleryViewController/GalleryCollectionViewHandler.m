//
//  GalleryCollectionViewHandler.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/16.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "GalleryCollectionViewHandler.h"

@implementation GalleryCollectionViewHandler

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.delegate totalCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate toggleLoadPages];
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(GalleryCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate toggleDisplayImageAt:indexPath inCell:cell];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate cellSizeAt:indexPath inCollectionView:collectionView];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UICollectionView *)collectionView {
    [self.delegate userCurrentIndex:[self userCurrentIndexPath:collectionView].row + 1];
}

#pragma mark - Private Instance Method

// 算出使用者正看到幾頁
- (NSIndexPath *)userCurrentIndexPath:(UICollectionView *)collectionView {
    CGRect visibleRect;
    visibleRect.origin = collectionView.contentOffset;
    visibleRect.size = collectionView.bounds.size;
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [collectionView indexPathForItemAtPoint:visiblePoint];
    return visibleIndexPath;
}

@end
