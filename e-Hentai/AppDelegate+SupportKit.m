//
//  AppDelegate+SupportKit.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate+SupportKit.h"

#import <objc/runtime.h>

@implementation AppDelegate (SupportKit)

@dynamic monitor;

#pragma mark - access

- (void)setMonitor:(void (^)(NSNumber *))monitor {
    objc_setAssociatedObject(self, @selector(monitor), monitor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSNumber *))monitor {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - SKTConversationDelegate

- (void)conversation:(SKTConversation *)conversation unreadCountDidChange:(NSUInteger)unreadCount {
    if (self.monitor) {
        self.monitor(@(unreadCount));
    }
}

#pragma mark - instance method

- (void)setupSupportKit {
    //初始化 supportkit
    SKTSettings *settings = [SKTSettings settingsWithAppToken:@"bp5je6b2cqie39idzkx8v9fvm"];
    settings.enableAppWideGesture = NO;
    settings.enableGestureHintOnFirstLaunch = NO;
    [SupportKit initWithSettings:settings];
    
    //掛載監聽未讀訊息
    SKTConversation *conversation = [SupportKit conversation];
    conversation.delegate = self;
}

@end
