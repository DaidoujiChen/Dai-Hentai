//
//  DaiPortalWarehouse.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiPortalWarehouse.h"

#import <objc/runtime.h>

@implementation DaiPortalWarehouse

#pragma mark - class method

+ (void)sign:(DaiPortal *)newPortal {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
        [[weakSelf portals] addObject:newPortal];
    }];
}

+ (void)resign:(id)dependObject {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
        NSMutableArray *removeObjects = [NSMutableArray array];
        for (DaiPortal *eachPortal in [weakSelf portals]) {
            if (eachPortal.dependObject == dependObject) {
                [[weakSelf daiPortalNotificationCenter] removeObserver:eachPortal];
                [removeObjects addObject:eachPortal];
            }
        }
        [[weakSelf portals] removeObjectsInArray:removeObjects];
    }];
}

+ (void)removeDisposable:(DaiPortal *)disposableObject {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
        [[weakSelf daiPortalNotificationCenter] removeObserver:disposableObject];
        [[weakSelf portals] removeObject:disposableObject];
    }];
}

#pragma mark - private

+ (void)portalPotecter:(void (^)(void))yourCode {
    //dispatch_sync(dispatch_get_main_queue(), yourCode);
    yourCode();
}

+ (NSMutableArray *)portals {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSNotificationCenter *)daiPortalNotificationCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSNotificationCenter new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
