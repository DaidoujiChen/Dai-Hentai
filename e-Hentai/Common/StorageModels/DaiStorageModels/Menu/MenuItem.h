//
//  MenuItem.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"

@interface MenuItem : DaiStorage

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *controller;

@end
