//
//  HentaiInfo.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/12.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "HentaiInfo.h"

@implementation HentaiInfo

#pragma mark - Private Instance Method

- (NSArray<NSString *> *)titleSplit:(NSString *)title {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"=♥~【】&/!#,.;:|{}[]() "];
    NSMutableArray *allowResults = [NSMutableArray array];
    for (NSString *splitString in [title componentsSeparatedByCharactersInSet:characterSet]) {
        if (splitString.length && [splitString rangeOfString:@"-"].location == NSNotFound) {
            [allowResults addObject:splitString];
        }
    }
    return allowResults;
}

#pragma mark - Instance Method

- (NSString *)bestTitle {
    NSString *bestTitle = self.title_jpn.length ? self.title_jpn : self.title;
    return bestTitle;
}

- (NSString *)folder {
    NSString *folder = [[[self bestTitle] componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
    return folder;
}

- (NSArray<NSString *> *)engTitleSplit {
    return [self titleSplit:self.title];
}

- (NSArray<NSString *> *)jpnTitleSplit {
    return [self titleSplit:self.title_jpn];
}

@end
