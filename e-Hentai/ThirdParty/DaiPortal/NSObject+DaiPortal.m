//
//  NSObject+DaiPortal.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/25.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "NSObject+DaiPortal.h"

@implementation NSObject (DaiPortal)

#pragma mark - instance method

- (DaiPortal *)portal:(NSString *)identifier {
    DaiPortal *newPortal = [DaiPortal new];
    newPortal.identifier = identifier;
    newPortal.dependObject = self;
    return newPortal;
}

#pragma mark - class method

+ (DaiPortal *)portal:(NSString *)identifier {
    DaiPortal *newPortal = [DaiPortal new];
    newPortal.identifier = identifier;
    newPortal.dependObject = self;
    return newPortal;
}

@end
