//
//  ListViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListCell.h"
#import "EHentaiParser.h"
#import "ExHentaiParser.h"
#import "GalleryViewController.h"
#import "Couchbase.h"
#import "SearchViewController.h"

@interface ListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) Class parser;
@property (nonatomic, strong) NSMutableArray<HentaiInfo *> *galleries;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSLock *pageLocker;
@property (nonatomic, assign) BOOL isEndOfGalleries;

@end

@implementation ListViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.galleries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEndOfGalleries && indexPath.row + 20 >= self.galleries.count) {
        [self fetchGalleries];
    }
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(ListCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HentaiInfo *info = self.galleries[indexPath.row];
    cell.title.text = info.title_jpn.length ? info.title_jpn : info.title;
    cell.category.text = info.category;
    cell.rating.text = info.rating;
    [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:info.thumb] placeholderImage:nil options:SDWebImageHandleCookies];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HentaiInfo *info = self.galleries[indexPath.row];
    [self performSegueWithIdentifier:@"PushToGallery" sender:info];
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
}

- (void)reloadGalleries {
    [self.galleries removeAllObjects];
    [self.collectionView reloadData];
    self.pageIndex = 0;
    self.isEndOfGalleries = NO;
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
                    [strongSelf.collectionView reloadData];
                    strongSelf.pageIndex++;
                    strongSelf.isEndOfGalleries = infos.count == 0;
                }
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
