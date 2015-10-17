//
//  AppDelegate.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/8/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+SupportKit.h"
#import "DaiSurvivor.h"
#import "SliderViewController.h"
#import "HentaiInfo.h"

@implementation AppDelegate

#pragma mark - app life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	[DaiSurvivor shared].isNeedAliveInBackground = ^BOOL(void) {
		return [HentaiDownloadCenter countInCenter];
	};
    
    [DaiSurvivor shared].totalAliveTime = ^(NSTimeInterval aliveTime) {
        [UIAlertView hentai_alertViewWithTitle:@">3< 歐耶!" message:[NSString stringWithFormat:@"我在背景活了 %d 秒捏", (int)aliveTime] cancelButtonTitle:@"好~ O3O"];
    };

    //設定 hud 的基本參數
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    //supportkit
    [self setupSupportKit];
    
    //Flurry
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"BY5JD5CPV7N4C3R2CP2J"];
    
    [self downloadLostRecovery];
    
    //display
    application.statusBarOrientation = UIDeviceOrientationPortrait;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:[SliderViewController new]];
    hentaiNavigation.autoRotate = NO;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    self.window.rootViewController = hentaiNavigation;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)downloadLostRecovery {
    NSArray *losts = [[[FilesManager documentFolder] fcd:@"Downloading"] listFolders];
    if (losts.count) {
        [UIAlertView hentai_alertViewWithTitle:@"O3O\" 發現有些東西沒有下載完成 " message:@"請問是否將他們加回下載列表?" cancelButtonTitle:@"不用" otherButtonTitles:@[@"要~ O3O"] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
            for (NSString *folder in losts) {
                HentaiInfo *lostHentaiInfo = [HentaiInfo new];
                [lostHentaiInfo importPath:[[[DaiStoragePath document] fcd:@"Downloading"] fcd:folder]];
                [HentaiDownloadCenter addBook:lostHentaiInfo.storeContents toGroup:lostHentaiInfo.group];
            }
        } onCancel: ^(UIAlertView *alertView) {
            for (NSString *folder in losts) {
                [[[FilesManager documentFolder] fcd:@"Downloading"] rd:folder];
            }
        }];
    }
}

@end
