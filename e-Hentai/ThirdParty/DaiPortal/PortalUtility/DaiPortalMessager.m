//
//  DaiPortalMessager.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiPortalMessager.h"

#import <objc/runtime.h>

@implementation DaiPortalMessager

#pragma mark - class method

+ (void)sign:(DaiPortal *)newPortal {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[weakSelf daiPortalNotificationCenter] addObserver:newPortal selector:@selector(handleRecvNotification:) name:newPortal.identifier object:nil];
#pragma clang diagnostic pop
        [[weakSelf portals] addObject:newPortal];
    }];
}

+ (void)broadcastToIdentifier:(NSString *)identifier objects:(NSArray *)objects fromSource:(id)source {
    [[DaiPortalMessager daiPortalNotificationCenter] postNotificationName:identifier object:objects userInfo:@{ @"source": source }];
}

+ (void)destory:(id)dependObject {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
        NSMutableArray *removeObjects = [NSMutableArray array];
        for (DaiPortal *eachPortal in [weakSelf portals]) {
            if (eachPortal.dependObject == dependObject) {
                [[weakSelf daiPortalNotificationCenter] removeObserver:eachPortal name:eachPortal.identifier object:nil];
                [removeObjects addObject:eachPortal];
            }
        }
        [[weakSelf portals] removeObjectsInArray:removeObjects];
    }];
}

+ (void)resign:(DaiPortal *)portal {
    __weak id weakSelf = self;
    [self portalPotecter: ^{
        [[weakSelf daiPortalNotificationCenter] removeObserver:portal name:portal.identifier object:nil];
        [[weakSelf portals] removeObject:portal];
    }];
}

#pragma mark - private

#pragma mark * misc

+ (void)portalPotecter:(void (^)(void))yourCode {
    //dispatch_sync(dispatch_get_main_queue(), yourCode);
    yourCode();
}

#pragma mark * runtime objects

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
