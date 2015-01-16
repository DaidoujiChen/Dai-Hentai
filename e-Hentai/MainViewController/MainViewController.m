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

#pragma mark - SearchFilterV2ViewControllerDelegate

- (void)onSearchFilterDone {
    self.listIndex = 0;
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
    NSString *sectionText = self.listArray[section][@"title"];
    if (!sectionText) {
        //因為從 report 看起來這邊會有危險, 但是不知道為什麼, 所以用這個奇怪的做法
        sectionText = [NSString stringWithFormat:@"好險~好險~差點就閃退了(%d)", section];
    }
    UITextView *titleTextView = self.textViewCacheMapping[sectionText];
    if (!titleTextView) {
        titleTextView = [UITextView new];
        titleTextView.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0f];
        titleTextView.text = sectionText;
        titleTextView.clipsToBounds = NO;
        titleTextView.userInteractionEnabled = NO;
        titleTextView.textColor = [UIColor blackColor];
        [titleTextView hentai_pathShadow];
        self.textViewCacheMapping[sectionText] = titleTextView;
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
                    [JDStatusBarNotification showWithStatus:@"這本你正在抓~ O3O" dismissAfter:2.0f styleName:JDStatusBarStyleWarning];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"此單位是跳跳忍者~ O3O"]) {
        if (buttonIndex) {
            UITextField *indexTextField = [alertView textFieldAtIndex:0];
            self.listIndex = [indexTextField.text intValue] - 1;
            [self reloadDatas];
        }
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if ([alertView.title isEqualToString:@"此單位是跳跳忍者~ O3O"]) {
        UITextField *indexTextField = [alertView textFieldAtIndex:0];
        indexTextField.text = [NSString stringWithFormat:@"%d", self.listIndex+1];
    }
}

#pragma mark - private

//製作 filter string
- (NSString *)filterDependOnURL:(NSString *)urlString {
    NSMutableString *filterURLString = [NSMutableString stringWithFormat:urlString, (unsigned long)self.listIndex];
    NSArray *filters = [HentaiSettingManager temporaryHentaiPrefer][@"filtersFlag"];
    
    //建立過濾 url
    for (NSInteger i = 0; i < [[HentaiSettingManager staticFilters] count]; i++) {
        NSNumber *eachFlag = filters[i];
        if ([eachFlag boolValue]) {
            [filterURLString appendFormat:@"&%@", [HentaiSettingManager staticFilters][i][@"url"]];
        }
    }
    
    //去除掉空白換行字符後, 如果長度不為 0, 則表示有字
    NSCharacterSet *emptyCharacter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[[HentaiSettingManager temporaryHentaiPrefer][@"searchText"] componentsSeparatedByCharactersInSet:emptyCharacter] componentsJoinedByString:@""].length) {
        [filterURLString appendFormat:@"&f_search=%@", [HentaiSettingManager temporaryHentaiPrefer][@"searchText"]];
    }
    [filterURLString appendString:@"&f_apply=Apply+Filter"];
    
    //評分過濾
    NSNumber *ratingIndex = [HentaiSettingManager temporaryHentaiPrefer][@"rating"];
    if (ratingIndex && [ratingIndex intValue] != 0) {
        [filterURLString appendFormat:@"&advsearch=1&f_sname=on&f_stags=on&f_sr=on&f_srdd=%d", [ratingIndex intValue] + 1];
    }
    return [filterURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//重新讀取資料
- (void)reloadDatas {
    
    [self.textViewCacheMapping removeAllObjects];
    [self.listArray removeAllObjects];
    [self.listTableView reloadData];
    
    @weakify(self);
    [self loadList: ^(BOOL successed, NSArray *listArray) {
        @strongify(self);
        
        //多加一個判斷, 如果使用者還在這頁的話, 才做這些事
        if (self) {
            if (successed) {
                [self.listArray addObjectsFromArray:listArray];
                [self.listTableView reloadData];
                [self.refreshControl endRefreshing];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
            }
        }
    }];
}

//把 request 的判斷都放到這個 method 裡面來
- (void)loadList:(void (^)(BOOL successed, NSArray *listArray))completion {
    [SVProgressHUD show];
    [HentaiParser requestListAtFilterUrl:self.filterString forExHentai:NO completion: ^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            completion(YES, listArray);
        }
        else {
            completion(NO, nil);
        }
        [SVProgressHUD dismiss];
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
    SearchFilterV2ViewController *searchFilter = [SearchFilterV2ViewController new];
    searchFilter.delegate = self;
    HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:searchFilter];
    hentaiNavigation.autoRotate = NO;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    [self presentViewController:hentaiNavigation animated:YES completion:nil];
}

- (void)nextPageAction {
    self.listIndex++;
    [self reloadDatas];
}

- (void)prevPageAction {
    if (self.listIndex != 0) {
        self.listIndex--;
    }
    [self reloadDatas];
}

#pragma mark viewdidload 中用到的初始方法

- (void)setupInitValues {
    
    //相關變數
    @weakify(self)
    [RACObserve(self, listIndex) subscribeNext:^(NSNumber *index) {
        @strongify(self);
        
        self.title = [NSString stringWithFormat:@"%@(%d)", [HentaiSettingManager temporaryHentaiPrefer][@"searchText"], self.listIndex + 1];
    }];
    self.listIndex = 0;
    self.listArray = [NSMutableArray array];
    self.onceFlag = YES;
    self.textViewCacheMapping = [NSMutableDictionary dictionary];
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(presentSearchFilter)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextPageAction)];
    self.navigationItem.rightBarButtonItems = @[filterButton, nextButton];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(sliderControl)];
    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(prevPageAction)];
    self.navigationItem.leftBarButtonItems = @[menuButton, prevButton];
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

#pragma mark * method to override

- (void)tapNavigationAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"此單位是跳跳忍者~ O3O" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"跳~ O3O", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupItemsOnNavigation];
    [self setupListTableView];
    [self setupRefreshControlOnTableView];
    [self allowNavigationBarGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.onceFlag) {
        @weakify(self);
        [self loadList: ^(BOOL successed, NSArray *listArray) {
            @strongify(self);
            
            //多加一個判斷, 如果使用者還在這頁的話, 才做這些事
            if (self) {
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
            }
        }];
    }
}

@end
