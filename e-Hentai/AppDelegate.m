//
//  AppDelegate.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/8/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:[SliderViewController new]];
	hentaiNavigation.autoRotate = NO;
	hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
	self.window.rootViewController = hentaiNavigation;
	[self.window makeKeyAndVisible];
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
