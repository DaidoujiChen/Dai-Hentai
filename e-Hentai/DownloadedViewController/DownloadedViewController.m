//
//  DownloadedViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadedViewController.h"

@interface DownloadedViewController ()

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
	NSDictionary *hentaiInfo = [HentaiSaveLibrary saveInfoAtIndex:inverseIndex][@"hentaiInfo"];
	PhotoViewController *photoViewController = [PhotoViewController new];
	photoViewController.hentaiInfo = hentaiInfo;
    [self.delegate needToPushViewController:photoViewController];
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
