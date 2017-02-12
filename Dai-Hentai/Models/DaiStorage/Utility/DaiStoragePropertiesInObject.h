//
//  DaiStoragePropertiesInObject.h
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaiStorageProperty.h"

@interface DaiStoragePropertiesInObject : NSObject

+ (NSArray *)enumerate:(id)anObject;

@end
