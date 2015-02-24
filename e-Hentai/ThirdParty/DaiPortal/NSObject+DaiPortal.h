//
//  NSObject+DaiPortal.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/25.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DaiPortal+Reciver.h"
#import "DaiPortal+Sender.h"

@interface NSObject (DaiPortal)

//開端, 所有的傳送門都需要先有一個識別的名字
- (DaiPortal *)portal:(NSString *)identifier;

// - 是掛在 instance 身上, + 則是掛在 class 身上
+ (DaiPortal *)portal:(NSString *)identifier;

@end
