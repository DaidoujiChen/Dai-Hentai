//
//  SliderViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SliderViewController.h"

@interface SliderViewController ()

@property (nonatomic, weak) UIView *weakMaskView;

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

#pragma mark - VideoViewControllerDelegate

//幫助秀電影畫面, 這邊有驗證過, 雖然產生了一個新的 window, 但是他會隨著電影畫面被 dismiss 時消失,
//不會有累積越來越多的情形, 這樣做的理由是說, 用另外一個 window 來放電影, 他的橫向直向皆不影響原來的任何功能
- (void)needToPresentMovieViewController:(MPMoviePlayerViewController *)controller {
    UIWindow *newWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *rootViewController = [UIViewController new];
    newWindow.rootViewController = rootViewController;
    [newWindow makeKeyAndVisible];
    [rootViewController presentMoviePlayerViewControllerAnimated:controller];
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

#pragma mark - IIViewDeckControllerDelegate

//當 slider 被打開時, 需要幫右邊的畫面上一層膜, 這層膜的用意在於當點擊到他的時候, 他會幫你把畫面縮回去,
//已經有膜的話則不重複加
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (!self.weakMaskView) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.centerController.view.bounds];
        maskView.userInteractionEnabled = YES;
        maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recovery:)];
        [maskView addGestureRecognizer:tapGesture];
        [self.centerController.view addSubview:maskView];
        self.weakMaskView = maskView;
    }
}

//當 slider 被關閉時, 如果膜還在則把他拿掉
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (self.weakMaskView) {
        [self.weakMaskView removeFromSuperview];
    }
}

#pragma mark - private

//點到膜的行為, 把 slider 關起來, 然後把膜移除
- (void)recovery:(UITapGestureRecognizer *)tapGesture {
    [self closeLeftView];
    [tapGesture.view removeFromSuperview];
}

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
    self.delegate = self;
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
