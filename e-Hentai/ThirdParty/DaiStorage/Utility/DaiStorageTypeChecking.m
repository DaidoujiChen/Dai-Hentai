//
//  DaiStorageTypeChecking.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/22.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorageTypeChecking.h"

#import "DaiStorage.h"

#define isDaiStorageSubclass(ARG) \
	[ARG respondsToSelector : @selector(isSubclassOfClass:)] ? [ARG isSubclassOfClass : [DaiStorage class]] :[[ARG class] isSubclassOfClass:[DaiStorage class]]

#define isDaiStorageArraySubclass(ARG) \
	[ARG respondsToSelector : @selector(isSubclassOfClass:)] ? [ARG isSubclassOfClass : [DaiStorageArray class]] :[[ARG class] isSubclassOfClass:[DaiStorageArray class]]

@implementation DaiStorageTypeChecking

+ (DaiStorageType)on:(id)anObject {
    NSAssert(anObject, @"判斷的物件不能為 nil");
    
	if (isDaiStorageSubclass(anObject)) {
		return DaiStorageTypeDaiStorage;
	}
	else if (isDaiStorageArraySubclass(anObject)) {
		return DaiStorageTypeDaiStorageArray;
	}
	else {
		return DaiStorageTypeOthers;
	}
}

@end
