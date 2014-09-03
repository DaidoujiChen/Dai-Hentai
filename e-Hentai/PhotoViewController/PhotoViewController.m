//
//  PhotoViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController


#pragma mark - private

- (void)backAction
{
    HentaiNavigationController *hentaiNavigation = (HentaiNavigationController*)self.navigationController;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    
    FakeViewController *fakeViewController = [FakeViewController new];
    fakeViewController.BackBlock = ^() {
        [hentaiNavigation popViewControllerAnimated:YES];
    };
    [self presentViewController:fakeViewController animated:NO completion:^{
        [fakeViewController onPresentCompletion];
    }];
}

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}


@end
