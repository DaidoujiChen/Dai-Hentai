//
//  MainViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;

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
	[cell setGalleryDict:hentaiInfo];
	return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
	NSDictionary *hentaiInfo = self.listArray[indexPath.row];
	HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
	hentaiNavigation.autorotate = YES;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;

	PhotoViewController *photoViewController = [PhotoViewController new];
	photoViewController.hentaiURLString = hentaiInfo[@"url"];
	photoViewController.maxHentaiCount = hentaiInfo[@"filecount"];
	[hentaiNavigation pushViewController:photoViewController animated:YES];
}

#pragma mark - life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.listIndex = 0;
	self.listArray = [NSMutableArray array];

	[self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil]
              forCellWithReuseIdentifier:@"GalleryCell"];

	[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listCollectionView reloadData];
	}];
}

@end
