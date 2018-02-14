//
//  UserPreference.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/2/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "UserPreference.h"
#import <UIKit/UIKit.h>

@implementation UserPreference

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = @(UICollectionViewScrollDirectionVertical);
        self.isLockThisApp = @(NO);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    self = [super init];
    if (self) {
        [self restoreContents:[NSMutableDictionary dictionaryWithDictionary:dictionary] defaultContent:nil];
    }
    return self;
}

@end
