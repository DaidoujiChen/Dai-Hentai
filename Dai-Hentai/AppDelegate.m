//
//  AppDelegate.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/7.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DBUserPreference.h"
#import "AuthHelper.h"
#import "EXTScope.h"

@interface AppDelegate ()

@property (nonatomic, assign) NSNumber *allowOnce;

@end

@implementation AppDelegate

#pragma mark - App Life Cycle

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 如果是一個有上鎖的設定, 就讓 window 在最一開始的時候就是隱藏的
    if ([DBUserPreference info].isLockThisApp.boolValue) {
        self.window.hidden = YES;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil]];
    [Fabric with:@[[Crashlytics class]]];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // 一次解開設定, 可以解開或是踢出去
    if (self.allowOnce) {
        BOOL allowOnce = self.allowOnce.boolValue;
        if (allowOnce) {
            self.allowOnce = nil;
            [AuthHelper refreshAuth];
            [self.window makeKeyAndVisible];
            return;
        }
        
        // crash
        self.window.hidden = YES;
        exit(0);
    }
    
    // 如果不需要上鎖, window 則是 visible 的
    if (![DBUserPreference info].isLockThisApp.boolValue) {
        [self.window makeKeyAndVisible];
        return;
    }
    
    // 需要上鎖的話, window 則是 hidden 的
    self.window.hidden = YES;
    @weakify(self);
    [AuthHelper checkFor:@"使用這個 App 需要先解鎖呦" completion:^(BOOL pass) {
        @strongify(self);
        self.allowOnce = @(pass);
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // 如果需要上鎖, 在進入背景前將 window hidden, 避免重新開啟時會看到露出的畫面
    if ([DBUserPreference info].isLockThisApp.boolValue) {
        self.window.hidden = YES;
    }
}

@end
