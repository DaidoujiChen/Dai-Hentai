//
//  Filter.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"
#import "FilterItem.h"

DaiStorageArrayConverter(FilterItem)

@interface Filter : DaiStorage

@property (nonatomic, strong) FilterItemArray *items;

@end
