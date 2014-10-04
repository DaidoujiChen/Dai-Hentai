//
//  HentaiSearchFilter.m
//  CoreGraphicsTest
//
//  Created by OptimusKe on 2014/9/26.
//  Copyright (c) 2014年 Jack. All rights reserved.
//

#import "HentaiSearchFilter.h"

@implementation HentaiSearchFilter

+ (NSString *)searchFilterUrlByKeyword:(NSString *)searchWord filterArray:(NSArray *)filterArray baseUrl:(NSString *)baseUrl {
    NSMutableString *filterURLString = [NSMutableString string];
    [filterURLString appendString:baseUrl];
    
    NSDictionary *filterMapping = @{ @(HentaiFilterTypeDoujinshi)  : @"f_doujinshi=1",
                                     @(HentaiFilterTypeManga)      : @"f_manga=1",
                                     @(HentaiFilterTypeArtistcg)   : @"f_artistcg=1",
                                     @(HentaiFilterTypeGamecg)     : @"f_gamecg=1",
                                     @(HentaiFilterTypeWestern)    : @"f_western=1",
                                     @(HentaiFilterTypeNonh)       : @"f_non-h=1",
                                     @(HentaiFilterTypeImagesets)  : @"f_imageset=1",
                                     @(HentaiFilterTypeCosplay)    : @"f_cosplay=1",
                                     @(HentaiFilterTypeAsianporn)  : @"f_asianporn=1",
                                     @(HentaiFilterTypeMisc)       : @"f_misc=1" };
    
    for (NSNumber *filterNum in filterArray) {
        [filterURLString appendFormat:@"&%@", filterMapping[filterNum]];
    }
    
    //去除掉空白換行字符後, 如果長度不為 0, 則表示有字
    NSCharacterSet *emptyCharacter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[searchWord componentsSeparatedByCharactersInSet:emptyCharacter] componentsJoinedByString:@""].length) {
        [filterURLString appendFormat:@"&f_search=%@", searchWord];
    }
    
    [filterURLString appendString:@"&f_apply=Apply+Filter"];
    
    return [filterURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
