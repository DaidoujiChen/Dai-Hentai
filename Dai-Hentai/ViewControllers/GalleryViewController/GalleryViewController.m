//
//  GalleryViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/14.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryCollectionViewHandler.h"
#import "HentaiParser.h"
#import "FilesManager.h"
#import "DBGallery.h"
#import "UIAlertController+Block.h"
#import "HentaiDownloadCenter.h"
#import "DBUserPreference.h"

@interface GalleryViewController () <GalleryCollectionViewHandlerDelegate, HentaiImagesManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirect;
@property (nonatomic, strong) GalleryCollectionViewHandler *collectionViewHandler;
@property (nonatomic, assign) NSInteger maxAllowScrollIndex;
@property (nonatomic, assign) NSInteger userCurrentIndex;
@property (nonatomic, assign) BOOL rotating;
@property (nonatomic, strong) HentaiImagesManager *manager;
@property (nonatomic, assign) BOOL leaveByDelete;

@end

@implementation GalleryViewController

#pragma mark - GalleryCollectionViewHandlerDelegate

// 總共可顯示數量
- (NSInteger)totalCount {
    return self.maxAllowScrollIndex;
}

// 觸發讀取圖片
- (void)toggleLoadPages {
    if (self.userCurrentIndex + 20 >= self.manager.imagePages.count) {
        [self.manager fetch:nil];
    }
}

// 觸發顯示圖片
- (void)toggleDisplayImageAt:(NSIndexPath *)indexPath inCell:(GalleryCell *)cell {
    if ([self.manager isReadyAt:indexPath.row]) {
        [self.manager loadImageAt:indexPath.row completion: ^(UIImage *image) {
            cell.imageView.image = image;
        }];
        return;
    }
    
    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [HentaiImagesManager placeholder];
    [self.manager downloadImageAt:indexPath.row];
}

// 取得該 cell 大小
- (CGSize)cellSizeAt:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView {
    if (self.rotating) {
        return CGSizeZero;
    }
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height;
    if (self.scrollDirect == UICollectionViewScrollDirectionVertical) {
        CGSize imageSize;
        if ([self.manager isReadyAt:indexPath.row]) {
            imageSize.width = self.manager.heights[@(indexPath.row)][@"width"].floatValue;
            imageSize.height = self.manager.heights[@(indexPath.row)][@"height"].floatValue;
        }
        else {
            imageSize.width = [HentaiImagesManager placeholder].size.width;
            imageSize.height = [HentaiImagesManager placeholder].size.height;
        }
        height = imageSize.height * (width / imageSize.width);
    }
    else {
        height = CGRectGetHeight(collectionView.bounds) - collectionView.contentInset.top - collectionView.contentInset.bottom;
    }
    return CGSizeMake(width, height);
}

// 回傳使用者正看到第幾頁
- (void)userCurrentIndex:(NSInteger)index {
    self.userCurrentIndex = index;
    [self refreshTitle];
}

#pragma mark - HentaiImagesManager

- (void)imageHeightChangedAtPageIndex:(NSInteger)pageIndex {
    [self refreshMaxIndexAndReload:pageIndex];
    [self refreshTitle];
}

#pragma mark - Private Instance Method

#pragma mark * 轉向控制

// 顯示方向橫直轉
- (void)toggleDirection {
    NSString *alertMessage;
    if (self.scrollDirect == UICollectionViewScrollDirectionVertical) {
        self.scrollDirect = UICollectionViewScrollDirectionHorizontal;
        alertMessage = @"閱讀方向改為橫向";
    }
    else {
        self.scrollDirect = UICollectionViewScrollDirectionVertical;
        alertMessage = @"閱讀方向改為直向";
    }
    [UIAlertController showAlertTitle:@"O3O" message:alertMessage defaultOptions:nil cancelOption:nil handler:nil].dismissAfter(0.75f);
    
    NSInteger userCurrentIndex = self.userCurrentIndex;
    self.collectionView.pagingEnabled = self.scrollDirect == UICollectionViewScrollDirectionHorizontal;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = self.scrollDirect;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [self scrollToIndex:userCurrentIndex];
}

#pragma mark * 提示窗

- (void)galleryNotAppear {
    [UIAlertController showAlertTitle:@"O3O" message:@"這部作品好像不見囉" defaultOptions:nil cancelOption:@"好 O3O" handler:nil];
}

- (void)foundLatestPage {
    NSInteger userLatestPage = [self.info latestPage];
    if (userLatestPage > 1) {
        __weak GalleryViewController *weakSelf = self;
        [UIAlertController showAlertTitle:@"O3O" message:@"您曾經閱讀過此作品" defaultOptions:@[ [NSString stringWithFormat:@"繼續從 %td 頁看起", userLatestPage] ] cancelOption:@"我要從頭看" handler: ^(NSInteger optionIndex) {
            if (optionIndex) {
                [weakSelf scrollToIndex:userLatestPage];
            }
        }];
    }
}

#pragma mark * 刷新顯示相關

// 自動滑到某頁
- (void)scrollToIndex:(NSInteger)index {
    if (!self.maxAllowScrollIndex) {
        return;
    }
    UICollectionViewScrollPosition scrollDirection = self.scrollDirect == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:scrollDirection animated:NO];
}

// 刷新新 load 好的頁面
- (void)refreshMaxIndexAndReload:(NSInteger)pageIndex {
    NSInteger preMaxAllowScrollIndex = self.maxAllowScrollIndex;
    NSArray<NSNumber *> *sortKeys = [self.manager.heights.allKeys sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray array];
    NSInteger index;
    for (index = preMaxAllowScrollIndex; index < sortKeys.count; index++) {
        NSNumber *sortKey = sortKeys[index];
        if ([@(index) compare:sortKey] == NSOrderedSame) {
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        else {
            break;
        }
    }
    self.maxAllowScrollIndex = index;
    
    NSMutableArray *reloadIndexPaths = [NSMutableArray array];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath && indexPath.row == pageIndex) {
            [reloadIndexPaths addObject:indexPath];
            break;
        }
    }
    
    [self.collectionView performBatchUpdates: ^{
        [self.collectionView reloadItemsAtIndexPaths:reloadIndexPaths];
        [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
    } completion:nil];
}

// 重新顯示 title
- (void)refreshTitle {
    if (self.manager.heights.count == 0) {
        self.title = @"===== 讀取中 =====";
        return;
    }
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"當前:%@ ", @(self.userCurrentIndex)];
    if (self.maxAllowScrollIndex != self.manager.imagePages.count) {
        [title appendFormat:@"卡在:%@ ", @(self.maxAllowScrollIndex + 1)];
    }
    else {
        [title appendFormat:@"總共:%@ ", self.info.filecount];
    }
    self.title = title;
}

#pragma mark * Show / Hidden Bars Animation

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer {
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionDown:
        case UISwipeGestureRecognizerDirectionUp:
            if (self.scrollDirect == UICollectionViewScrollDirectionHorizontal) {
                [self toggleDirection];
            }
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
        case UISwipeGestureRecognizerDirectionRight:
            if (self.scrollDirect == UICollectionViewScrollDirectionVertical) {
                [self toggleDirection];
            }
            break;
    }
}

#pragma mark * navigation bar button action

- (void)deleteThis {
    __weak GalleryViewController *weakSelf = self;
    [UIAlertController showAlertTitle:@"O3O" message:@"我們現在這部作品囉!" defaultOptions:@[ @"好 O3Ob" ] cancelOption:@"先不要好了 OwO\"" handler: ^(NSInteger optionIndex) {
        if (!weakSelf) {
            return;
        }
        
        __strong GalleryViewController *strongSelf = weakSelf;
        if (optionIndex) {
            strongSelf.leaveByDelete = YES;
            [strongSelf.manager stop];
            [HentaiDownloadCenter bye:strongSelf.info];
            
            [DBGallery deleteDownloaded:strongSelf.info handler: ^{
                [[FilesManager documentFolder] rd:[strongSelf.info folder]];
            } onFinish: ^(BOOL successed) {
                [strongSelf.delegate helpToReloadList];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)giveMeAll {
    [self.manager giveMeAll];
    [self.info moveToDownloaded];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteThis)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

#pragma mark * init

// 初始化參數們
- (void)initValues {
    self.title = @"Loading...";
    
    // collection view 相關設定
    self.collectionViewHandler = [GalleryCollectionViewHandler new];
    self.collectionView.dataSource = self.collectionViewHandler;
    self.collectionView.delegate = self.collectionViewHandler;
    self.collectionViewHandler.delegate = self;
    self.scrollDirect = [DBUserPreference info].scrollDirection.integerValue;
    self.collectionView.pagingEnabled = self.scrollDirect == UICollectionViewScrollDirectionHorizontal;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = self.scrollDirect;
    
    // 讀取頁面相關設定
    self.maxAllowScrollIndex = 0;
    
    // 下載器
    self.manager = [HentaiDownloadCenter manager:self.info andParser:self.parser];
    self.manager.delegate = self;
    self.leaveByDelete = NO;
    
    // 設定 navigation bar 上的標題
    self.navigationItem.prompt = [self.info bestTitle];
    
    // 在 navigation bar 上加一個下載的按鈕, 或是刪除掉的按鈕
    if ([self.info isDownloaded]) {
        [self.manager giveMeAll];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteThis)];
        self.navigationItem.rightBarButtonItem = deleteButton;
    }
    else {
        UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(giveMeAll)];
        self.navigationItem.rightBarButtonItem = downloadButton;
    }
    
    // 轉向時的判斷
    self.rotating = NO;
    
    // 顯示相關
    for (UISwipeGestureRecognizerDirection direction = UISwipeGestureRecognizerDirectionRight; direction <= UISwipeGestureRecognizerDirectionDown; direction <<= 1) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipe setDirection:direction];
        [self.collectionView addGestureRecognizer:swipe];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    NSLog(@"===== %@, %@", [FilesManager documentFolder].currentPath, self.info.filecount);
    [super viewDidLoad];
    [self initValues];
    
    __weak GalleryViewController *weakSelf = self;
    [self.manager fetch: ^(BOOL isExist) {
        if (!weakSelf) {
            return;
        }
        
        __strong GalleryViewController *strongSelf = weakSelf;
        if (isExist) {
            [strongSelf foundLatestPage];
        }
        else {
            [strongSelf galleryNotAppear];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.hidesBarsOnTap = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.leaveByDelete) {
        [self.info setLatestPage:self.userCurrentIndex];
    }
    [HentaiDownloadCenter bye:self.info];

    self.navigationController.hidesBarsOnTap = NO;
}

// 當轉向時需要處理 cell 的 size, 避免產生不必要的 warning
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSInteger userCurrentIndex = self.userCurrentIndex;
    self.rotating = YES;
    
    __weak GalleryViewController *weakSelf = self;
    [coordinator animateAlongsideTransition:nil completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (!weakSelf) {
            return;
        }
        
        __strong GalleryViewController *strongSelf = weakSelf;
        strongSelf.rotating = NO;
        [strongSelf.collectionView.collectionViewLayout invalidateLayout];
        [strongSelf scrollToIndex:userCurrentIndex];
    }];
}

// 這個畫面讓 status bar 消失
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// 版面有變動時, 會重設大小
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

// 並且讓 cell 們都重新配置
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(layoutSubviews)];
}

- (void)dealloc {
    NSLog(@"===== GalleryViewController dealloc");
}

@end
