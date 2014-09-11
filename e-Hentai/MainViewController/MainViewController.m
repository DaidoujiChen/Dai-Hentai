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
    [hentaiInfo setValue:[NSNumber numberWithBool:enableH_Image] forKey:imageMode];
	[cell setGalleryDict:hentaiInfo];
	return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
    BOOL isExist = NO;
    
    for (NSDictionary *eachSavedInfo in HentaiSaveLibraryArray) {
        if ([eachSavedInfo[@"hentaiInfo"][@"url"] isEqualToString:hentaiInfo[@"url"]]) {
            isExist = YES;
            break;
        }
    }
    
    if (isExist) {
        HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
        hentaiNavigation.autorotate = YES;
        hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
        
        PhotoViewController *photoViewController = [PhotoViewController new];
        photoViewController.hentaiInfo = hentaiInfo;
        [hentaiNavigation pushViewController:photoViewController animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"請問要下載還是直接看" message:@"請搶答~ O3O" delegate:self cancelButtonTitle:@"直接看!" otherButtonTitles:@"下載!", nil];
        alert.tag = indexPath.row;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *hentaiInfo = self.listArray[alertView.tag];
    if (buttonIndex) {
        [HentaiDownloadCenter addBook:hentaiInfo];
    }
    else {
        if ([HentaiDownloadCenter isDownloading:hentaiInfo]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"這本你正在抓~ O3O" message:nil delegate:nil cancelButtonTitle:@"好~ O3O" otherButtonTitles:nil];
            [alert show];
        } else {
            HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
            hentaiNavigation.autorotate = YES;
            hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
            
            PhotoViewController *photoViewController = [PhotoViewController new];
            photoViewController.hentaiInfo = hentaiInfo;
            [hentaiNavigation pushViewController:photoViewController animated:YES];
        }
    }
}

#pragma mark - recv notification

- (void)hentaiDownloadSuccess:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下載完成!" message:notification.object delegate:nil cancelButtonTitle:@"好~ O3O" otherButtonTitles:nil];
    [alert show];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hentaiDownloadSuccess:) name:HentaiDownloadSuccessNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HentaiDownloadSuccessNotification object:nil];
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
