//
//  SearchInfo.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/21.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchInfo.h"

@implementation SearchInfo

#pragma mark - Instance Method

- (NSString *)query:(NSInteger)page {
    NSMutableString *query = [NSMutableString stringWithFormat:@"?page=%ld&f_doujinshi=%@&f_manga=%@&f_artistcg=%@&f_gamecg=%@&f_western=%@&f_non-h=%@&f_imageset=%@&f_cosplay=%@&f_asianporn=%@&f_misc=%@&f_search=%@&f_apply=Apply+Filter", page, self.doujinshi, self.manga, self.artistcg, self.gamecg, self.western, self.non_h, self.imageset, self.cosplay, self.asianporn, self.misc, self.keyword];
    
    if ([self.rating compare:@(0)] != NSOrderedSame) {
        [query appendFormat:@"&advsearch=1&f_sname=on&f_stags=on&f_sr=on&f_srdd=%ld", self.rating.integerValue + 1];
    }
    return [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyword = @"";
        self.rating = @(0);
        self.doujinshi = @(1);
        self.manga = @(1);
        self.artistcg = @(1);
        self.gamecg = @(1);
        self.western = @(1);
        self.non_h = @(1);
        self.imageset = @(1);
        self.cosplay = @(1);
        self.asianporn = @(1);
        self.misc = @(1);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary {
    self = [super init];
    if (self) {
        [self restoreContents:[NSMutableDictionary dictionaryWithDictionary:dictionary] defaultContent:nil];
    }
    return self;
}

@end
