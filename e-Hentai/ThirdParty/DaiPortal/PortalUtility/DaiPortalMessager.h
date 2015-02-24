//
//  DaiPortalMessager.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DaiPortal.h"

@interface DaiPortalMessager : NSObject

//註冊一個傳送門
+ (void)sign:(DaiPortal *)newPortal;

//註銷一個傳送門
+ (void)resign:(DaiPortal *)portal;

//對某一個名字廣播
+ (void)broadcastToIdentifier:(NSString *)identifier objects:(NSArray *)objects fromSource:(id)source;

//註銷和某個物件有關聯的所有傳送門
+ (void)destory:(id)dependObject;

@end
