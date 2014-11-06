//
//  PhotoViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

//目前漫畫是在網路上的哪一頁
@property (nonatomic, assign) NSUInteger hentaiIndex;

//漫畫每一頁的 url 網址
@property (nonatomic, strong) NSMutableArray *hentaiImageURLs;

//記錄 fail 了幾次
@property (nonatomic, strong) NSMutableDictionary *retryMap;
@property (nonatomic, assign) NSUInteger failCount;

//已經下載好的漫畫結果
//結構 key 是檔案名稱 (url 網址的 lastTwoPathComponent) NSString
//value 是該檔案的高度 NSNumber
@property (nonatomic, strong) NSMutableDictionary *hentaiResults;

//從漫畫主頁的網址拆出來一組獨一無二的 key, 用作儲存識別
@property (nonatomic, readonly) NSString *hentaiKey;

//真正可以看到哪一頁 (下載的檔案需要有連續, 數字才會增長)
@property (nonatomic, assign) NSInteger realDisplayCount;
@property (nonatomic, assign) NSUInteger downloadKey;
@property (nonatomic, assign) BOOL isRemovedHUD;
@property (nonatomic, strong) NSOperationQueue *hentaiQueue;
@property (nonatomic, strong) FMStream *hentaiFilesManager;

@property (nonatomic, strong) NSString *hentaiURLString;
@property (nonatomic, strong) NSString *maxHentaiCount;
@property (nonatomic, strong) NSIndexPath *sharedIndexPath;
@property (nonatomic, strong) NSLock *shareLock;

- (void)backAction;
- (void)saveAction;
- (void)deleteAction;

- (void)setupInitValues;

- (CGSize)imagePortraitHeight:(CGSize)landscapeSize;
- (void)preloadImages:(NSArray *)images;
- (NSInteger)availableCount;

- (void)waitingOnDownloadFinish;
- (void)checkEndOfFile;
- (void)setupForAlreadyDownloadKey:(NSUInteger)downloadKey;
- (NSUInteger)foundDownloadKey;

@end

@implementation PhotoViewController

#pragma mark - getter

@dynamic hentaiKey;

- (NSString *)hentaiKey {
    return [self.hentaiInfo hentai_hentaiKey];
}

#pragma mark - ibaction

- (IBAction)singleTapScreenAction:(id)sender {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - navigation bar button action

- (void)backAction {
    HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
    hentaiNavigation.autoRotate = NO;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    
    //FakeViewController 是一個硬把畫面轉直的媒介
    FakeViewController *fakeViewController = [FakeViewController new];
    fakeViewController.BackBlock = ^() {
        [hentaiNavigation popViewControllerAnimated:YES];
    };
    [self presentViewController:fakeViewController animated:NO completion: ^{
        dispatch_after(0, dispatch_get_main_queue(), ^{
            [fakeViewController onPresentCompletion];
        });
    }];
}

- (void)saveAction {
    [UIAlertView hentai_alertViewWithTitle:@"你想要儲存這本漫畫嗎?" message:@"過程是不能中斷的, 請保持網路順暢." cancelButtonTitle:@"不要好了...Q3Q" otherButtonTitles:@[@"衝吧! O3O"] onClickIndex: ^(NSInteger clickIndex) {
        [DaiInboxHUD show];
        [self waitingOnDownloadFinish];
    } onCancel: ^{
    }];
}

- (void)deleteAction {
    [[FilesManager documentFolder] rd:self.hentaiKey];
    LWPSafe(
            [HentaiSaveLibraryArray removeObjectAtIndex:self.downloadKey];
            LWPForceWrite();
    )
    [self backAction];
}

#pragma mark - setup inits

- (void)setupInitValues {
    self.title = @"Loading...";
    
    //navigation bar 上的兩個 button
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //註冊 cell
    [self.hentaiTableView registerClass:[HentaiPhotoCell class] forCellReuseIdentifier:@"HentaiPhotoCell"];
    
    self.hentaiURLString = self.hentaiInfo[@"url"];
    self.maxHentaiCount = self.hentaiInfo[@"filecount"];
    
    //OperationQueue 限制數量為 5
    self.hentaiQueue = [NSOperationQueue new];
    [self.hentaiQueue setMaxConcurrentOperationCount:5];
    
    //相關參數初始化
    self.hentaiImageURLs = [NSMutableArray array];
    self.retryMap = [NSMutableDictionary dictionary];
    if (HentaiCacheLibraryDictionary[self.hentaiKey]) {
        //這邊要多一個判斷, 當 cache 資料夾下如果找不到東西了, 表示圖片已經被清掉
        if ([[[FilesManager cacheFolder] fcd:@"Hentai"] cd:self.hentaiKey]) {
            self.hentaiResults = HentaiCacheLibraryDictionary[self.hentaiKey];
        }
        else {
            self.hentaiResults = [NSMutableDictionary dictionary];
            LWPSafe(
                    [HentaiCacheLibraryDictionary removeObjectForKey:self.hentaiKey];
                    LWPForceWrite();
            )
        }
    }
    else {
        self.hentaiResults = [NSMutableDictionary dictionary];
    }
    self.hentaiIndex = 0;
    self.failCount = 0;
    self.isRemovedHUD = NO;
    self.realDisplayCount = 0;
    self.shareLock = [NSLock new];
}

#pragma mark - components

//換算直向的高度
- (CGSize)imagePortraitHeight:(CGSize)landscapeSize {
    CGFloat oldWidth = landscapeSize.width;
    CGFloat scaleFactor = [UIScreen mainScreen].bounds.size.width / oldWidth;
    CGFloat newHeight = landscapeSize.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
}

//計算目前到底可以顯示到哪一個 index
- (NSInteger)availableCount {
    NSInteger returnIndex = -1;
    for (NSInteger i = self.realDisplayCount; i < [self.hentaiImageURLs count]; i++) {
        NSString *eachImageString = self.hentaiImageURLs[i];
        if (self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]]) {
            returnIndex = i;
        }
        else {
            break;
        }
    }
    return returnIndex + 1;
}

- (void)createNewOperation:(NSString *)urlString {
    HentaiDownloadImageOperation *newOperation = [HentaiDownloadImageOperation new];
    newOperation.downloadURLString = urlString;
    newOperation.isCacheOperation = YES;
    newOperation.hentaiKey = self.hentaiKey;
    newOperation.delegate = self;
    [self.hentaiQueue addOperation:newOperation];
}

#pragma mark - download methods

//將要下載的圖片加到 queue 裡面
- (void)preloadImages:(NSArray *)images {
    for (NSString *eachImageString in images) {
        [self createNewOperation:eachImageString];
    }
}

//等待圖片下載完成
- (void)waitingOnDownloadFinish {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        [self.hentaiQueue waitUntilAllOperationsAreFinished];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkEndOfFile];
        });
    });
}

//檢查是不是還有圖片需要下載
- (void)checkEndOfFile {
    if ([self.hentaiImageURLs count] < [self.maxHentaiCount integerValue]) {
        self.hentaiIndex++;
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            if (status && [images count]) {
                [self.hentaiImageURLs addObjectsFromArray:images];
                [self preloadImages:images];
                [self waitingOnDownloadFinish];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:nil cancelButtonTitle:@"確定"];
            }
        }];
    }
    else {
        FMStream *saveFolder = [[FilesManager documentFolder] fcd:@"Hentai"];
        [self.hentaiFilesManager moveToPath:[saveFolder.currentPath stringByAppendingPathComponent:self.hentaiKey]];
        NSDictionary *saveInfo = @{ @"hentaiKey":self.hentaiKey, @"images":self.hentaiImageURLs, @"hentaiResult":self.hentaiResults, @"hentaiInfo":self.hentaiInfo };
        LWPSafe(
                [HentaiSaveLibraryArray insertObject:saveInfo atIndex:0];
                LWPForceWrite();
        )
        self.downloadKey = [HentaiSaveLibraryArray indexOfObject:saveInfo];
        [self setupForAlreadyDownloadKey:self.downloadKey];
        [DaiInboxHUD hide];
    }
}

//設定下載好的相關資料
- (void)setupForAlreadyDownloadKey:(NSUInteger)downloadKey {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    [self.hentaiImageURLs setArray:HentaiSaveLibraryArray[downloadKey][@"images"]];
    [self.hentaiResults setDictionary:HentaiSaveLibraryArray[downloadKey][@"hentaiResult"]];
    self.realDisplayCount = [self.hentaiImageURLs count];
    self.hentaiFilesManager = [[[FilesManager documentFolder] fcd:@"Hentai"] fcd:self.hentaiKey];
    [self.hentaiTableView reloadData];
}

//找尋是不是有下載過
- (NSUInteger)foundDownloadKey {
    for (NSDictionary *eachInfo in HentaiSaveLibraryArray) {
        if ([eachInfo[@"hentaiKey"] isEqualToString:self.hentaiKey]) {
            return [HentaiSaveLibraryArray indexOfObject:eachInfo];
        }
    }
    return NSNotFound;
}

#pragma mark - share methods

//分享到 g+
- (void)shareToGPlus {
    id <GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:[self sharedMessage]];
    NSString *sharedImageName = self.hentaiImageURLs[self.sharedIndexPath.row];
    [shareBuilder attachImage:[UIImage imageWithData:[self.hentaiFilesManager read:[sharedImageName hentai_lastTwoPathComponent]]]];
    [shareBuilder open];
}

//預設的文字內容
- (NSString *)sharedMessage {
    NSMutableString *sharedMessage = [NSMutableString string];
    [sharedMessage appendFormat:@"作品名稱 : %@\n", self.hentaiInfo[@"title"]];
    [sharedMessage appendFormat:@"作品連結 : %@\n\n\n\n\n", self.hentaiInfo[@"url"]];
    [sharedMessage appendString:@"send from my hentai app"];
    return sharedMessage;
}

#pragma mark - HentaiPhotoCellDelegate

- (void)needToShareAtIndexPath:(NSIndexPath *)indexPath {
    
    //防止 alert 多次跳出
    if ([self.shareLock tryLock]) {
        self.sharedIndexPath = indexPath;
        if ([[GPPSignIn sharedInstance] authentication]) {
            [self shareToGPlus];
            [self.shareLock unlock];
        }
        else {
            @weakify(self);
            [UIAlertView hentai_alertViewWithTitle:@"G+尚未聯結" message:@"請到設定頁面做聯結先喔!" cancelButtonTitle:@"好~ O3O" otherButtonTitles:nil onClickIndex:nil onCancel:^{
                @strongify(self);
                [self.shareLock unlock];
            }];
        }
    }
}

#pragma mark - HentaiDownloadImageOperationDelegate

- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess {
    if (isSuccess) {
        self.hentaiResults[[urlString hentai_lastTwoPathComponent]] = @(height);
        NSInteger availableCount = [self availableCount];
        if (availableCount > self.realDisplayCount) {
            if (availableCount >= 1 && !self.isRemovedHUD) {
                self.isRemovedHUD = YES;
                [DaiInboxHUD hide];
            }
            self.realDisplayCount = availableCount;
            [self.hentaiTableView reloadData];
        }
    }
    else {
        NSNumber *retryCount = self.retryMap[urlString];
        if (retryCount) {
            retryCount = @([retryCount integerValue] + 1);
        }
        else {
            retryCount = @(1);
        }
        self.retryMap[urlString] = retryCount;
        
        if ([retryCount integerValue] <= 3) {
            [self createNewOperation:urlString];
        }
        else {
            self.failCount++;
            self.maxHentaiCount = [NSString stringWithFormat:@"%ld", [self.maxHentaiCount integerValue] - 1];
            [self.hentaiImageURLs removeObject:urlString];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.realDisplayCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 當前頁數 / ( 可到頁數 / 已下載頁數 / 總共頁數 )
    self.title = [NSString stringWithFormat:@"%ld/(%ld/%ld/%@)", indexPath.row + 1, self.realDisplayCount, [self.hentaiResults count], self.maxHentaiCount];
    
    //無限滾
    if (indexPath.row >= [self.hentaiImageURLs count] - 20 && ([self.hentaiImageURLs count] + self.failCount) == (self.hentaiIndex + 1) * 40 && [self.hentaiImageURLs count] < [self.maxHentaiCount integerValue]) {
        self.hentaiIndex++;
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            if (status && [images count]) {
                [self.hentaiImageURLs addObjectsFromArray:images];
                [self preloadImages:images];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:nil cancelButtonTitle:@"確定"];
            }
        }];
    }
    
    static NSString *cellIdentifier = @"HentaiPhotoCell";
    HentaiPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    NSString *eachImageString = self.hentaiImageURLs[indexPath.row];
    if (self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]]) {
        NSIndexPath *copyIndexPath = [indexPath copy];
        
        //讀取不卡線程
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            @strongify(self);
            UIImage *image = [UIImage imageWithData:[self.hentaiFilesManager read:[eachImageString hentai_lastTwoPathComponent]]];
            
            if ([[tableView indexPathForCell:cell] compare:copyIndexPath] == NSOrderedSame) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.hentaiImageView.image = image;
                });
            }
        });
    }
    else {
        cell.hentaiImageView.image = nil;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *eachImageString = self.hentaiImageURLs[indexPath.row];
    if (self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]]) {
        //如果畫面是直向的時候, 長度要重新算
        if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
            CGSize newSize = [self imagePortraitHeight:CGSizeMake([UIScreen mainScreen].bounds.size.height, [self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]] floatValue])];
            return newSize.height;
        }
        else {
            return [self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]] floatValue];
        }
    }
    else {
        return 0;
    }
}

#pragma mark - Configuring the View’s Layout Behavior

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    
    self.downloadKey = [self foundDownloadKey];
    
    //如果本機有存檔案就用本機的
    if (self.downloadKey != NSNotFound) {
        [self setupForAlreadyDownloadKey:self.downloadKey];
    }
    //否則則從網路上取得
    else {
        self.hentaiFilesManager = [[[FilesManager cacheFolder] fcd:@"Hentai"] fcd:self.hentaiKey];
        [DaiInboxHUD show];
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            if (status && [images count]) {
                [self.hentaiImageURLs addObjectsFromArray:images];
                [self preloadImages:images];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:nil cancelButtonTitle:@"確定"];
                [DaiInboxHUD hide];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.isRemovedHUD) {
        [DaiInboxHUD hide];
    }
    
    //結束時把 queue 清掉, 並且記錄目前已下載的東西有哪些
    [self.hentaiQueue cancelAllOperations];
    
    LWPSafe(
            if (self.downloadKey != NSNotFound) {
                [HentaiCacheLibraryDictionary removeObjectForKey:self.hentaiKey];
            }
            else {
                HentaiCacheLibraryDictionary[self.hentaiKey] = self.hentaiResults;
            }
            LWPForceWrite();
    )
}

@end
