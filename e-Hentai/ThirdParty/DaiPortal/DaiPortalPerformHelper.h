//
//  DaiPortalPerformHelper.h
//  DaiPortal
//
//  Created by 啟倫 陳 on 2014/11/18.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

//概念來自 ReactiveCocoa 裡面的 RACBlockTrampoline

#import <Foundation/Foundation.h>

@interface DaiPortalPerformHelper : NSObject

+ (id)idPerformObjects:(NSArray *)objects usingBlock:(id)block;
+ (void)voidPerformObjects:(NSArray *)objects usingBlock:(id)block;

@end
