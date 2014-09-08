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
    UIRefreshControl* refreshControl;
    BOOL enableH_Image;
}

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation MainViewController


#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //無限滾
    if (indexPath.row >= [self.listArray count]-15 && [self.listArray count] == (self.listIndex+1)*25) {
        self.listIndex++;
        [HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
            [self.listArray addObjectsFromArray:listArray];
            [self.listCollectionView reloadData];
        }];
    }
    
    GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
    [hentaiInfo setValue:[NSNumber numberWithBool:enableH_Image] forKey:imageMode];//設定是否顯示H圖
    [cell setGalleryDict:hentaiInfo];
    return cell;
}


#pragma mark - UICollectionViewDelegate


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
	[SVProgressHUD show];
	[HentaiParser requestImagesAtURL:hentaiInfo[@"url"] atIndex:0 completion: ^(HentaiParserStatus status, NSArray *images) {
	    NSLog(@"%@", images);
        
        HentaiNavigationController *hentaiNavigation = (HentaiNavigationController*)self.navigationController;
        hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskLandscape;
        
        FakeViewController *fakeViewController = [FakeViewController new];
        fakeViewController.BackBlock = ^() {
            [hentaiNavigation pushViewController:[PhotoViewController new] animated:YES];
        };
        [self presentViewController:fakeViewController animated:NO completion:^{
            [fakeViewController onPresentCompletion];
        }];
        
	    [SVProgressHUD dismiss];
	}];
}




#pragma mark - life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.listIndex = 0;
    self.listArray = [NSMutableArray array];
    [self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCell"];
    [HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listCollectionView reloadData];
	}];
    
    //add refresh control
    refreshControl = [[UIRefreshControl alloc]init];
    [self.listCollectionView addSubview:refreshControl];
    [refreshControl addTarget:self
                       action:@selector(reloadDatas)
             forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem* changeModeItem = [[UIBarButtonItem alloc] initWithTitle:@"H圖" style:UIBarButtonItemStylePlain target:self action:@selector(changeImageMode:)];
    self.navigationItem.rightBarButtonItem = changeModeItem;
    
    enableH_Image = NO;
}


#pragma mark - actions

- (void)reloadDatas
{
    [HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
        [self.listArray removeAllObjects];
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listCollectionView reloadData];
        
        [refreshControl endRefreshing];
	}];
}

- (void)changeImageMode:(UIBarButtonItem*)sender
{
    enableH_Image = !enableH_Image;
    
    if(enableH_Image)
    {
        sender.title = @"貓圖";
    }
    else
    {
        sender.title = @"H圖";
    }
    
    [self.listCollectionView reloadData];
}


@end
