//
//  AppDelegate.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/8/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate+SupportKit.h"

@implementation AppDelegate

#pragma mark - app life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //設定 hud 的基本參數
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    //supportkit
    [self setupSupportKit];
    
    //Flurry
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"BY5JD5CPV7N4C3R2CP2J"];
    
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

@end
