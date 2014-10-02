//
//  MainViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"
#import "HentaiSearchFilter.h"
#import "HentaiFilterView.h"

//avoid import cycle
#import "DownloadedViewController.h"

#define statusBarWithNavigationHeight 64.0f

@interface MainViewController ()

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, readonly) NSString *filterString;

@end

@implementation MainViewController

@dynamic filterString;

#pragma mark - dynamic

- (NSString *)filterString {
	HentaiFilterView *filterView = [self filterViewInSearchBar:self.searchBar];
	NSString *baseUrlString = [NSString stringWithFormat:@"http://g.e-hentai.org/?page=%lu", (unsigned long)self.listIndex];
	NSString *filterString = [HentaiSearchFilter searchFilterUrlByKeyword:self.searchBar.text filterArray:[filterView filterResult] baseUrl:baseUrlString];
	return filterString;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.listArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	//無限滾
	if (indexPath.row >= [self.listArray count] - 15 && [self.listArray count] == (self.listIndex + 1) * 25) {
		self.listIndex++;
        
		__weak MainViewController *weakSelf = self;
		[self loadList: ^(BOOL successed, NSArray *listArray) {
		    if (successed) {
		        [weakSelf.listArray addObjectsFromArray:listArray];
		        [weakSelf.listCollectionView reloadData];
			}
		    else {
		        weakSelf.listIndex--;
			}
		}];
	}
	GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
	NSURL *imageURL = [NSURL URLWithString:self.listArray[indexPath.row][@"thumb"]];
	[cell.cellImageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
	cell.cellImageView.alpha = ([self.listArray[indexPath.row][@"rating"] floatValue] / 4.5f);
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
		PhotoViewController *photoViewController = [PhotoViewController new];
		photoViewController.hentaiInfo = hentaiInfo;
		[self.delegate needToPushViewController:photoViewController];
	}
	else {
		__weak MainViewController *weakSelf = self;
		[UIAlertView hentai_alertViewWithTitle:hentaiInfo[@"category"] message:[self alertMessage:hentaiInfo] cancelButtonTitle:@"都不要~ O3O" otherButtonTitles:@[@"下載", @"直接看"] onClickIndex: ^(int clickIndex) {
		    if (clickIndex) {
		        if ([HentaiDownloadCenter isDownloading:hentaiInfo]) {
		            [UIAlertView hentai_alertViewWithTitle:@"這本你正在抓~ O3O" message:nil cancelButtonTitle:@"好~ O3O"];
				}
		        else {
		            PhotoViewController *photoViewController = [PhotoViewController new];
		            photoViewController.hentaiInfo = hentaiInfo;
		            [weakSelf.delegate needToPushViewController:photoViewController];
				}
			}
		    else {
		        [HentaiDownloadCenter addBook:hentaiInfo];
			}
		} onCancel:nil];
	}
}

#pragma mark -  UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
    
	if ([searchBar.text isEqualToString:@""]) {
		[[self filterViewInSearchBar:searchBar] selectAll];
	}
	[self alwaysEnableReturnKeyInSearchBar:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self reloadDatas];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
}

#pragma mark - private

//讓 search bar 在沒有輸入字的情況下也可以按下搜尋按鈕
- (void)alwaysEnableReturnKeyInSearchBar:(UISearchBar *)searchBar {
	UITextField *searchField = nil;
	for (UIView *subView in searchBar.subviews) {
		for (UIView *childSubview in subView.subviews) {
			if ([childSubview isKindOfClass:[UITextField class]]) {
				searchField = (UITextField *)childSubview;
				break;
			}
		}
	}
    
	if (searchField) {
		searchField.enablesReturnKeyAutomatically = NO;
	}
}

//重新讀取資料
- (void)reloadDatas {
	//清除GalleryCell的圖片暫存
	[[SDImageCache sharedImageCache] clearMemory];
	[[SDImageCache sharedImageCache] clearDisk];
	self.listIndex = 0;
    
	__weak MainViewController *weakSelf = self;
	[self loadList: ^(BOOL successed, NSArray *listArray) {
	    if (successed) {
	        [weakSelf.listArray removeAllObjects];
	        [weakSelf.listArray addObjectsFromArray:listArray];
	        [weakSelf.listCollectionView reloadData];
	        [weakSelf.listCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
	        [weakSelf.refreshControl endRefreshing];
		}
	    else {
	        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
		}
	}];
}

//從 searchbar 裡面抽出 HentaiFilterView
- (HentaiFilterView *)filterViewInSearchBar:(UISearchBar *)searchBar {
	return (HentaiFilterView *)searchBar.inputAccessoryView;
}

//把 request 的判斷都放到這個 method 裡面來
- (void)loadList:(void (^)(BOOL successed, NSArray *listArray))completion {
	__weak MainViewController *weakSelf = self;
	[HentaiParser requestListAtFilterUrl:self.filterString completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    if (status && weakSelf && [listArray count]) {
	        completion(YES, listArray);
		}
	    else {
	        completion(NO, nil);
		}
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

#pragma mark viewdidload 中用到的初始方法

- (void)setupInitValues {
	//相關變數
	self.listIndex = 0;
	self.listArray = [NSMutableArray array];
    
	//調整畫面的大小
	CGRect screenSize = [UIScreen mainScreen].bounds;
	self.view.frame = screenSize;
	self.listCollectionView.frame = screenSize;
}

- (void)setupItemsOnNavigation {
	//搜尋列
	self.searchBar = [UISearchBar new];
	self.searchBar.inputAccessoryView = [[HentaiFilterView alloc] initWithFrame:CGRectZero];
	self.searchBar.delegate = self;
	self.navigationItem.titleView = self.searchBar;
}

- (void)setupListCollectionViewBehavior {
	[self.listCollectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:@"GalleryCell"];
	//下拉更新
	self.refreshControl = [UIRefreshControl new];
	[self.listCollectionView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(reloadDatas) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - recv notification

- (void)hentaiDownloadSuccess:(NSNotification *)notification {
	[UIAlertView hentai_alertViewWithTitle:@"下載完成!" message:notification.object cancelButtonTitle:@"好~ O3O"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat deltaHeight = CGRectGetMinY(keyboardFrame) - statusBarWithNavigationHeight;
	HentaiFilterView *filterView = [self filterViewInSearchBar:self.searchBar];
    
	//當變異值的值不為 0, 以及跟目前 filterView height 不同時需要改變
	if (deltaHeight != filterView.frame.size.height && deltaHeight != 0) {
		[self.searchBar resignFirstResponder];
		CGRect filterFrame = filterView.frame;
		filterFrame.size.height += deltaHeight;
		filterView.frame = filterFrame;
		[self.searchBar becomeFirstResponder];
	}
}

#pragma mark - life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupInitValues];
	[self setupItemsOnNavigation];
	[self setupListCollectionViewBehavior];
    
	__weak MainViewController *weakSelf = self;
	[self loadList: ^(BOOL successed, NSArray *listArray) {
	    if (successed) {
	        [weakSelf.listArray addObjectsFromArray:listArray];
	        [weakSelf.listCollectionView reloadData];
		}
	    else {
	        [UIAlertView hentai_alertViewWithTitle:@"讀取失敗" message:@"試試用下拉重新載入"];
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hentaiDownloadSuccess:) name:HentaiDownloadSuccessNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HentaiDownloadSuccessNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end
