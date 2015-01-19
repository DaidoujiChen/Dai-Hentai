//
//  NSString+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/6.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "NSString+Hentai.h"

@implementation NSString (Hentai)

- (NSString *)hentai_lastTwoPathComponent {
    NSArray *splitArray = [self componentsSeparatedByString:@"/"];
    NSInteger lastPathIndex = [splitArray count] - 1;
    return [NSString stringWithFormat:@"%@-%@", splitArray[lastPathIndex - 1], splitArray[lastPathIndex]];
}

- (NSString *)hentai_withoutSpace {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
}

@end
