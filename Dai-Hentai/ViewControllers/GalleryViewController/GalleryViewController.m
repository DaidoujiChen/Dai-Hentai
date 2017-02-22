//
//  GalleryViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/14.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryCollectionViewHandler.h"
#import "EHentaiParser.h"
#import "ExHentaiParser.h"
#import "FilesManager.h"

@interface GalleryViewController () <GalleryCollectionViewHandlerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirect;
@property (nonatomic, strong) GalleryCollectionViewHandler *collectionViewHandler;
@property (nonatomic, assign) NSInteger totalPageIndex;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger maxAllowScrollIndex;
@property (nonatomic, assign) NSInteger userCurrentIndex;
@property (nonatomic, strong) FMStream *manager;
@property (nonatomic, strong) NSMutableArray<NSString *> *imagePages;
@property (nonatomic, strong) NSMutableArray<NSString *> *loadingImagePages;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *heights;
@property (nonatomic, strong) NSLock *pageLocker;
@property (nonatomic, assign) BOOL rotating;
@property (nonatomic, assign) BOOL isBarsHidden;

@end

@implementation GalleryViewController

#pragma mark - GalleryCollectionViewHandlerDelegate

// 總共可顯示數量
- (NSInteger)totalCount {
    return self.maxAllowScrollIndex;
}

// 觸發讀取圖片
- (void)toggleLoadPages {
    if (self.currentPageIndex <= self.totalPageIndex && self.userCurrentIndex+ 20 >= self.imagePages.count) {
        [self loadPages];
    }
}

// 觸發顯示圖片
- (void)toggleDisplayImageAt:(NSIndexPath *)indexPath inCell:(GalleryCell *)cell {
    if ([self isFailedImageAtIndex:indexPath.row]) {
        cell.galleryImageView.backgroundColor = [UIColor whiteColor];
        cell.galleryImageView.image = [UIImage imageNamed:@"placeholder"];
        [self loadImage:self.imagePages[indexPath.row]];
    }
    else {
        __weak GalleryViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf) {
                __strong GalleryViewController *strongSelf = weakSelf;
                NSString *filename = strongSelf.imagePages[indexPath.row].lastPathComponent;
                UIImage *image = [UIImage imageWithData:[strongSelf.manager read:filename]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.galleryImageView.image = image;
                });
            }
        });
    }
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
        if (self.heights[@(indexPath.row)][@"width"].floatValue == 0 && self.heights[@(indexPath.row)][@"height"].floatValue == 0) {
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            imageSize.width = placeholderImage.size.width;
            imageSize.height = placeholderImage.size.height;
        }
        else {
            imageSize.width = self.heights[@(indexPath.row)][@"width"].floatValue;
            imageSize.height = self.heights[@(indexPath.row)][@"height"].floatValue;
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

#pragma mark - IBAction

// 顯示方向橫直轉
- (IBAction)toggleDirection:(id)sender {
    if (self.scrollDirect == UICollectionViewScrollDirectionVertical) {
        self.scrollDirect = UICollectionViewScrollDirectionHorizontal;
    }
    else {
        self.scrollDirect = UICollectionViewScrollDirectionVertical;
    }
    
    NSInteger userCurrentIndex = self.userCurrentIndex;
    self.collectionView.pagingEnabled = self.scrollDirect == UICollectionViewScrollDirectionHorizontal;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = self.scrollDirect;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [self scrollToIndex:userCurrentIndex];
}

#pragma mark - Private Instance Method

#pragma mark * 刷新顯示相關

// 自動滑到某頁
- (void)scrollToIndex:(NSInteger)index {
    UICollectionViewScrollPosition scrollDirection = self.scrollDirect == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:scrollDirection animated:NO];
}

// 刷新新 load 好的頁面
- (void)refreshMaxIndexAndReload {
    NSInteger preMaxAllowScrollIndex = self.maxAllowScrollIndex;
    NSArray<NSNumber *> *sortKeys = [self.heights.allKeys sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *reloadIndexPaths = [NSMutableArray array];
    NSInteger index;
    for (index = preMaxAllowScrollIndex; index < sortKeys.count; index++) {
        NSNumber *sortKey = sortKeys[index];
        if ([@(index) compare:sortKey] == NSOrderedSame) {
            [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        else {
            break;
        }
    }
    self.maxAllowScrollIndex = index;
    
    [self.collectionView performBatchUpdates: ^{
        [self.collectionView insertItemsAtIndexPaths:reloadIndexPaths];
    } completion:nil];
}

// 重新顯示 title
- (void)refreshTitle {
    self.title = [NSString stringWithFormat:@"%ld(%ld/%ld/%@)", self.userCurrentIndex, self.maxAllowScrollIndex, self.heights.count, self.info.filecount];
}

#pragma mark * 讀取圖片相關

// 判斷是否為讀取失敗的圖片
- (BOOL)isFailedImageAtIndex:(NSInteger)index {
    return (self.heights[@(index)][@"width"].floatValue == 0 && self.heights[@(index)][@"height"].floatValue == 0);
}

// 處理完圖片做顯示
- (void)displayImage:(NSString *)imagePage data:(NSData *)data isNeedWriteFile:(BOOL)isNeedWriteFile {
    NSString *filename = imagePage.lastPathComponent;
    NSInteger pageIndex = [[filename componentsSeparatedByString:@"-"][1] integerValue] - 1;
    
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        imageWidth = image.size.width;
        imageHeight = image.size.height;
    }
    
    __weak GalleryViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            __strong GalleryViewController *strongSelf = weakSelf;
            if (data && isNeedWriteFile) {
                [strongSelf.manager write:data filename:filename];
            }
            strongSelf.heights[@(pageIndex)] = @{ @"width": @(imageWidth), @"height": @(imageHeight) };
            [strongSelf refreshMaxIndexAndReload];
            [strongSelf refreshTitle];
        }
    });
}

// 當圖片準備好時
- (void)onImageReady:(NSString *)imagePage data:(NSData *)data isNeedWriteFile:(BOOL)isNeedWriteFile {
    if ([NSThread isMainThread]) {
        __weak GalleryViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf) {
                __strong GalleryViewController *strongSelf = weakSelf;
                [strongSelf displayImage:imagePage data:data isNeedWriteFile:isNeedWriteFile];
            }
        });
    }
    else {
        [self displayImage:imagePage data:data isNeedWriteFile:isNeedWriteFile];
    }
}

// 從 https://e-hentai.org/s/107f1048f2/1030726-1 頁面中
// 取得真實的圖片連結 ex: http://114.33.249.224:18053/h/e6d61323621dc2c578266d3192578edb66ad1517-99131-1280-845-jpg/keystamp=1487226600-fd28acd1f7;fileindex=50314533;xres=1280/60785277_p0.jpg
- (void)loadImage:(NSString *)imagePage {
    if (![self.loadingImagePages containsObject:imagePage]) {
        [self.loadingImagePages addObject:imagePage];
        __weak GalleryViewController *weakSelf = self;
        [EHentaiParser requestImageURL:imagePage completion: ^(HentaiParserStatus status, NSString *imageURL) {
            if (weakSelf) {
                if (status == HentaiParserStatusSuccess) {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (weakSelf) {
                            __strong GalleryViewController *strongSelf = weakSelf;
                            [strongSelf onImageReady:imagePage data:data isNeedWriteFile:YES];
                        }
                        
                        if (error) {
                            NSLog(@"===== Load imagePage Fail : %@", imagePage);
                        }
                        [weakSelf.loadingImagePages removeObject:imagePage];
                    }];
                    [task resume];
                    [NSTimer scheduledTimerWithTimeInterval:30.0f repeats:NO block: ^(NSTimer *timer) {
                        if (task.state != NSURLSessionTaskStateCompleted) {
                            [task cancel];
                        }
                    }];
                }
                else {
                    NSLog(@"===== requestImageURLWithURLString fail");
                    [weakSelf.loadingImagePages removeObject:imagePage];
                }
            }
        }];
    }
}

// 從 https://e-hentai.org/g/1030726/c854450405/ 大頁中
// 讀取每個分別的小頁 ex: https://e-hentai.org/s/107f1048f2/1030726-1
- (void)loadPages {
    if ([self.pageLocker tryLock] && self.currentPageIndex <= self.totalPageIndex) {
        
        __weak GalleryViewController *weakSelf = self;
        [EHentaiParser requestImagePagesBy:self.info atIndex:self.currentPageIndex completion: ^(HentaiParserStatus status, NSArray<NSString *> *imagePages) {
            if (weakSelf) {
                __strong GalleryViewController *strongSelf = weakSelf;
                if (status == HentaiParserStatusSuccess) {
                    strongSelf.currentPageIndex++;
                    [strongSelf.imagePages addObjectsFromArray:imagePages];
                    
                    for (NSString *imagePage in imagePages) {
                        NSString *filename = imagePage.lastPathComponent;
                        NSData *existData = [strongSelf.manager read:filename];
                        if (existData) {
                            [strongSelf onImageReady:imagePage data:existData isNeedWriteFile:NO];
                        }
                        else {
                            [strongSelf loadImage:imagePage];
                        }
                    }
                }
                else {
                    NSLog(@"===== requestImagePagesBy fail");
                }
                [strongSelf.pageLocker unlock];
            }
        }];
    }
}

#pragma mark * Show / Hidden Bars Animation

- (void)layoutBars {
    CGRect newFrame = self.navigationController.navigationBar.frame;
    
    // navigation bar 伸縮
    if (self.isBarsHidden) {
        newFrame.origin.y = -CGRectGetHeight(newFrame);
    }
    else {
        newFrame.origin.y = 0;
    }
    self.navigationController.navigationBar.frame = newFrame;
    [self.navigationController.navigationBar layoutSubviews];
    
    // tabbar 伸縮
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    newFrame = self.tabBarController.tabBar.frame;
    if (self.isBarsHidden) {
        newFrame.origin.y = screenHeight;
    }
    else {
        newFrame.origin.y = screenHeight - CGRectGetHeight(newFrame);
    }
    self.tabBarController.tabBar.frame = newFrame;
    [self.tabBarController.tabBar layoutSubviews];
}

- (void)layoutCollectionView {
    
    // collection view 伸縮
    UIEdgeInsets newInsets = self.collectionView.contentInset;
    if (self.isBarsHidden) {
        newInsets.top = 0;
        newInsets.bottom = 0;
    }
    else {
        newInsets.top = CGRectGetHeight(self.navigationController.navigationBar.frame);
        newInsets.bottom = CGRectGetHeight(self.tabBarController.tabBar.frame);
    }
    self.collectionView.contentInset = newInsets;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [self.tabBarController.tabBar.layer removeAllAnimations];
    
    self.isBarsHidden = !self.isBarsHidden;
    __weak GalleryViewController *weakSelf = self;
    [UIView animateWithDuration:0.3f animations: ^{
        if (weakSelf) {
            __strong GalleryViewController *strongSelf = weakSelf;
            [strongSelf layoutBars];
        }
    } completion: ^(BOOL finished) {
        if (weakSelf && finished) {
            __strong GalleryViewController *strongSelf = weakSelf;
            [strongSelf layoutCollectionView];
        }
    }];
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
    self.scrollDirect = UICollectionViewScrollDirectionVertical;
    self.collectionView.pagingEnabled = self.scrollDirect == UICollectionViewScrollDirectionHorizontal;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = self.scrollDirect;
    
    // 讀取頁面相關設定
    self.pageLocker = [NSLock new];
    self.imagePages = [NSMutableArray array];
    self.loadingImagePages = [NSMutableArray array];
    self.heights = [NSMutableDictionary dictionary];
    self.totalPageIndex = floor(self.info.filecount.floatValue / 40.0f);
    self.currentPageIndex = 0;
    self.maxAllowScrollIndex = 0;
    
    // 儲存位置設定
    NSString *folder = self.info.title_jpn.length ? self.info.title_jpn : self.info.title;
    folder = [[folder componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
    self.manager = [[FilesManager documentFolder] fcd:folder];
    self.navigationItem.prompt = folder;
    
    // 轉向時的判斷
    self.rotating = NO;
    
    // 顯示相關
    self.isBarsHidden = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    NSLog(@"===== %@, %@", [FilesManager documentFolder].currentPath, self.info.filecount);
    [super viewDidLoad];
    [self initValues];
    [self loadPages];
}

// 當轉向時需要處理 cell 的 size, 避免產生不必要的 warning
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSInteger userCurrentIndex = self.userCurrentIndex;
    self.rotating = YES;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    __weak GalleryViewController *weakSelf = self;
    [coordinator animateAlongsideTransition:nil completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (weakSelf) {
            __strong GalleryViewController *strongSelf = weakSelf;
            strongSelf.rotating = NO;
            [strongSelf layoutBars];
            [strongSelf layoutCollectionView];
            [strongSelf scrollToIndex:userCurrentIndex];
        }
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
    NSLog(@"===== dealloc");
}

@end
