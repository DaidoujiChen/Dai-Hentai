//
//  AppDelegate.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/7.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil]];
    return YES;
}

@end
