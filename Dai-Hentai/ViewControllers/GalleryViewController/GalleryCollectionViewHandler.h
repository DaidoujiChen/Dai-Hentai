//
//  GalleryCollectionViewHandler.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/16.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Dai_Hentai-Swift.h"

@protocol GalleryCollectionViewHandlerDelegate;

@interface GalleryCollectionViewHandler : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<GalleryCollectionViewHandlerDelegate> delegate;

@end

@protocol GalleryCollectionViewHandlerDelegate <NSObject>

@required
- (NSInteger)totalCount;
- (void)toggleLoadPages;
- (void)toggleDisplayImageAt:(NSIndexPath *)indexPath inCell:(GalleryCell *)cell;
- (CGSize)cellSizeAt:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView;
- (void)userCurrentIndex:(NSInteger)index;

@end
