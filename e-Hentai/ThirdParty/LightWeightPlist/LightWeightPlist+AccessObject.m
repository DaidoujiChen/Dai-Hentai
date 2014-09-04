//
//  LightWeightPlist+AccessObject.m
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist+AccessObject.h"

#import <objc/runtime.h>

@implementation LightWeightPlist (AccessObject)

#pragma mark - class method

+ (LightWeightPlistObjects *)objects
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    LightWeightPlistObjects *objects = [LightWeightPlistObjects new];
	    [objects.dataCache setDelegate:(id <NSCacheDelegate>)self];
	    objc_setAssociatedObject(self, _cmd, objects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	});
	return objc_getAssociatedObject(self, _cmd);
}

@end
