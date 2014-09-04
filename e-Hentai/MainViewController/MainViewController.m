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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCell *cell = (GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
    [cell setGalleryDict:hentaiInfo];
    return cell;
}


#pragma mark - UICollectionViewDelegate


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *hentaiInfo = self.listArray[indexPath.row];
	[SVProgressHUD show];
	[HentaiParser requestImagesAtURL:[NSURL URLWithString:hentaiInfo[@"url"]] completion: ^(HentaiParserStatus status, NSArray *images) {
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
    
//    [self.listCollectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:@"GalleryCell"];
    
    [self.listCollectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryCell"];
    
	[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listCollectionView reloadData];
	}];
}


@end
