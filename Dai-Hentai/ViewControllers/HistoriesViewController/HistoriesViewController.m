//
//  HistoriesViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/22.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "HistoriesViewController.h"
#import "PrivateListViewController.h"

@implementation HistoriesViewController

#pragma mark - Method to Override

#define pageCout 40

- (void)fetchGalleries {
    if ([self.pageLocker tryLock]) {
        NSInteger index = self.pageIndex * pageCout;
        NSArray *hentaiInfos = [Couchbase historiesFrom:index length:pageCout];
        if (hentaiInfos && hentaiInfos.count) {
            [self.galleries addObjectsFromArray:hentaiInfos];
            [self.collectionView reloadData];
            self.pageIndex++;
            self.isEndOfGalleries = hentaiInfos.count < 40;
        }
        else {
            self.isEndOfGalleries = YES;
        }
        [self.pageLocker unlock];
    }
}

- (void)showMessageTo:(MessageCell *)cell onLoading:(BOOL)isLoading {
    cell.activityView.hidden = YES;
    cell.messageLabel.text = @"你還沒有看過任何作品呦 O3O";
}

#pragma mark - IBAction

- (IBAction)refreshAction:(id)sender {
    if (self.galleries.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    [self reloadGalleries];
}

@end
