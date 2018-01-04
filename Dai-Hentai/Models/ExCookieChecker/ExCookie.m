//
//  ExCookie.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/4.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "ExCookie.h"

@implementation ExCookie

#pragma mark - Private Class Method

+ (void)replace {
    NSArray<NSHTTPCookie *> *hentaiCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://e-hentai.org"]];
    for (NSHTTPCookie *cookie in hentaiCookies) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:cookie.properties];
        if (properties) {
            properties[@"Domain"] = @".exhentai.org";
            NSHTTPCookie *newCookie = [[NSHTTPCookie alloc] initWithProperties:properties];
            if (newCookie) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
            }
        }
    }
}

#pragma mark - Class Method

+ (BOOL)isExist {
    BOOL isExist = NO;
    NSArray<NSHTTPCookie *> *hentaiCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://e-hentai.org"]];
    for (NSHTTPCookie *cookie in hentaiCookies) {
        if ([cookie.name isEqualToString:@"ipb_pass_hash"]) {
            if ([[NSDate date] compare:cookie.expiresDate] != NSOrderedAscending) {
                isExist = NO;
            }
            else {
                isExist = YES;
            }
        }
    }
    
    if (isExist) {
        [self replace];
    }
    return isExist;
}

@end
