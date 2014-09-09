//
//  LightWeightPlist+SourceFromDisk.h
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/20.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist.h"

@interface LightWeightPlist (SourceFromDisk)

+ (NSMutableArray *)arrayInDocument:(NSString *)key;
+ (NSMutableArray *)arrayInResource:(NSString *)key;
+ (NSMutableDictionary *)dictionaryInDocument:(NSString *)key;
+ (NSMutableDictionary *)dictionaryInResource:(NSString *)key;

@end
