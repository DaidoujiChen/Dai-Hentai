//
//  LightWeightPlist+HandleCache.m
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/20.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist+HandleCache.h"

#import <objc/message.h>

#import "LightWeightPlist+AccessObject.h"
#import "LightWeightPlist+FilePath.h"

#define lwpBridge(fmt) ((__bridge const void *)fmt)

@implementation LightWeightPlist (HandleCache)

#pragma mark - NSCacheDelegate

+ (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if ([lwpPointerMapping objectForKey:[self objectAddressString:obj]]) {
        id associatedObject = objc_getAssociatedObject(self, lwpBridge(obj));
        NSString *filename = [lwpPointerMapping objectForKey:[self objectAddressString:obj]];
        NSString *path = lwpDocumentFile(filename);
        [associatedObject performSelector:@selector(writeToFile:atomically:) withObject:path withObject:@YES];
        [lwpPointerMapping removeObjectForKey:[self objectAddressString:obj]];
    }
}

#pragma mark - class method

+ (BOOL)setObjectToCache:(id)object withKey:(NSString *)key
{
	if ([self isDictionary:object] || [self isArray:object]) {
		NSObject *emptyObject = [NSObject new];
		[lwpCache setObject:emptyObject forKey:key];
		objc_setAssociatedObject(self, lwpBridge([lwpCache objectForKey:key]), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[lwpPointerMapping setObject:key forKey:[self objectAddressString:[lwpCache objectForKey:key]]];
		return YES;
	} else {
		return NO;
	}
}

+ (id)objectFromCache:(NSString *)key
{
	return objc_getAssociatedObject(self, lwpBridge([lwpCache objectForKey:key]));
}

+ (void)removeObjectFromCache:(NSString *)key
{
	if ([lwpCache objectForKey:key]) {
		[lwpPointerMapping removeObjectForKey:[self objectAddressString:[lwpCache objectForKey:key]]];
		[lwpCache removeObjectForKey:key];
	}
}

#pragma mark - private

+ (NSString *)objectAddressString:(NSObject *)object
{
	return [NSString stringWithFormat:@"%p", object];
}

+ (BOOL)isArray:(id)object
{
	return (0 == strcmp(object_getClassName(object), "__NSArrayM") || 0 == strcmp(object_getClassName(object), "__NSCFArray"));
}

+ (BOOL)isDictionary:(id)object
{
	return (0 == strcmp(object_getClassName(object), "__NSDictionaryM") || 0 == strcmp(object_getClassName(object), "__NSCFDictionary"));
}

@end
