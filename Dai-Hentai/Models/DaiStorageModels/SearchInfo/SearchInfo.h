//
//  SearchInfo.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/21.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "DaiStorage.h"

@interface SearchInfo : DaiStorage

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *doujinshi;
@property (nonatomic, strong) NSNumber *manga;
@property (nonatomic, strong) NSNumber *artistcg;
@property (nonatomic, strong) NSNumber *gamecg;
@property (nonatomic, strong) NSNumber *western;
@property (nonatomic, strong) NSNumber *non_h;
@property (nonatomic, strong) NSNumber *imageset;
@property (nonatomic, strong) NSNumber *cosplay;
@property (nonatomic, strong) NSNumber *asianporn;
@property (nonatomic, strong) NSNumber *misc;
@property (nonatomic, strong) NSNumber *chineseOnly;
@property (nonatomic, strong) NSNumber *originalOnly;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSString *)query:(NSInteger)page next:(NSString *)next;
- (NSMutableArray<NSString *> *)hints;
- (void)setHints:(NSString *)hint;

@end
