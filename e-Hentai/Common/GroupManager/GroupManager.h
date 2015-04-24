//
//  GroupManager.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupManager : NSObject

//開啓分類選擇
+ (void)presentFromViewController:(UIViewController *)viewController completion:(void (^)(NSString *selectedGroup))completion;

//開啓分類選擇, 已有原先分類
+ (void)presentFromViewController:(UIViewController *)viewController originGroup:(NSString *)originGroup completion:(void (^)(NSString *selectedGroup))completion;

@end
