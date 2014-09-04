//
//  PhotoViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

//目前漫畫是在網路上的哪一頁
@property (nonatomic, assign) NSUInteger hentaiIndex;

//漫畫每一頁的 url 網址
@property (nonatomic, strong) NSMutableArray *hentaiImageURLs;

//已經下載好的漫畫結果
//結構 key 是檔案名稱 (url 網址的 lastPathComponent) NSString
//value 是該檔案的高度 NSNumber
@property (nonatomic, strong) NSMutableDictionary *hentaiResults;

//從漫畫主頁的網址拆出來一組獨一無二的 key, 用作儲存識別
@property (nonatomic, readonly) NSString *hentaiKey;

//真正可以看到哪一頁 (下載的檔案需要有連續, 數字才會增長)
@property (nonatomic, assign) NSInteger realDisplayCount;
@property (nonatomic, assign) BOOL isRemovedHUD;
@property (nonatomic, strong) NSOperationQueue *hentaiQueue;

- (void)backAction;
- (void)preloadImages:(NSArray *)images;
- (NSInteger)availableCount;
- (void)setupInitValues;

@end

@implementation PhotoViewController


#pragma mark - getter

@dynamic hentaiKey;

- (NSString *)hentaiKey
{
	NSArray *splitStrings = [self.hentaiURLString componentsSeparatedByString:@"/"];
	NSUInteger splitCount = [splitStrings count];
	return [NSString stringWithFormat:@"%@-%@", splitStrings[splitCount - 3], splitStrings[splitCount - 2]];
}


#pragma mark - ibaction

- (IBAction)singleTapScreenAction:(id)sender
{
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
	[self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark - private

- (void)backAction
{
	HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;

    //FakeViewController 是一個硬把畫面轉直的媒介
	FakeViewController *fakeViewController = [FakeViewController new];
	fakeViewController.BackBlock = ^() {
		[hentaiNavigation popViewControllerAnimated:YES];
	};
	[self presentViewController:fakeViewController animated:NO completion: ^{
	    [fakeViewController onPresentCompletion];
	}];
}

- (void)preloadImages:(NSArray *)images
{
    //將要下載的圖片加到 queue 裡面
	for (NSString *eachImageString in images) {
		HentaiDownloadOperation *newOperation = [HentaiDownloadOperation new];
		newOperation.downloadURLString = eachImageString;
		newOperation.hentaiKey = self.hentaiKey;
		newOperation.delegate = self;
		[self.hentaiQueue addOperation:newOperation];
	}
}

//計算目前到底可以顯示到哪一個 index
- (NSInteger)availableCount
{
	NSInteger returnIndex = -1;
	for (NSInteger i = self.realDisplayCount; i < [self.hentaiImageURLs count]; i++) {
		NSString *eachImageString = self.hentaiImageURLs[i];
		if (self.hentaiResults[[eachImageString lastPathComponent]]) {
			returnIndex = i;
		} else {
			break;
		}
	}
	return returnIndex + 1;
}

- (void)setupInitValues
{
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
	self.title = @"Loading...";
	self.navigationItem.leftBarButtonItem = newBackButton;

	[self.hentaiTableView registerClass:[HentaiPhotoCell class] forCellReuseIdentifier:@"HentaiPhotoCell"];

	self.hentaiImageURLs = [NSMutableArray array];
	if (HentaiLibraryDictionary[self.hentaiKey]) {
		self.hentaiResults = HentaiLibraryDictionary[self.hentaiKey];
	} else {
		self.hentaiResults = [NSMutableDictionary dictionary];
	}
	self.hentaiQueue = [NSOperationQueue new];
	[self.hentaiQueue setMaxConcurrentOperationCount:5];
	self.hentaiIndex = 0;
	self.isRemovedHUD = NO;
	self.realDisplayCount = 0;
}


#pragma mark - HentaiDownloadOperationDelegate

- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess
{
	if (isSuccess) {
		self.hentaiResults[[urlString lastPathComponent]] = @(height);
		NSInteger availableCount = [self availableCount];
		if (availableCount > self.realDisplayCount) {
			if (availableCount >= 1 && !self.isRemovedHUD) {
				self.isRemovedHUD = YES;
				[SVProgressHUD dismiss];
			}
			self.realDisplayCount = availableCount;
			[self.hentaiTableView reloadData];
		}
	} else {
		HentaiDownloadOperation *newOperation = [HentaiDownloadOperation new];
		newOperation.downloadURLString = urlString;
		newOperation.hentaiKey = self.hentaiKey;
		newOperation.delegate = self;
		[self.hentaiQueue addOperation:newOperation];
	}
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.realDisplayCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 當前頁數 / ( 可到頁數 / 已下載頁數 / 總共頁數 )
	self.title = [NSString stringWithFormat:@"%d/(%d/%d/%@)", indexPath.row + 1, self.realDisplayCount, [self.hentaiResults count], self.maxHentaiCount];
    
	static NSString *cellIdentifier = @"HentaiPhotoCell";
	HentaiPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	NSString *eachImageString = self.hentaiImageURLs[indexPath.row];
	if (self.hentaiResults[[eachImageString lastPathComponent]]) {
		cell.hentaiImageView.image = [UIImage imageWithData:[[[FilesManager documentFolder] fcd:self.hentaiKey] read:[eachImageString lastPathComponent]]];
	} else {
		cell.hentaiImageView.image = nil;
	}
	return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *eachImageString = self.hentaiImageURLs[indexPath.row];
	if (self.hentaiResults[[eachImageString lastPathComponent]]) {
		return [self.hentaiResults[[eachImageString lastPathComponent]] floatValue];
	} else {
		return 0;
	}
}


#pragma mark - Configuring the View’s Layout Behavior

- (BOOL)prefersStatusBarHidden
{
	return self.navigationController.navigationBarHidden;
}


#pragma mark - life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupInitValues];

    //從網路上取得 image 列表
	[SVProgressHUD show];
	__weak PhotoViewController *weakSelf = self;
	[HentaiParser requestImagesAtURL:self.hentaiURLString atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
	    if (status && weakSelf) {
	        __strong PhotoViewController *strongSelf = weakSelf;
	        [strongSelf.hentaiImageURLs addObjectsFromArray:images];
	        [strongSelf preloadImages:images];
		}
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    //結束時把 queue 清掉, 並且記錄目前已下載的東西有哪些
	[self.hentaiQueue cancelAllOperations];
	HentaiLibraryDictionary[self.hentaiKey] = self.hentaiResults;
	LWPForceWrite();
}

@end
