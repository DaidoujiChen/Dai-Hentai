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
#import "HentaiParser.h"
#import "GalleryViewController.h"
#import "SearchViewController.h"
#import "RelatedViewController.h"
#import "LoginViewController.h"
#import "ExCookie.h"
#import "NSTimer+Block.h"
#import "HentaiDownloadCenter.h"

#define color(r, g, b) [UIColor colorWithRed:(CGFloat)r / 255.0f green:(CGFloat)g / 255.0f blue:(CGFloat)b / 255.0f alpha:1.0f]

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
        listCell.category.textColor = [self categoryColor:info.category];
        listCell.rating.text = info.rating;
        listCell.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES usingBlock: ^{
            NSInteger progress = [HentaiDownloadCenter downloadProgress:info] * 100;
            if (labs(progress) != 100) {
                listCell.progress.text = [NSString stringWithFormat:@"DL: %@ %%", @(progress)];
            }
            else {
                listCell.progress.text = @"";
            }
        }];
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
        [self onCellBeSelectedAction:info];
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
    BOOL isExExist = [ExCookie isExist];
    HentaiParserType type = isExExist ? HentaiParserTypeEx : HentaiParserTypeEh;
    self.parser = [HentaiParser parserType:type];
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

- (void)onCellBeSelectedAction:(HentaiInfo *)info {
    __weak ListViewController *weakSelf = self;
    [UIAlertController showAlertTitle:@"O3O" message:[NSString stringWithFormat:@"這部作品有 %@ 頁呦", info.filecount] defaultOptions:@[ @"我要現在看", @"我要下載", @"用相關字詞搜尋" ] cancelOption:@"都不要 O3O" handler: ^(NSInteger optionIndex) {
        __strong ListViewController *strongSelf = weakSelf;
        switch (optionIndex) {
            case 1:
                [strongSelf performSegueWithIdentifier:@"PushToGallery" sender:info];
                break;
                
            case 2:
            {
                HentaiImagesManager *manager = [HentaiDownloadCenter manager:info andParser:self.parser];
                manager.downloadAll = YES;
                [manager fetch:nil];
                [Couchbase fetchUserLatestPage:info];
                break;
            }
                
            case 3:
                [strongSelf performSegueWithIdentifier:@"PushToRelated" sender:info];
                break;
                
            default:
                break;
        }
    }];
}

- (UIColor *)categoryColor:(NSString *)category {
    static NSDictionary *colorMapping = nil;
    if (!colorMapping) {
        colorMapping = @{ @"Doujinshi": color(255, 59, 59),
                          @"Manga": color(255, 186, 59),
                          @"Artist CG Sets": color(234, 220, 59),
                          @"Game CG Sets": color(59, 157, 59),
                          @"Western": color(164, 255, 76),
                          @"Non-H": color(76, 180, 255),
                          @"Image Sets": color(59, 59, 255),
                          @"Cosplay": color(117, 59, 159),
                          @"Asian Porn": color(243, 176, 243),
                          @"Misc": color(212, 212, 212)};
    }
    return colorMapping[category];
}

#pragma mark - IBAction

- (IBAction)unwindFromSearch:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"PopFromSearch"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        [Couchbase setSearchInfo:searchViewController.info];
        [self reloadGalleries];
    }
    else if ([segue.identifier isEqualToString:@"PopFromRelated"]) {
        RelatedViewController *relatedViewController = (RelatedViewController *)segue.sourceViewController;
        if (relatedViewController.selectedWords.count) {
            SearchInfo *searchInfo = [Couchbase searchInfo];
            searchInfo.keyword = [relatedViewController.selectedWords componentsJoinedByString:@" "];
            [Couchbase setSearchInfo:searchInfo];
            [self reloadGalleries];
        }
    }
}

- (IBAction)loginToExAction:(id)sender {
    __weak ListViewController *weakSelf = self;
    LoginWebViewController *loginWebViewController = [[LoginWebViewController alloc] initWithCompletion: ^{
        if (!weakSelf) {
            return;
        }
        __strong ListViewController *strongSelf = weakSelf;
        strongSelf.parser = [HentaiParser parserType:HentaiParserTypeEx];
        [strongSelf reloadGalleries];
    }];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginWebViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
    [self reloadGalleries];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *className = [NSString stringWithFormat:@"%s", object_getClassName(self)];
    if ([ExCookie isExist] && [className isEqualToString:@"ListViewController"]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
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
        galleryViewController.parser = self.parser;
    }
    else if ([segue.identifier isEqualToString:@"PushToSearch"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.destinationViewController;
        searchViewController.info = [Couchbase searchInfo];
    }
    else if ([segue.identifier isEqualToString:@"PushToRelated"]) {
        RelatedViewController *relatedViewController = (RelatedViewController *)segue.destinationViewController;
        relatedViewController.info = sender;
    }
}

@end
