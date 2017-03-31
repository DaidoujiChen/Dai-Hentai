//
//  HistoriesViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/22.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "HistoriesViewController.h"
#import "PrivateListViewController.h"
#import "FilesManager.h"

@interface HistoriesViewController ()

@property (nonatomic, assign) BOOL isDeleting;
@property (nonatomic, strong) NSString *deletingMessage;

@end

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
    if (self.isDeleting) {
        cell.activityView.hidden = NO;
        [cell.activityView startAnimating];
        cell.messageLabel.text = self.deletingMessage;
    }
    else {
        cell.activityView.hidden = YES;
        cell.messageLabel.text = @"你還沒有看過任何作品呦 O3O";
    }
}

- (void)initValues {
    [super initValues];
    self.isDeleting = NO;
}

#pragma mark - IBAction

- (IBAction)refreshAction:(id)sender {
    if (self.isDeleting) {
        return;
    }
    
    if (self.galleries.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    [self reloadGalleries];
}

- (IBAction)deleteAllHistoriesAction:(id)sender {
    if (!self.isDeleting) {
        self.isDeleting = YES;
        self.deletingMessage = @"作品刪除中...";
        [self.galleries removeAllObjects];
        [self.collectionView reloadData];
        
        __weak HistoriesViewController *weakSelf = self;
        [Couchbase deleteAllHistories: ^BOOL(NSInteger total, NSInteger index, HentaiInfo *info) {
            weakSelf.deletingMessage = [NSString stringWithFormat:@"作品刪除中 ( %td / %td )", index, total];
            [weakSelf.collectionView reloadData];
            NSString *folder = info.title_jpn.length ? info.title_jpn : info.title;
            folder = [[folder componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
            [[FilesManager documentFolder] rd:folder];
            return YES;
        } onFinish: ^(BOOL successed) {
            weakSelf.isDeleting = NO;
            [weakSelf.collectionView reloadData];
        }];
    }
}

@end
