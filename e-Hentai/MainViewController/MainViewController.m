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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //無限滾
    if (indexPath.row >= [self.listArray count]-15 && [self.listArray count] == (self.listIndex+1)*25) {
        self.listIndex++;
        [HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
            [self.listArray addObjectsFromArray:listArray];
            [self.listTableView reloadData];
        }];
    }
	static NSString *cellIdentifier = @"HentaiCell";
	HentaiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	NSDictionary *hentaiInfo = self.listArray[indexPath.row];
	cell.typeLabel.text = hentaiInfo[@"type"];
	cell.publishedLabel.text = hentaiInfo[@"published"];
	cell.titleLabel.text = hentaiInfo[@"title"];
	cell.uploaderLabel.text = hentaiInfo[@"uploader"];
	return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
            [fakeViewController whenPresentCompletion];
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
	[self.listTableView registerClass:[HentaiCell class] forCellReuseIdentifier:@"HentaiCell"];
    
	[HentaiParser requestListAtIndex:self.listIndex completion: ^(HentaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listTableView reloadData];
	}];
}


@end
