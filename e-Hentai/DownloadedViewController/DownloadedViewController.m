//
//  DownloadedViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadedViewController.h"

@interface DownloadedViewController ()

@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation DownloadedViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [HentaiSaveLibraryArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
	NSURL *imageURL = [NSURL URLWithString:HentaiSaveLibraryArray[indexPath.row][@"hentaiInfo"][@"thumb"]];
	[cell.cellImageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *hentaiInfo = HentaiSaveLibraryArray[indexPath.row][@"hentaiInfo"];
	HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
	hentaiNavigation.autorotate = YES;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
	PhotoViewController *photoViewController = [PhotoViewController new];
	photoViewController.hentaiInfo = hentaiInfo;
	[hentaiNavigation pushViewController:photoViewController animated:YES];
}

#pragma mark - recv notification

- (void)hentaiDownloadSuccess:(NSNotification *)notification {
	[self.listCollectionView reloadData];
}

#pragma mark - ibaction

//override 這個 method 避免可以一直 push
- (IBAction)pushToDownloadedAction:(id)sender {
}

#pragma mark - life cycle

//這邊我故意沒有放 [super viewDidLoad], 不然會跑到很多 mainviewcontroller 的東西
- (void)viewDidLoad {
	self.title = @"已經下載的漫畫";
	[self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCell"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.listCollectionView reloadData];
}

@end
