//
//  Setting.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "Setting.h"

@implementation Setting

- (id)init {
    self = [super init];
    if (self) {
        [self importPath:[DaiStoragePath document] defaultPath:[DaiStoragePath resource]];
    }
    return self;
}

- (void)sync {
    [self exportPath:[DaiStoragePath document]];
}

@end
