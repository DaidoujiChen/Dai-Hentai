//
//  Menu.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "Menu.h"

@implementation Menu

- (id)init {
    self = [super init];
    if (self) {
        [self.items setAllowClass:[MenuItem class]];
        [self importPath:[DaiStoragePath resource]];
    }
    return self;
}

@end
