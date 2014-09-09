//
//  LightWeightPlist.m
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist.h"

#import "LightWeightPlist+AccessObject.h"
#import "LightWeightPlist+HandleCache.h"
#import "LightWeightPlist+SourceFromDisk.h"
#import "LightWeightPlist+FilePath.h"

@implementation LightWeightPlist

#pragma mark - common

+ (void)lwpDelete:(NSString *)key
{
	[[NSFileManager defaultManager] removeItemAtPath:lwpDocumentFile(key) error:NULL];
    [self removeObjectFromCache:key];
}

+ (void)lwpForceWrite
{
	[lwpCache removeAllObjects];
}

#pragma mark - array

+ (NSMutableArray *)lwpArray:(NSString *)key
{
	if (![self objectFromCache:key]) {
        NSMutableArray *returnObject;
		returnObject = [self arrayInDocument:key];
		if (!returnObject) {
			returnObject = [self arrayInResource:key];
			if (!returnObject) {
                returnObject = [NSMutableArray array];
			}
		}
        [self setObjectToCache:returnObject withKey:key];
	}
	return [self objectFromCache:key];
}

+ (NSMutableArray *)lwpArrayFromResource:(NSString *)key
{
	if (![self objectFromCache:key]) {
		NSMutableArray *returnObject;
        returnObject = [self arrayInResource:key];
		if (!returnObject) {
            returnObject = [NSMutableArray array];
		}
        [self setObjectToCache:returnObject withKey:key];
	}
	return [self objectFromCache:key];
}

#pragma mark - dictionary

+ (NSMutableDictionary *)lwpDictionary:(NSString *)key
{
	if (![self objectFromCache:key]) {
		NSMutableDictionary *returnObject;
        returnObject = [self dictionaryInDocument:key];
		if (!returnObject) {
			returnObject = [self dictionaryInResource:key];
			if (!returnObject) {
                returnObject = [NSMutableDictionary dictionary];
			}
		}
        [self setObjectToCache:returnObject withKey:key];
	}
	return [self objectFromCache:key];
}

+ (NSMutableDictionary *)lwpDictionaryFromResource:(NSString *)key
{
	if (![self objectFromCache:key]) {
		NSMutableDictionary *returnObject;
        returnObject = [self dictionaryInResource:key];
		if (!returnObject) {
            returnObject = [NSMutableDictionary dictionary];
		}
        [self setObjectToCache:returnObject withKey:key];
	}
	return [self objectFromCache:key];
}

@end
