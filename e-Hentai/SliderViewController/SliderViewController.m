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

#pragma mark - OpenMenuProtocol

//如果右邊的畫面是開著的, 就把他關起來
//反之則開啟左邊分頁
- (void)sliderControl {
    if ([self isSideOpen:IIViewDeckRightSide]) {
        [self closeRightView];
    }
    else {
        [self openLeftView];
    }
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

#pragma mark - Configuring the View Rotation Settings

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - private

//點到膜的行為, 把 slider 關起來, 然後把膜移除
- (void)recovery:(UITapGestureRecognizer *)tapGesture {
    if ([self isSideOpen:IIViewDeckLeftSide]) {
        [self closeLeftView];
    }
    else {
        [self closeRightView];
    }
    [tapGesture.view removeFromSuperview];
}

- (void)setupRecvNotifications {
    
    //接 HentaiDownloadSuccessNotification
    @weakify(self);
    [[self portal:PortalHentaiDownloadSuccess] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        if (self && [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController == nil) {
            [JDStatusBarNotification showWithStatus:@"下載完成!" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
        }
    }];
    
    //接 HentaiDownloadFailNotification
    [[self portal:PortalHentaiDownloadFail] recv: ^(NSString *alertViewMessage) {
        @strongify(self);
        if (self && [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController == nil) {
            [JDStatusBarNotification showWithStatus:@"下載失敗!" dismissAfter:2.0f styleName:JDStatusBarStyleError];
        }
    }];
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

//設定右邊的 viewcontroller
- (void)setupRightViewController {
    DownloadManagerViewController *downloadManagerViewController = [DownloadManagerViewController new];
    downloadManagerViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:downloadManagerViewController];
    self.rightController = navigationController;
    self.rightSize = realScreenWidth;
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
    self.panningMode = IIViewDeckAllViewsPanning;
    self.delegate = self;
	self.shadowEnabled = NO;
    [self setupRecvNotifications];
	[self setupLeftViewController];
    [self setupRightViewController];
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
