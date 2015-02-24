//
//  DownloadedViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadedViewController.h"

typedef enum {
    DisplayDownloadedTypeSearch,
    DisplayDownloadedTypeGroupAll,
    DisplayDownloadedTypeUnGroup,
    DisplayDownloadedTypeSpecificGroup
} DisplayDownloadedType;

@interface DownloadedViewController ()

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSDictionary *currentInfo;
@property (nonatomic, assign) BOOL onceFlag;
@property (nonatomic, strong) NSMutableDictionary *textViewCacheMapping;
@property (nonatomic, readonly) NSUInteger hentaiSaveLibraryCount;

@end

@implementation DownloadedViewController

@dynamic hentaiSaveLibraryCount;

#pragma mark - dynamic

//根據 type 的不同, count 也會不一樣
- (NSUInteger)hentaiSaveLibraryCount {
    switch ([self currentType]) {
        case DisplayDownloadedTypeSearch:
            return [HentaiSaveLibrary countBySearchInfo:self.searchInfo];
            break;
        case DisplayDownloadedTypeGroupAll:
            return [HentaiSaveLibrary count];
            break;
        case DisplayDownloadedTypeSpecificGroup:
            return [HentaiSaveLibrary countByGroup:self.group];
            break;
        case DisplayDownloadedTypeUnGroup:
            return [HentaiSaveLibrary countByGroup:@""];
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.hentaiSaveLibraryCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = self.hentaiSaveLibraryCount - 1 - indexPath.section;
    
    static NSString *identifier = @"MainTableViewCell";
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *hentaiInfo = [self saveInfoAtIndex:inverseIndex][@"hentaiInfo"];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSUInteger inverseIndex = self.hentaiSaveLibraryCount - 1 - section;
    
    NSString *sectinoText = [self saveInfoAtIndex:inverseIndex][@"hentaiInfo"][@"title"];
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
    NSUInteger inverseIndex = self.hentaiSaveLibraryCount - 1 - section;
    
    NSString *sectinoText = [self saveInfoAtIndex:inverseIndex][@"hentaiInfo"][@"title"];
    return self.textViewCacheMapping[sectinoText];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = self.hentaiSaveLibraryCount - 1 - indexPath.section;
    
    self.currentInfo = [self saveInfoAtIndex:inverseIndex];
    NSDictionary *hentaiInfo = self.currentInfo[@"hentaiInfo"];
    
    if ([[HentaiSettingManager temporarySettings][@"useNewBrowser"] boolValue]) {
        NSArray *hentaiImages = self.currentInfo[@"images"];
        
        self.photos = [NSMutableArray array];
        NSString *filePath = [[[[FilesManager documentFolder] fcd:@"Hentai"] fcd:[hentaiInfo hentai_hentaiKey]] currentPath];
        for (NSString *eachURL in hentaiImages) {
            [self.photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:[eachURL hentai_lastTwoPathComponent]]]]];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        browser.displayNavArrows = NO;
        browser.displaySelectionButtons = NO;
        browser.zoomPhotosToFill = NO;
        browser.alwaysShowControls = NO;
        browser.enableGrid = NO;
        browser.startOnGrid = NO;
        
        [self.navigationController pushViewController:browser animated:YES];
    }
    else {
        PhotoViewController *photoViewController = [PhotoViewController new];
        photoViewController.hentaiInfo = hentaiInfo;
        photoViewController.originGroup = self.currentInfo[@"group"];
        [self.delegate needToPushViewController:photoViewController];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.photos count];
}

- (id <MWPhoto> )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return self.photos[index];
    }
    return nil;
}

- (void)helpToDelete {
    @weakify(self);
    [UIAlertView hentai_alertViewWithTitle:@"警告~ O3O" message:@"確定要刪除這部作品嗎?" cancelButtonTitle:@"我按錯了~ Q3Q" otherButtonTitles:@[@"對~ O3O 不好看~"] onClickIndex:^(NSInteger clickIndex) {
        @strongify(self);
        if (self) {
            [self.navigationController popViewControllerAnimated:YES];
            NSDictionary *hentaiInfo = self.currentInfo[@"hentaiInfo"];
            NSString *hentaiKey = [hentaiInfo hentai_hentaiKey];
            
            [[[FilesManager documentFolder] fcd:@"Hentai"] rd:hentaiKey];
            [HentaiSaveLibrary removeSaveInfoAtHentaiKey:hentaiKey];
        }
    } onCancel:^{
    }];
}

- (void)helpToChangeGroup:(UIViewController *)viewController {
    @weakify(self);
    [GroupManager presentFromViewController:viewController originGroup:self.currentInfo[@"group"] completion:^(NSString *selectedGroup) {
        @strongify(self);
        if (self && selectedGroup) {
            [HentaiSaveLibrary changeToGroup:selectedGroup atHentaiKey:self.currentInfo[@"hentaiKey"]];
        }
    }];
}

#pragma mark - private

#pragma mark * override methods from MainViewController

- (void)setupInitValues {
    switch ([self currentType]) {
        case DisplayDownloadedTypeSearch:
            self.title = @"搜尋結果";
            break;
        case DisplayDownloadedTypeGroupAll:
            self.title = @"全部";
            break;
        case DisplayDownloadedTypeSpecificGroup:
            self.title = self.group;
            break;
        case DisplayDownloadedTypeUnGroup:
            self.title = @"未分類";
            break;
    }
    self.onceFlag = NO;
    self.textViewCacheMapping = [NSMutableDictionary dictionary];
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *changeGroupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(changeGroupAction)];
    self.navigationItem.rightBarButtonItem = changeGroupButton;
}

- (void)setupRefreshControlOnTableView {
}

- (void)setupRecvNotifications {
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[self portal:PortalHentaiDownloadSuccess] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        [self.listTableView reloadData];
    }];
}

- (void)allowNavigationBarGesture {
}

#pragma mark * misc

//目前究竟該顯示哪種資料
- (DisplayDownloadedType)currentType {
    if (self.searchInfo) {
        return DisplayDownloadedTypeSearch;
    }
    else {
        if (self.group) {
            if ([self.group isEqualToString:@""]) {
                return DisplayDownloadedTypeGroupAll;
            }
            else {
                return DisplayDownloadedTypeSpecificGroup;
            }
        }
        else {
            return DisplayDownloadedTypeUnGroup;
        }
    }
}

//將目前全部的作品一次轉換到某一個 group
- (void)changeGroupAction {
    @weakify(self);
    [GroupManager presentFromViewController:self completion:^(NSString *selectedGroup) {
        @strongify(self);
        [SVProgressHUD show];
        if (self && selectedGroup) {
            NSMutableArray *hentaiKeys = [NSMutableArray array];
            for (int i=0; i<self.hentaiSaveLibraryCount; i++) {
                NSDictionary *saveInfo = [self saveInfoAtIndex:i];
                [hentaiKeys addObject:[saveInfo[@"hentaiInfo"] hentai_hentaiKey]];
            }
            
            for (NSString *eachHentaiKey in hentaiKeys) {
                [HentaiSaveLibrary changeToGroup:selectedGroup atHentaiKey:eachHentaiKey];
            }
            self.title = selectedGroup;
            self.group = selectedGroup;
            self.searchInfo = nil;
            [self.listTableView reloadData];
        }
        [SVProgressHUD dismiss];
    }];
}

//按照 type 不同, 取得的 saveinfo 也不一樣
- (NSDictionary *)saveInfoAtIndex:(NSUInteger)index {
    switch ([self currentType]) {
        case DisplayDownloadedTypeSearch:
            return [HentaiSaveLibrary saveInfoAtIndex:index bySearchInfo:self.searchInfo];
            break;
        case DisplayDownloadedTypeGroupAll:
            return [HentaiSaveLibrary saveInfoAtIndex:index];
            break;
        case DisplayDownloadedTypeSpecificGroup:
            return [HentaiSaveLibrary saveInfoAtIndex:index byGroup:self.group];
            break;
        case DisplayDownloadedTypeUnGroup:
            return [HentaiSaveLibrary saveInfoAtIndex:index byGroup:@""];
            break;
    }
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hentaiSaveLibraryCount) {
        [self.listTableView reloadData];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
