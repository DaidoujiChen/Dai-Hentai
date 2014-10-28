//
//  SliderViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SliderViewController.h"

@interface SliderViewController ()

@end

@implementation SliderViewController

#pragma mark - MainViewControllerDelegate

//幫助頁面跳到看漫畫頁面
- (void)needToPushViewController:(UIViewController *)controller {
	HentaiNavigationController *hentaiNavigation = (HentaiNavigationController *)self.navigationController;
	hentaiNavigation.autoRotate = YES;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
	[hentaiNavigation pushViewController:controller animated:YES];
}

#pragma mark - MenuViewControllerDelegate

//切換 controller
- (void)needToChangeViewController:(NSString *)className {
    
    if (className) {
        id newViewController = [NSClassFromString(className) new];
        if ([newViewController respondsToSelector:@selector(setDelegate:)]) {
            [newViewController performSelector:@selector(setDelegate:) withObject:self];
        }
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newViewController];
        self.centerController = navigationController;
    }
    else {
        [SupportKit show];
    }
    [self closeLeftView];
}

#pragma mark - private

#pragma mark viewdidload 中的初始設定

//設定左邊的 viewcontroller
- (void)setupLeftViewController {
    MenuViewController *menuViewController = [MenuViewController new];
    menuViewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
	self.leftController = navigationController;
	self.leftSize = 150.0f;
}

//設定中間的 viewcontroller
- (void)setupCenterViewController {
	MainViewController *mainViewController = [MainViewController new];
	mainViewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	self.centerController = navigationController;
}

#pragma mark - life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.sizeMode = IIViewDeckViewSizeMode;
	self.shadowEnabled = NO;
	[self setupLeftViewController];
	[self setupCenterViewController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationController.navigationBarHidden = NO;
}

@end
