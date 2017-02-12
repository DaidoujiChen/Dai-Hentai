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

@interface ListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) Class parser;
@property (nonatomic, strong) NSMutableArray<HentaiInfo *> *galleries;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToGallery"]) {
        GalleryViewController *next = (GalleryViewController *)segue.destinationViewController;
        next.info = sender;
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
    self.galleries = [NSMutableArray array];
    self.parser = [HentaiParser parserType:HentaiParserTypeEh];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak ListViewController *weakSelf = self;
    [weakSelf.parser requestListAtFilterUrl:@"https://e-hentai.org/" completion: ^(HentaiParserStatus status, NSArray<HentaiInfo *> *infos) {
        if (status == HentaiParserStatusSuccess) {
            [weakSelf.galleries addObjectsFromArray:infos];
            [weakSelf.collectionView reloadData];
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(layoutSubviews)];
}

@end
