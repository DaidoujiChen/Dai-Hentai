//
//  LightWeightPlist+AccessObject.h
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist.h"

#import "LightWeightPlistObjects.h"

#define lwpCache [LightWeightPlist objects].dataCache
#define lwpPointerMapping [LightWeightPlist objects].pointerMapping

@interface LightWeightPlist (AccessObject)

+ (LightWeightPlistObjects *)objects;

@end
