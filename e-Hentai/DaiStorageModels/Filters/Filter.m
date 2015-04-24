//
//  Filter.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "Filter.h"

@implementation Filter

- (id)init {
    self = [super init];
    if (self) {
        [self.items setAllowClass:[FilterItem class]];
        [self importPath:[DaiStoragePath resource]];
    }
    return self;
}

@end
