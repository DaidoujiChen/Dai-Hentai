//
//  AppDelegate.m
//  e-Hantai
//
//  Created by 啟倫 陳 on 2014/8/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HantaiNavigationController *hantaiNavigation = [[HantaiNavigationController alloc] initWithRootViewController:[MainViewController new]];
    hantaiNavigation.hantaiMask = UIInterfaceOrientationMaskPortrait;
	self.window.rootViewController = hantaiNavigation;
	[self.window makeKeyAndVisible];
	return YES;
}

@end
