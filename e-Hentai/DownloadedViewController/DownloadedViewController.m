//
//  DownloadedViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadedViewController.h"

@interface DownloadedViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSDictionary *currentInfo;

@end

@implementation DownloadedViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [HentaiSaveLibrary count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - indexPath.row;
    GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    NSURL *imageURL = [NSURL URLWithString:[HentaiSaveLibrary saveInfoAtIndex:inverseIndex][@"hentaiInfo"][@"thumb"]];
    [cell.cellImageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger inverseIndex = [HentaiSaveLibrary count] - 1 - indexPath.row;
    self.currentInfo = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex];
    NSDictionary *hentaiInfo = self.currentInfo[@"hentaiInfo"];
    
    if ([HentaiSettings[@"useNewBroswer"] boolValue]) {
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

#pragma mark - recv notification

- (void)setupRecvNotifications {
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[self portal:HentaiDownloadSuccessNotification] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        [self.listCollectionView reloadData];
    }];
}

#pragma mark - life cycle

- (id)init {
    if (isIPad) {
        self = [super initWithNibName:@"IPadMainViewController" bundle:nil];
    }
    else {
        self = [super initWithNibName:@"MainViewController" bundle:nil];
    }
    if (self) {
    }
    return self;
}

//這邊我故意沒有放 [super viewDidLoad], 不然會跑到很多 mainviewcontroller 的東西
- (void)viewDidLoad {
    self.title = @"已經下載的漫畫";
    [self setupRecvNotifications];
    [self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.listCollectionView reloadData];
}

@end
