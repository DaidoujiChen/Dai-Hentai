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

@interface MainViewController ()

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSLock *rollLock;
@property (nonatomic, readonly) NSString *filterString;
@property (nonatomic, assign) BOOL onceFlag;
@property (nonatomic, strong) NSMutableDictionary *textViewCacheMapping;

@end

@implementation MainViewController

@dynamic filterString;

#pragma mark - dynamic

- (NSString *)filterString {
    return [self filterDependOnURL:@"http://g.e-hentai.org/?page=%lu"];
}

#pragma mark - SearchFilterViewControllerDelegate

- (void)onSearchFilterDone {
    self.title = HentaiPrefer[@"searchText"];
    [self reloadDatas];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //無限滾
    if (indexPath.section >= [self.listArray count] - 15 && [self.rollLock tryLock]) {
        self.listIndex++;
        
        @weakify(self);
        [self loadList: ^(BOOL successed, NSArray *listArray) {
            @strongify(self);
            if (successed) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self.listArray addObjectsFromArray:listArray];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.listTableView reloadData];
                    });
                });
            }
            else {
                self.listIndex--;
            }
            [self.rollLock unlock];
        }];
    }
    static NSString *identifier = @"MainTableViewCell";
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *hentaiInfo = self.listArray[indexPath.section];
    
    //設定 ipad / iphone 共通資訊
    NSURL *imageURL = [NSURL URLWithString:hentaiInfo[@"thumb"]];
    [cell.thumbImageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            [cell.thumbImageView hentai_pathShadow];
            [cell.backgroundImageView hentai_blurWithImage:image];
        }
    }];
    
    //設定 ipad 獨有需要的資訊
    if (isIPad) {
        cell.categoryLabel.text = [NSString stringWithFormat:@"分類 : %@", hentaiInfo[@"category"]];
        cell.ratingLabel.text = [NSString stringWithFormat:@"評價 : %@", hentaiInfo[@"rating"]];
        cell.fileCountLabel.text = [NSString stringWithFormat:@"檔案數量 : %@", hentaiInfo[@"filecount"]];
        cell.fileSizeLabel.text = [NSString stringWithFormat:@"檔案線上容量 : %@", hentaiInfo[@"filesize"]];
        cell.postedLabel.text = [NSString stringWithFormat:@"上傳時間 : %@", hentaiInfo[@"posted"]];
        cell.uploaderLabel.text = [NSString stringWithFormat:@"上傳者 : %@", hentaiInfo[@"uploader"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectinoText = self.listArray[section][@"title"];
    UITextView *titleTextView = self.textViewCacheMapping[sectinoText];
    if (!titleTextView) {
        titleTextView = [UITextView new];
        titleTextView.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0f];
        titleTextView.text = sectinoText;
        titleTextView.clipsToBounds = NO;
        titleTextView.userInteractionEnabled = NO;
        titleTextView.textColor = [UIColor blackColor];
        [titleTextView hentai_pathShadow];
        self.textViewCacheMapping[sectinoText] = titleTextView;
    }
    CGSize textViewSize =  [titleTextView sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), MAXFLOAT)];
    return textViewSize.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectinoText = self.listArray[section][@"title"];
    return self.textViewCacheMapping[sectinoText];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *hentaiInfo = self.listArray[indexPath.section];
    NSUInteger indexInHentaiSaveLibrary = [HentaiSaveLibrary indexOfHentaiKey:[hentaiInfo hentai_hentaiKey]];
    BOOL isExist = (indexInHentaiSaveLibrary == NSNotFound)?NO:YES;
    
    if (isExist) {
        PhotoViewController *photoViewController = [PhotoViewController new];
        photoViewController.hentaiInfo = [HentaiSaveLibrary saveInfoAtIndex:indexInHentaiSaveLibrary][@"hentaiInfo"];
        [self.delegate needToPushViewController:photoViewController];
    }
    else {
        @weakify(self);
        NSString *alertTitle;
        NSString *alertMessage;
        if (isIPad) {
            alertTitle = @"選擇要做的事情~ O3O";
            alertMessage = nil;
        }
        else {
            alertTitle = hentaiInfo[@"category"];
            alertMessage = [self alertMessage:hentaiInfo];
        }
        [UIAlertView hentai_alertViewWithTitle:alertTitle message:alertMessage cancelButtonTitle:@"都不要~ O3O" otherButtonTitles:@[@"下載", @"直接看"] onClickIndex:^(NSInteger clickIndex) {
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

//製作 filter string
- (NSString *)filterDependOnURL:(NSString *)urlString {
    NSMutableString *filterURLString = [NSMutableString stringWithFormat:urlString, (unsigned long)self.listIndex];
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

//重新讀取資料
- (void)reloadDatas {
    
    //清除 sdwebimage 的圖片暫存
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
                    [self.listTableView reloadData];
                    [self.listTableView scrollRectToVisible:CGRectZero animated:YES];
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
    [HentaiParser requestListAtFilterUrl:self.filterString forExHentai:NO completion: ^(HentaiParserStatus status, NSArray *listArray) {
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
    HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:searchFilter];
    hentaiNavigation.autoRotate = NO;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    [self presentViewController:hentaiNavigation animated:YES completion:nil];
}

#pragma mark viewdidload 中用到的初始方法

- (void)setupInitValues {
    
    //相關變數
    self.title = HentaiPrefer[@"searchText"];
    self.listIndex = 0;
    self.listArray = [NSMutableArray array];
    self.rollLock = [NSLock new];
    self.onceFlag = YES;
    self.textViewCacheMapping = [NSMutableDictionary dictionary];
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(presentSearchFilter)];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(openSlider)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setupListTableView {
    
    //讓左右兩邊有 10 的 gap
    CGRect listTableViewRect = self.view.bounds;
    listTableViewRect.size.width -= 20;
    listTableViewRect.origin.x += 10;
    
    self.listTableView = [[UITableView alloc] initWithFrame:listTableViewRect style:UITableViewStyleGrouped];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.backgroundColor = [UIColor clearColor];
    self.listTableView.showsVerticalScrollIndicator = NO;
    [self.listTableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:@"MainTableViewCell"];
    [self.view addSubview:self.listTableView];
}

- (void)setupRefreshControlOnTableView {
    //下拉更新
    self.refreshControl = [UIRefreshControl new];
    [self.listTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(reloadDatas) forControlEvents:UIControlEventValueChanged];
}

- (void)setupRecvNotifications {
    
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[self portal:HentaiDownloadSuccessNotification] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        if (self && [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController == nil) {
            [UIAlertView hentai_alertViewWithTitle:@"下載完成!" message:alertViewMessage cancelButtonTitle:@"好~ O3O"];
        }
    }];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupItemsOnNavigation];
    [self setupListTableView];
    [self setupRefreshControlOnTableView];
    [self setupRecvNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.onceFlag) {
        @weakify(self);
        [self loadList: ^(BOOL successed, NSArray *listArray) {
            @strongify(self);
            if (successed) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self.listArray addObjectsFromArray:listArray];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.listTableView reloadData];
                    });
                });
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
            }
            self.onceFlag = NO;
        }];
    }
}

@end
