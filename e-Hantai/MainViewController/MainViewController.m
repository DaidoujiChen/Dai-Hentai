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
        [HantaiParser requestListAtIndex:self.listIndex completion: ^(HantaiParserStatus status, NSArray *listArray) {
            [self.listArray addObjectsFromArray:listArray];
            [self.listTableView reloadData];
        }];
    }
	static NSString *cellIdentifier = @"HantaiCell";
	HantaiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	NSDictionary *hantaiInfo = self.listArray[indexPath.row];
	cell.typeLabel.text = hantaiInfo[@"type"];
	cell.publishedLabel.text = hantaiInfo[@"published"];
	cell.titleLabel.text = hantaiInfo[@"title"];
	cell.uploaderLabel.text = hantaiInfo[@"uploader"];
	return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *hantaiInfo = self.listArray[indexPath.row];
	[SVProgressHUD show];
	[HantaiParser requestImagesAtURL:[NSURL URLWithString:hantaiInfo[@"url"]] completion: ^(HantaiParserStatus status, NSArray *images) {
	    NSLog(@"%@", images);
        
        HantaiNavigationController *hantaiNavigation = (HantaiNavigationController*)self.navigationController;
        hantaiNavigation.hantaiMask = UIInterfaceOrientationMaskLandscape;
        
        FakeViewController *fakeViewController = [FakeViewController new];
        fakeViewController.BackBlock = ^() {
            [hantaiNavigation pushViewController:[PhotoViewController new] animated:YES];
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
	[self.listTableView registerClass:[HantaiCell class] forCellReuseIdentifier:@"HantaiCell"];
    
	[HantaiParser requestListAtIndex:self.listIndex completion: ^(HantaiParserStatus status, NSArray *listArray) {
	    [self.listArray addObjectsFromArray:listArray];
	    [self.listTableView reloadData];
	}];
}


@end
