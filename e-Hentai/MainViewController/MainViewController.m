//
//  MainViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

//avoid import cycle
#import "DownloadedViewController.h"

#define statusBarWithNavigationHeight 64.0f

@interface MainViewController ()

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSLock *rollLock;
@property (nonatomic, readonly) NSString *filterString;

@end

@implementation MainViewController

@dynamic filterString;

#pragma mark - dynamic

- (NSString *)filterString {
    NSMutableString *filterURLString = [NSMutableString stringWithFormat:@"http://g.e-hentai.org/?page=%lu", (unsigned long)self.listIndex];
    NSArray *filters = HentaiPrefer[@"filtersFlag"];
    
    //建立過濾 url
    for (NSInteger i = 0; i < [HentaiFilters count]; i++) {
        NSNumber *eachFlag = filters[i];
        if ([eachFlag boolValue]) {
            [filterURLString appendFormat:@"&%@", HentaiFilters[i][@"url"]];
        }
    }
    
    //去除掉空白換行字符後, 如果長度不為 0, 則表示有字
    NSCharacterSet *emptyCharacter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[HentaiPrefer[@"searchText"] componentsSeparatedByCharactersInSet:emptyCharacter] componentsJoinedByString:@""].length) {
        [filterURLString appendFormat:@"&f_search=%@", HentaiPrefer[@"searchText"]];
    }
    [filterURLString appendString:@"&f_apply=Apply+Filter"];
    return [filterURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - SearchFilterViewControllerDelegate

- (void)onSearchFilterDone {
    self.title = HentaiPrefer[@"searchText"];
    [self reloadDatas];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //無限滾
    if (indexPath.row >= [self.listArray count] - 15 && [self.rollLock tryLock]) {
        self.listIndex++;
        
        @weakify(self);
        [self loadList: ^(BOOL successed, NSArray *listArray) {
            @strongify(self);
            if (successed) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self.listArray addObjectsFromArray:listArray];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.listCollectionView reloadData];
                    });
                });
            }
            else {
                self.listIndex--;
            }
            [self.rollLock unlock];
        }];
    }
    GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    NSURL *imageURL = [NSURL URLWithString:self.listArray[indexPath.row][@"thumb"]];
    [cell.cellImageView sd_setImageWithURL:imageURL];
    cell.cellImageView.alpha = ([self.listArray[indexPath.row][@"rating"] floatValue] / 4.5f);
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
    BOOL isExist = NO;
    
    for (NSDictionary *eachSavedInfo in HentaiSaveLibraryArray) {
        if ([eachSavedInfo[@"hentaiInfo"][@"url"] isEqualToString:hentaiInfo[@"url"]]) {
            isExist = YES;
            break;
        }
    }
    
    if (isExist) {
        PhotoViewController *photoViewController = [PhotoViewController new];
        photoViewController.hentaiInfo = hentaiInfo;
        [self.delegate needToPushViewController:photoViewController];
    }
    else {
        @weakify(self);
        [UIAlertView hentai_alertViewWithTitle:hentaiInfo[@"category"] message:[self alertMessage:hentaiInfo] cancelButtonTitle:@"都不要~ O3O" otherButtonTitles:@[@"下載", @"直接看"] onClickIndex: ^(int clickIndex) {
            @strongify(self);
            if (clickIndex) {
                if ([HentaiDownloadCenter isDownloading:hentaiInfo]) {
                    [UIAlertView hentai_alertViewWithTitle:@"這本你正在抓~ O3O" message:nil cancelButtonTitle:@"好~ O3O"];
                }
                else {
                    PhotoViewController *photoViewController = [PhotoViewController new];
                    photoViewController.hentaiInfo = hentaiInfo;
                    [self.delegate needToPushViewController:photoViewController];
                }
            }
            else {
                [HentaiDownloadCenter addBook:hentaiInfo];
            }
        } onCancel:nil];
    }
}

#pragma mark - private

//重新讀取資料
- (void)reloadDatas {
    
    //清除GalleryCell的圖片暫存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    self.listIndex = 0;
    
    @weakify(self);
    [self loadList: ^(BOOL successed, NSArray *listArray) {
        @strongify(self);
        if (successed) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:listArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.listCollectionView reloadData];
                    [self.listCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    [self.refreshControl endRefreshing];
                });
            });
        }
        else {
            [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
        }
    }];
}

//把 request 的判斷都放到這個 method 裡面來
- (void)loadList:(void (^)(BOOL successed, NSArray *listArray))completion {
    [HentaiParser requestListAtFilterUrl:self.filterString completion: ^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            completion(YES, listArray);
        }
        else {
            completion(NO, nil);
        }
    }];
}

//製造來放 alertview 跳出來的訊息
- (NSString *)alertMessage:(NSDictionary *)hentaiInfo {
    NSMutableString *alertMessage = [NSMutableString string];
    [alertMessage appendString:@"這部作品叫做:\n"];
    [alertMessage appendFormat:@"%@\n", hentaiInfo[@"title"]];
    [alertMessage appendFormat:@"評價:%@\n", hentaiInfo[@"rating"]];
    [alertMessage appendFormat:@"總共: %@ 頁, %@\n", hentaiInfo[@"filecount"], hentaiInfo[@"filesize"]];
    return alertMessage;
}

//present 搜尋跟過濾
- (void)presentSearchFilter {
    SearchFilterViewController *searchFilter = [SearchFilterViewController new];
    searchFilter.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:searchFilter] animated:YES completion:nil];
}

#pragma mark viewdidload 中用到的初始方法

- (void)setupInitValues {
    
    //相關變數
    self.title = HentaiPrefer[@"searchText"];
    self.listIndex = 0;
    self.listArray = [NSMutableArray array];
    self.rollLock = [NSLock new];
    
    //調整畫面的大小
    CGRect screenSize = [UIScreen mainScreen].bounds;
    self.view.frame = screenSize;
    self.listCollectionView.frame = screenSize;
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(presentSearchFilter)];
    self.navigationItem.rightBarButtonItem = filterButton;
}

- (void)setupListCollectionViewBehavior {
    [self.listCollectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:@"GalleryCell"];
    
    //下拉更新
    self.refreshControl = [UIRefreshControl new];
    [self.listCollectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(reloadDatas) forControlEvents:UIControlEventValueChanged];
}

- (void)setupRecvNotifications {
    
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:HentaiDownloadSuccessNotification object:nil] subscribeNext: ^(NSNotification *notification) {
        @strongify(self);
        if (self && [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController == nil) {
            [UIAlertView hentai_alertViewWithTitle:@"下載完成!" message:notification.object cancelButtonTitle:@"好~ O3O"];
        }
    }];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupItemsOnNavigation];
    [self setupListCollectionViewBehavior];
    [self setupRecvNotifications];
    
    @weakify(self);
    [self loadList: ^(BOOL successed, NSArray *listArray) {
        @strongify(self);
        if (successed) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self.listArray addObjectsFromArray:listArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.listCollectionView reloadData];
                });
            });
        }
        else {
            [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
        }
    }];
}

@end
