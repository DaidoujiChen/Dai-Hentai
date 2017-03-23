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

- (void)fetchGalleries {
    if ([self.pageLocker tryLock]) {
        NSArray *hentaiInfos = [Couchbase historiesFrom:self.pageIndex to:self.pageIndex + 20];
        if (hentaiInfos && hentaiInfos.count) {
            [self.galleries addObjectsFromArray:hentaiInfos];
            [self.collectionView reloadData];
            self.pageIndex++;
            self.isEndOfGalleries = hentaiInfos.count < 20;
        }
        else {
            self.isEndOfGalleries = YES;
        }
        [self.pageLocker unlock];
    }
}

#pragma mark - IBAction

- (IBAction)refreshAction:(id)sender {
    [self reloadGalleries];
}

@end
