//
//  Setting.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"

@interface Setting : DaiStorage

@property (nonatomic, strong) NSNumber *highResolution;
@property (nonatomic, strong) NSString *themeColor;
@property (nonatomic, strong) NSNumber *useNewBrowser;

- (void)sync;

@end
