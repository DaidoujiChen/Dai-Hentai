//
//  AppDelegate+SupportKit.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (SupportKit) <SKTConversationDelegate>

@property (nonatomic, copy) void (^monitor)(NSNumber *unreadCount);

- (void)setupSupportKit;

@end
