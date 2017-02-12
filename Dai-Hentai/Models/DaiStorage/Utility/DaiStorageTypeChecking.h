//
//  DaiStorageTypeChecking.h
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/22.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DaiStorageTypeDaiStorage,
	DaiStorageTypeDaiStorageArray,
	DaiStorageTypeOthers
} DaiStorageType;

@interface DaiStorageTypeChecking : NSObject

+ (DaiStorageType)on:(id)anObject;

@end
