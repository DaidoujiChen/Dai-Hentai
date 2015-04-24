//
//  Prefer.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "Prefer.h"

@implementation Prefer

- (id)init {
    self = [super init];
    if (self) {
        [self.flags setAllowClass:[NSNumber class]];
        [self importPath:[DaiStoragePath document] defaultPath:[DaiStoragePath resource]];
    }
    return self;
}

- (void)sync {
    [self exportPath:[DaiStoragePath document]];
}

@end
