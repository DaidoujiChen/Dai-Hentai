//
//  DownloadedViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadedViewController.h"

@interface DownloadedViewController ()

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSDictionary *currentInfo;
@property (nonatomic, assign) BOOL onceFlag;
@property (nonatomic, strong) NSMutableDictionary *textViewCacheMapping;

@end

@implementation DownloadedViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [HentaiSaveLibrary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - indexPath.section;
    
    static NSString *identifier = @"MainTableViewCell";
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *hentaiInfo = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex][@"hentaiInfo"];
    
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
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - section;
    
    NSString *sectinoText = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex][@"hentaiInfo"][@"title"];
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
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - section;
    
    NSString *sectinoText = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex][@"hentaiInfo"][@"title"];
    return self.textViewCacheMapping[sectinoText];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - indexPath.section;
    
    self.currentInfo = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex];
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
    [UIAlertView hentai_alertViewWithTitle:@"警告~ O3O" message:@"確定要刪除這部作品嗎?" cancelButtonTitle:@"我按錯了~ Q3Q" otherButtonTitles:@[@"對~ O3O 不好看~"] onClickIndex:^(NSInteger clickIndex) {
        [self.navigationController popViewControllerAnimated:YES];
        NSDictionary *hentaiInfo = self.currentInfo[@"hentaiInfo"];
        NSString *hentaiKey = [hentaiInfo hentai_hentaiKey];
        
        [[[FilesManager documentFolder] fcd:@"Hentai"] rd:hentaiKey];
        [HentaiSaveLibrary removeSaveInfoAtIndex:[HentaiSaveLibrary indexOfHentaiKey:hentaiKey]];
    } onCancel:^{
    }];
}

#pragma mark - private

#pragma mark * override methods from MainViewController

- (void)setupInitValues {
    self.title = @"已經下載的漫畫";
    self.onceFlag = NO;
    self.textViewCacheMapping = [NSMutableDictionary dictionary];
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(sliderControl)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setupRefreshControlOnTableView {
}

- (void)setupRecvNotifications {
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[self portal:HentaiDownloadSuccessNotification] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        [self.listTableView reloadData];
    }];
}

- (void)allowNavigationBarGesture {
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.listTableView reloadData];
}

@end
