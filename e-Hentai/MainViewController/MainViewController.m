//
//  MainViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
{
	BOOL enableH_Image;
}

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MainViewController


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.listArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	//無限滾
	if (indexPath.row >= [self.listArray count] - 15 && [self.listArray count] == (self.listIndex + 1) * 25) {
		self.listIndex++;
		[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
		    [self.listArray addObjectsFromArray:listArray];
		    [self.listCollectionView reloadData];
		}];
	}
    
	GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
	NSDictionary *hentaiInfo = self.listArray[indexPath.row];
	[hentaiInfo setValue:[NSNumber numberWithBool:enableH_Image] forKey:imageMode]; //設定是否顯示H圖
	[cell setGalleryDict:hentaiInfo];
	return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *hentaiInfo = self.listArray[indexPath.row];
    
	HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskLandscape;
    
	PhotoViewController *photoViewController = [PhotoViewController new];
	photoViewController.hentaiURLString = hentaiInfo[@"url"];
	photoViewController.maxHentaiCount = hentaiInfo[@"filecount"];
    
	FakeViewController *fakeViewController = [FakeViewController new];
	fakeViewController.BackBlock = ^() {
		[hentaiNavigation pushViewController:photoViewController animated:YES];
	};
	[self presentViewController:fakeViewController animated:NO completion: ^{
	    [fakeViewController onPresentCompletion];
	}];
}

#pragma mark - life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.listIndex = 0;
	self.listArray = [NSMutableArray array];
	[self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCell"];
	[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listCollectionView reloadData];
	}];
    
	//add refresh control
	self.refreshControl = [[UIRefreshControl alloc]init];
	[self.listCollectionView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self
	                        action:@selector(reloadDatas)
	              forControlEvents:UIControlEventValueChanged];
    
	UIBarButtonItem *changeModeItem = [[UIBarButtonItem alloc] initWithTitle:@"H圖" style:UIBarButtonItemStylePlain target:self action:@selector(changeImageMode:)];
	self.navigationItem.rightBarButtonItem = changeModeItem;
    
	enableH_Image = NO;
}

#pragma mark - actions

- (void)reloadDatas {
	self.listIndex = 0;
	__weak MainViewController *weakSelf = self;
	[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    if (status && weakSelf) {
	        [weakSelf.listArray removeAllObjects];
	        [weakSelf.listArray addObjectsFromArray:listArray];
	        [weakSelf.listCollectionView reloadData];
	        [weakSelf.refreshControl endRefreshing];
		}
	    else {
	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"錯誤"
	                                                        message:@"讀取失敗"
	                                                       delegate:nil
	                                              cancelButtonTitle:@""
	                                              otherButtonTitles:nil];
	        [alert show];
		}
	}];
}

- (void)changeImageMode:(UIBarButtonItem *)sender {
	enableH_Image = !enableH_Image;
    
	if (enableH_Image) {
		sender.title = @"貓圖";
	}
	else {
		sender.title = @"H圖";
	}
    
	[self.listCollectionView reloadData];
}

@end
