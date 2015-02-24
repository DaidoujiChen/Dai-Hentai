//
//  DaiPortalPackage.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortalPackage.h"

@implementation DaiPortalPackageNil

+ (DaiPortalPackageNil *)nilObject {
    static DaiPortalPackageNil *daiPortalPackageNil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        daiPortalPackageNil = [DaiPortalPackageNil new];
    });
    return daiPortalPackageNil;
}

@end

@interface DaiPortalPackage ()

@property (nonatomic, strong) id anyObject;

@end

@implementation DaiPortalPackage

+ (DaiPortalPackage *)empty {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = nil;
    return newResult;
}

+ (DaiPortalPackage *)item:(id)anObject {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = @[anObject?:[DaiPortalPackageNil nilObject]];
    return newResult;
}

+ (DaiPortalPackage *)itemsFromArray:(NSArray *)objects {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = [objects copy];
    return newResult;
}

@end
