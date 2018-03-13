//
//  Translator.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "Translator.h"
#import <objc/runtime.h>
#import "FilesManager.h"

@implementation Translator

#pragma mark - Class Method

+ (NSString *)remove:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" \\(.*\\)" options:0 error:nil];
    return [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
}

+ (NSString *)from:(NSString *)eng {
    NSString *translator = objc_getAssociatedObject(self, @selector(load))[eng];
    if (translator) {
        return [NSString stringWithFormat:@" (%@)", translator];
    }
    return @"";
}

#pragma mark - Life Cycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[[FilesManager resourceFolder] read:@"translator.json"] options:NSJSONReadingMutableLeaves error:nil];
        objc_setAssociatedObject(self, _cmd, jsonObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

@end
