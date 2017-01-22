//
//  HentaiWatching.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2017/1/22.
//  Copyright © 2017年 ChilunChen. All rights reserved.
//

#import "HentaiWatching.h"

@implementation HentaiWatching

#pragma mark - Class Method

+ (BOOL)inCache:(NSString *)hentaiKey {
    return [[self allThings] containsObject:hentaiKey];
}

+ (void)startOn:(NSString *)hentaiKey {
    [[self allThings] addObject:hentaiKey];
}

+ (void)stopOn:(NSString *)hentaiKey {
    [[self allThings] removeObject:hentaiKey];
}

#pragma mark - Privete Class Method

+ (NSMutableArray *)allThings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
