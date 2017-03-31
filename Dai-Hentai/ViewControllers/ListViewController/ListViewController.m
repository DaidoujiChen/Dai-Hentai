//
//  ListViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "PrivateListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListCell.h"
#import "EHentaiParser.h"
#import "ExHentaiParser.h"
#import "GalleryViewController.h"
#import "SearchViewController.h"

@implementation ListViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    BOOL extraCell = self.galleries.count == 0;
    return self.galleries.count + extraCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEndOfGalleries && indexPath.row + 20 >= self.galleries.count) {
        [self fetchGalleries];
    }
    
    UICollectionViewCell *cell;
    if (self.galleries.count == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ListCell class]]) {
        ListCell *listCell = (ListCell *)cell;
        HentaiInfo *info = self.galleries[indexPath.row];
        listCell.title.text = info.title_jpn.length ? info.title_jpn : info.title;
        listCell.category.text = info.category;
        listCell.rating.text = info.rating;
        [listCell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:info.thumb] placeholderImage:nil options:SDWebImageHandleCookies];
    }
    else if ([cell isKindOfClass:[MessageCell class]]) {
        [self showMessageTo:(MessageCell *)cell onLoading:self.isLoading];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.galleries.count) {
        HentaiInfo *info = self.galleries[indexPath.row];
        [self performSegueWithIdentifier:@"PushToGallery" sender:info];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width - 20;
    CGFloat height = 150;
    return CGSizeMake(width, height);
}

#pragma mark - Private Instance Method

- (void)initValues {
    self.parser = [HentaiParser parserType:HentaiParserTypeEh];
    self.galleries = [NSMutableArray array];
    self.pageIndex = 0;
    self.pageLocker = [NSLock new];
    self.isEndOfGalleries = NO;
    self.isLoading = YES;
}

- (void)showMessageTo:(MessageCell *)cell onLoading:(BOOL)isLoading {
    cell.activityView.hidden = !isLoading;
    if (isLoading) {
        [cell.activityView startAnimating];
        cell.messageLabel.text = @"列表載入中...";
    }
    else {
        [cell.activityView stopAnimating];
        cell.messageLabel.text = @"找不到相關作品呦";
    }
}

- (void)reloadGalleries {
    [self.galleries removeAllObjects];
    [self.collectionView reloadData];
    self.pageIndex = 0;
    self.isEndOfGalleries = NO;
    self.isLoading = YES;
    [self fetchGalleries];
}

- (void)fetchGalleries {
    if ([self.pageLocker tryLock]) {
        SearchInfo *info = [Couchbase searchInfo];
        __weak ListViewController *weakSelf = self;
        [self.parser requestListUsingFilter:[info query:self.pageIndex] completion: ^(HentaiParserStatus status, NSArray<HentaiInfo *> *infos) {
            if (weakSelf) {
                __strong ListViewController *strongSelf = weakSelf;
                if (status == HentaiParserStatusSuccess) {
                    [strongSelf.galleries addObjectsFromArray:infos];
                    strongSelf.pageIndex++;
                    strongSelf.isEndOfGalleries = infos.count == 0;
                }
                else {
                    strongSelf.isEndOfGalleries = YES;
                }
                strongSelf.isLoading = NO;
                [strongSelf.collectionView reloadData];
            }
            [weakSelf.pageLocker unlock];
        }];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
    [self reloadGalleries];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(layoutSubviews)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToGallery"]) {
        GalleryViewController *galleryViewController = (GalleryViewController *)segue.destinationViewController;
        galleryViewController.info = sender;
    }
    else if ([segue.identifier isEqualToString:@"PushToSearch"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.destinationViewController;
        searchViewController.info = [Couchbase searchInfo];
    }
}

- (IBAction)unwindFromSearch:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"PopToList"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        [Couchbase setSearchInfo:searchViewController.info];
        [self reloadGalleries];
    }
}

@end
