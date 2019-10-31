//
//  ListViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "PrivateListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HentaiParser.h"
#import "SearchViewController.h"
#import "RelatedViewController.h"
#import "Dai_Hentai-Swift.h"
#import "NSTimer+Block.h"
#import "HentaiDownloadCenter.h"

#define color(r, g, b) [UIColor colorWithRed:(CGFloat)r / 255.0f green:(CGFloat)g / 255.0f blue:(CGFloat)b / 255.0f alpha:1.0f]

@interface ListViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *exLoginBarButtonItem;

@end

@implementation ListViewController

#pragma mark - GalleryViewControllerDelegate

- (void)helpToReloadList {
    [self reloadGalleries];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    BOOL extraCell = self.galleries.count == 0;
    return self.galleries.count + extraCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLoading) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    }
    
    if (!self.isEndOfGalleries && indexPath.row + 20 >= self.galleries.count) {
        [self fetchGalleries];
    }
    
    if (self.galleries.count == 0) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    }

    return [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ListCell class]]) {
        ListCell *listCell = (ListCell *)cell;
        HentaiInfo *info = self.galleries[indexPath.row];
        listCell.title.text = [info bestTitle];
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
    [self fetchGalleries];
}

- (void)fetchGalleries {
    self.isLoading = YES;
    if ([self.pageLocker tryLock]) {
        SearchInfo *info = [DBSearchSetting info];
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

- (NSMutableArray<NSDictionary<NSString *, void(^)(void)> *> *)behaviorsForInfo:(HentaiInfo *)info {
    
    __weak ListViewController *weakSelf = self;
    NSMutableArray<NSDictionary<NSString *, void(^)(void)> *> *behaviors = [NSMutableArray array];
    [behaviors addObject:@{ @"我要現在看": ^(void) {
        if (!weakSelf) {
            return;
        }
        __strong ListViewController *strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:@"PushToGallery" sender:info];
    } }];
    
    if (![info isDownloaded]) {
        [behaviors addObject:@{ @"我要下載": ^(void) {
            if (!weakSelf) {
                return;
            }
            __strong ListViewController *strongSelf = weakSelf;
            HentaiImagesManager *manager = [HentaiDownloadCenter manager:info andParser:strongSelf.parser];
            [manager giveMeAll];
            [manager fetch:nil];
            [info latestPage];
            [info moveToDownloaded];
        } }];
    }
    
    [behaviors addObject:@{ @"用相關字詞搜尋": ^(void) {
        if (!weakSelf) {
            return;
        }
        __strong ListViewController *strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:@"PushToRelated" sender:info];
    } }];
    
    return behaviors;
}

- (void)onCellBeSelectedAction:(HentaiInfo *)info {
    
    __weak ListViewController *weakSelf = self;
    NSMutableArray<NSDictionary<NSString *, void(^)(void)> *> *behaviors = [self behaviorsForInfo:info];
    
    NSMutableArray<NSString *> *options = [NSMutableArray array];
    for (NSInteger index = 0; index < behaviors.count; index++) {
        [options addObject:behaviors[index].allKeys.firstObject];
    }
    
    [UIAlertController showAlertTitle:@"O3O" message:[NSString stringWithFormat:@"這部作品有 %@ 頁呦", info.filecount] defaultOptions:options cancelOption:@"都不要 O3O" handler: ^(NSInteger optionIndex) {
        if (!weakSelf) {
            return;
        }
        
        NSInteger fixOptionIndex = optionIndex - 1;
        if (fixOptionIndex >= behaviors.count) {
            return;
        }
        
        void (^invoke)(void) = behaviors[fixOptionIndex].allValues.firstObject;
        invoke();
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

- (void)resetButtonAndParser {
    NSString *className = [NSString stringWithFormat:@"%s", object_getClassName(self)];
    if ([className isEqualToString:@"ListViewController"]) {
        Class newParser;
        if ([ExCookie isExist]) {
            self.navigationItem.leftBarButtonItem = nil;
            newParser = [HentaiParser parserType:HentaiParserTypeEx];
        }
        else {
            self.navigationItem.leftBarButtonItem = self.exLoginBarButtonItem;
            newParser = [HentaiParser parserType:HentaiParserTypeEh];
        }
        
        if (newParser != self.parser) {
            self.parser = newParser;
            [self reloadGalleries];
        }
    }
}

#pragma mark - IBAction

- (IBAction)unwindFromSearch:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"PopFromSearch"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        SearchInfo *info = searchViewController.info;
        
        // 如果有從提示中選取, 將 keyword 改為提示字選取的內容
        if ([info hints].count) {
            NSMutableString *newKeyword = [NSMutableString string];
            for (NSString *hint in [info hints]) {
                NSRange range = [newKeyword.lowercaseString rangeOfString:hint.lowercaseString];
                if (range.location == NSNotFound) {
                    [newKeyword appendFormat:@"%@ ", hint];
                }
            }
            info.keyword = newKeyword;
        }
        [DBSearchSetting setInfo:info];
        [self reloadGalleries];
    }
    else if ([segue.identifier isEqualToString:@"PopFromRelated"]) {
        RelatedViewController *relatedViewController = (RelatedViewController *)segue.sourceViewController;
        if (relatedViewController.selectedWords.count) {
            SearchInfo *searchInfo = [DBSearchSetting info];
            searchInfo.keyword = [relatedViewController.selectedWords componentsJoinedByString:@" "];
            [DBSearchSetting setInfo:searchInfo];
            [self reloadGalleries];
        }
    }
}

- (IBAction)loginToExAction:(id)sender {
    __weak ListViewController *weakSelf = self;
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithCompletion: ^{
        if (!weakSelf) {
            return;
        }
        __strong ListViewController *strongSelf = weakSelf;
        [strongSelf resetButtonAndParser];
    }];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
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
        galleryViewController.delegate = self;
        galleryViewController.info = sender;
        galleryViewController.parser = self.parser;
        galleryViewController.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"PushToSearch"]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.destinationViewController;
        searchViewController.info = [DBSearchSetting info];
    }
    else if ([segue.identifier isEqualToString:@"PushToRelated"]) {
        RelatedViewController *relatedViewController = (RelatedViewController *)segue.destinationViewController;
        relatedViewController.info = sender;
    }
}

@end
