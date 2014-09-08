//
//  LightWeightPlist.h
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LWPArray(fmt) [LightWeightPlist lwpArray:fmt]
#define LWPArrayR(fmt) [LightWeightPlist lwpArrayFromResource:fmt]
#define LWPDictionary(fmt) [LightWeightPlist lwpDictionary:fmt]
#define LWPDictionaryR(fmt) [LightWeightPlist lwpArrayFromResource:fmt]
#define LWPDelete(fmt) [LightWeightPlist lwpDelete:fmt]
#define LWPForceWrite() [LightWeightPlist lwpForceWrite]

@interface LightWeightPlist : NSObject

#pragma mark - Common

+ (void)lwpDelete:(NSString *)key;
+ (void)lwpForceWrite;

#pragma mark - Array

+ (NSMutableArray *)lwpArray:(NSString *)key;
+ (NSMutableArray *)lwpArrayFromResource:(NSString *)key;

#pragma mark - Dictionary

+ (NSMutableDictionary *)lwpDictionary:(NSString *)key;
+ (NSMutableDictionary *)lwpDictionaryFromResource:(NSString *)key;

@end
