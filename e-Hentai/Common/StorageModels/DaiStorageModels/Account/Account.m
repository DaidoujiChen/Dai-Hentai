//
//  Account.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "Account.h"

@implementation Account

- (id)init {
    self = [super init];
    if (self) {
        [self importPath:[DaiStoragePath document]];
    }
    return self;
}

- (void)sync {
    [self exportPath:[DaiStoragePath document]];
}

@end
