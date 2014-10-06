//
//  NSDictionary+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/6.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "NSDictionary+Hentai.h"

@implementation NSDictionary (Hentai)

- (NSString *)hentaiKey {
    NSArray *splitStrings = [self[@"url"] componentsSeparatedByString:@"/"];
    NSUInteger splitCount = [splitStrings count];
    NSString *checkHentaiKey = [NSString stringWithFormat:@"%@-%@-%@", splitStrings[splitCount - 3], splitStrings[splitCount - 2], self[@"title"]];
    return [checkHentaiKey stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
}

@end
