//
//  DaiPortalWarehouse.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DaiPortal.h"

@interface DaiPortalWarehouse : NSObject

//分別處理登記, 註銷, 移除一次性使用傳送門
+ (void)sign:(DaiPortal *)newPortal;
+ (void)resign:(id)dependObject;
+ (void)removeDisposable:(DaiPortal *)disposableObject;

//daiportal 專用的 notification center, 不會跟系統的混在一起
+ (NSNotificationCenter *)daiPortalNotificationCenter;

@end
