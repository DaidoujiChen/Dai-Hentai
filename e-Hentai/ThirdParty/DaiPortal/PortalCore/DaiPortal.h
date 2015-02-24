//
//  DaiPortal.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DaiPortalPackage.h"

typedef void (^VoidBlock)();
typedef DaiPortalPackage *(^PackageBlock)();

@interface DaiPortal : NSObject

//分別是該傳送門的識別名稱跟所依附的物件
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) id dependObject;

@end
