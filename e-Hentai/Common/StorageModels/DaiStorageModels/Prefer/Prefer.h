//
//  Prefer.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"

@interface Prefer : DaiStorage

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) DaiStorageArray *flags;
@property (nonatomic, strong) NSNumber *rating;

- (void)sync;

@end
