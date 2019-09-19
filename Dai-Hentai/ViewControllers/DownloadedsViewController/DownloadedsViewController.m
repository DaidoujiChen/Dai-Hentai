//
//  DownloadedsViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/15.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "DownloadedsViewController.h"
#import "PrivateListViewController.h"
#import "DBGallery.h"

@interface DownloadedsViewController ()

@end

@implementation DownloadedsViewController

#pragma mark - Private Instance Method

- (void)refreshAction {
    if (self.galleries.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    [self reloadGalleries];
}

#pragma mark - Method to Override

#define pageCout 40

- (void)fetchGalleries {
    self.isLoading = YES;
    if ([self.pageLocker tryLock]) {
        NSInteger index = self.pageIndex * pageCout;
        NSArray<HentaiInfo *> *hentaiInfos = [DBGallery downloadedsFrom:index length:pageCout];
        if (hentaiInfos && hentaiInfos.count) {
            [self.galleries addObjectsFromArray:hentaiInfos];
            [self.collectionView reloadData];
            self.pageIndex++;
            self.isEndOfGalleries = hentaiInfos.count < 40;
        }
        else {
            self.isEndOfGalleries = YES;
        }
        self.isLoading = NO;
        [self.pageLocker unlock];
    }
}

- (void)showMessageTo:(MessageCell *)cell onLoading:(BOOL)isLoading {
    cell.activityView.hidden = YES;
    cell.messageLabel.text = @"你還沒有看過任何作品呦 O3O";
}

- (void)onCellBeSelectedAction:(HentaiInfo *)info {
    [self performSegueWithIdentifier:@"PushToGallery" sender:info];
}

- (void)initValues {
    [super initValues];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAction) name:DBGalleryTimeStampUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAction) name:DBGalleryDownloadedUpdateNotification object:nil];
}

@end
