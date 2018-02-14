//
//  AppDelegate.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/7.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "AppDelegate.h"
#import "DBUserPreference.h"
#import "AuthHelper.h"
#import "EXTScope.h"

@interface AppDelegate ()

@property (nonatomic, weak) UIViewController *blackViewController;
@property (nonatomic, assign) NSNumber *allowOnce;

@end

@implementation AppDelegate

#pragma mark - Private Instance Method

- (void)addBlackScreen:(void (^)(void))completion {
    if (!self.blackViewController) {
        UIViewController *blackViewController = [UIViewController new];
        blackViewController.view.backgroundColor = [UIColor blackColor];
        [self.window.rootViewController presentViewController:blackViewController animated:NO completion:completion];
        self.blackViewController = blackViewController;
        return;
    }
    
    if (completion) {
        completion();
    }
}

- (void)removeBlackScreen:(void (^)(void))completion {
    if (self.blackViewController) {
        [self.blackViewController dismissViewControllerAnimated:NO completion:completion];
        return;
    }
    
    if (completion) {
        completion();
    }
}

#pragma mark - App Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil]];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // 一次解開設定, 可以解開或是踢出去
    if (self.allowOnce) {
        BOOL allowOnce = self.allowOnce.boolValue;
        if (allowOnce) {
            self.allowOnce = nil;
            [AuthHelper refreshAuth];
            return;
        }
        
        // crash
        exit(0);
    }
    
    // 如果不需要上鎖, 避免有黑膜在上面, 安全性的移除他, 或是避免閃一個黑屏
    if (![DBUserPreference info].isLockThisApp.boolValue) {
        [self removeBlackScreen:nil];
        return;
    }
    
    // 需要上鎖的話, 就用黑畫面鎖起來
    @weakify(self);
    [self addBlackScreen: ^{
        [AuthHelper checkFor:@"使用這個 App 需要先解鎖呦" completion:^(BOOL pass) {
            @strongify(self);
            self.allowOnce = @(pass);
            [self removeBlackScreen:nil];
        }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // 如果需要上鎖, 在進入背景前將顏色塗黑, 避免重新開啟時會看到露出的畫面
    if ([DBUserPreference info].isLockThisApp.boolValue) {
        [self addBlackScreen:nil];
    }
}

@end
