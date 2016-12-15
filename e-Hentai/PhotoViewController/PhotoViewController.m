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
@property (nonatomic, assign) BOOL isRemovedHUD;
@property (nonatomic, strong) NSOperationQueue *hentaiQueue;
@property (nonatomic, strong) FMStream *hentaiFilesManager;

@property (nonatomic, strong) NSString *hentaiURLString;
@property (nonatomic, strong) NSString *maxHentaiCount;

@property (nonatomic, assign) BOOL isHighResolution;

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
    fakeViewController.view = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    fakeViewController.BackBlock = ^() {
        [hentaiNavigation popViewControllerAnimated:YES];
    };
    [self presentViewController:fakeViewController animated:NO completion: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [fakeViewController onPresentCompletion];
        });
    }];
}

- (void)saveAction {
    @weakify(self);
    [UIAlertView hentai_alertViewWithTitle:@"你想要儲存這本漫畫嗎?" message:nil cancelButtonTitle:@"不要好了...Q3Q" otherButtonTitles:@[@"加入下載管理員~ O3O"] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
        [GroupManager presentFromViewController:self completion: ^(NSString *selectedGroup) {
            @strongify(self);
            if (self && selectedGroup) {
                [HentaiDownloadCenter addBook:self.hentaiInfo toGroup:selectedGroup];
                [self backAction];
            }
        }];
    } onCancel:nil];
}

- (void)deleteAction {
    @weakify(self);
    [UIAlertView hentai_alertViewWithTitle:@"警告~ O3O" message:@"確定要刪除這部作品嗎?" cancelButtonTitle:@"我按錯了~ Q3Q" otherButtonTitles:@[@"對~ O3O 不好看~"] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
        @strongify(self);
        if (self) {
            [[[FilesManager documentFolder] fcd:@"Hentai"] rd:self.hentaiKey];
            [HentaiSaveLibrary removeSaveInfoAtHentaiKey:self.hentaiKey];
            [self backAction];
        }
    } onCancel:nil];
}

- (void)changeGroupAction {
    @weakify(self);
    [GroupManager presentFromViewController:self originGroup:self.originGroup completion: ^(NSString *selectedGroup) {
        @strongify(self);
        if (self && selectedGroup) {
            [HentaiSaveLibrary changeToGroup:selectedGroup atHentaiKey:self.hentaiKey];
        }
    }];
}

#pragma mark - setup inits

- (void)setupInitValues {
    self.title = @"Loading...";
    
    //navigation bar 上的兩個 button
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //註冊 cell
    [self.hentaiTableView registerClass:[HentaiPhotoCell class] forCellReuseIdentifier:@"HentaiPhotoCell"];
    
    self.hentaiURLString = self.hentaiInfo[@"url"];
    self.maxHentaiCount = self.hentaiInfo[@"filecount"];
    
    //OperationQueue 限制數量為 从设置读入
    self.hentaiQueue = [NSOperationQueue new];
    [self.hentaiQueue setMaxConcurrentOperationCount:[[Setting shared].loadingPicsAtSameTime integerValue]];
    
    //相關參數初始化
    self.hentaiImageURLs = [NSMutableArray array];
    self.retryMap = [NSMutableDictionary dictionary];
    if ([HentaiCacheLibrary cacheInfoForKey:self.hentaiKey]) {
        //這邊要多一個判斷, 當 cache 資料夾下如果找不到東西了, 表示圖片已經被清掉
        if ([[[FilesManager cacheFolder] fcd:@"Hentai"] cd:self.hentaiKey]) {
            self.hentaiResults = [NSMutableDictionary dictionaryWithDictionary:[HentaiCacheLibrary cacheInfoForKey:self.hentaiKey]];
        }
        else {
            self.hentaiResults = [NSMutableDictionary dictionary];
            [HentaiCacheLibrary removeCacheInfoForKey:self.hentaiKey];
        }
    }
    else {
        self.hentaiResults = [NSMutableDictionary dictionary];
    }
    self.hentaiIndex = 0;
    self.failCount = 0;
    self.isRemovedHUD = NO;
    self.realDisplayCount = 0;
    self.isHighResolution = [[Setting shared].highResolution boolValue];
}

#pragma mark - components

//換算直向的高度
- (CGSize)imagePortraitHeight:(CGSize)landscapeSize {
    CGFloat oldWidth = landscapeSize.width;
    CGFloat scaleFactor = realScreenWidth / oldWidth;
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
    [self createNewOperation:urlString isHighPrior:NO];
}

- (void)createNewOperation:(NSString *)urlString isHighPrior:(BOOL)isHighPrior {
    HentaiDownloadImageOperation *newOperation = [HentaiDownloadImageOperation new];
    newOperation.downloadURLString = urlString;
    newOperation.isCacheOperation = YES;
    newOperation.hentaiKey = self.hentaiKey;
    newOperation.delegate = self;
    newOperation.isHighResolution = self.isHighResolution;
    newOperation.queuePriority = isHighPrior ?  NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
    [self.hentaiQueue addOperation:newOperation];
}

#pragma mark - download methods

//將要下載的圖片加到 queue 裡面
- (void)preloadImages:(NSArray *)images {
    if ([images count]) {
        for (NSString *eachImageString in images) {
            [self createNewOperation:eachImageString];
        }
    }
    else {
        [UIAlertView hentai_alertViewWithTitle:@"抓圖的過程中出問題囉~ >x<" message:@"請見諒~ >x<" cancelButtonTitle:@"好吧~ >x<"];
        [SVProgressHUD dismiss];
    }
}

//設定下載好的相關資料
- (void)setupForDownloadedSaveInfo:(NSDictionary *)saveInfo {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction)];
    UIBarButtonItem *changeGroupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(changeGroupAction)];
    self.navigationItem.rightBarButtonItems = @[deleteButton, changeGroupButton];
    [self.hentaiImageURLs setArray:saveInfo[@"images"]];
    [self.hentaiResults setDictionary:saveInfo[@"hentaiResult"]];
    self.realDisplayCount = [self.hentaiImageURLs count];
    self.hentaiFilesManager = [[[FilesManager documentFolder] fcd:@"Hentai"] fcd:self.hentaiKey];
    [self.hentaiTableView reloadData];
}

#pragma mark - HentaiDownloadImageOperationDelegate

- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess {
    if (isSuccess) {
        self.hentaiResults[[urlString hentai_lastTwoPathComponent]] = @(height);
        NSInteger availableCount = [self availableCount];
        if (availableCount > self.realDisplayCount) {
            if (availableCount >= 1 && !self.isRemovedHUD) {
                self.isRemovedHUD = YES;
                [SVProgressHUD dismiss];
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
        
        if ([retryCount integerValue] <= [[Setting shared].retryTimes integerValue]) {
            [self createNewOperation:urlString isHighPrior:YES];
        }
        else {
            self.failCount++;
            self.maxHentaiCount = [NSString stringWithFormat:@"%td", [self.maxHentaiCount integerValue] - 1];
            
            NSUInteger removeIndex = NSNotFound;
            for (NSString *eachURLString in self.hentaiImageURLs) {
                if ([eachURLString isEqualToString:urlString]) {
                    removeIndex = [self.hentaiImageURLs indexOfObject:eachURLString];
                    break;
                }
            }
            
            if (removeIndex != NSNotFound) {
                [self.hentaiImageURLs removeObjectAtIndex:removeIndex];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.realDisplayCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 當前頁數 / ( 可到頁數 / 已下載頁數 / 總共頁數 )
    self.title = [NSString stringWithFormat:@"%td/(%td/%td/%@)", indexPath.row + 1, self.realDisplayCount, [self.hentaiResults count], self.maxHentaiCount];
    
    //無限滾
    if (indexPath.row >= [self.hentaiImageURLs count] - 20 && ([self.hentaiImageURLs count] + self.failCount) == (self.hentaiIndex + 1) * 40 && [self.hentaiImageURLs count] < [self.maxHentaiCount integerValue]) {
        self.hentaiIndex++;
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            
            if (self) {
                switch (status) {
                    case HentaiParserStatusSuccess:
                        [self.hentaiImageURLs addObjectsFromArray:images];
                        [self preloadImages:images];
                        break;
                    case HentaiParserStatusNetworkFail:
                        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:@"網路失敗" cancelButtonTitle:@"確定"];
                        break;
                    case HentaiParserStatusParseFail:
                        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:@"解析失敗" cancelButtonTitle:@"確定"];
                        break;
                }
            }
        }];
    }
    
    static NSString *cellIdentifier = @"HentaiPhotoCell";
    HentaiPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
            CGSize newSize = [self imagePortraitHeight:CGSizeMake(realScreenHeight, [self.hentaiResults[[eachImageString hentai_lastTwoPathComponent]] floatValue])];
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

- (id)init {
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    
    NSDictionary *saveInfo = [HentaiSaveLibrary saveInfoAtHentaiKey:self.hentaiKey];
    
    //如果本機有存檔案就用本機的
    if (saveInfo) {
        [self setupForDownloadedSaveInfo:saveInfo];
    }
    //否則則從網路上取得
    else {
        self.hentaiFilesManager = [[[FilesManager cacheFolder] fcd:@"Hentai"] fcd:self.hentaiKey];
        [SVProgressHUD show];
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            
            if (self) {
                switch (status) {
                    case HentaiParserStatusSuccess:
                        [self.hentaiImageURLs addObjectsFromArray:images];
                        [self preloadImages:images];
                        break;
                    case HentaiParserStatusNetworkFail:
                        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:@"網路失敗" cancelButtonTitle:@"確定"];
                        [SVProgressHUD dismiss];
                        break;
                    case HentaiParserStatusParseFail:
                        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗囉" message:@"解析失敗" cancelButtonTitle:@"確定"];
                        [SVProgressHUD dismiss];
                        break;
                }
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.isRemovedHUD) {
        [SVProgressHUD dismiss];
    }
    
    //結束時把 queue 清掉, 並且記錄目前已下載的東西有哪些
    [self.hentaiQueue cancelAllOperations];
    
    if ([HentaiSaveLibrary saveInfoAtHentaiKey:self.hentaiKey]) {
        [HentaiCacheLibrary removeCacheInfoForKey:self.hentaiKey];
    }
    else {
        [HentaiCacheLibrary addCacheInfo:self.hentaiResults forKey:self.hentaiKey];
    }
}

@end
