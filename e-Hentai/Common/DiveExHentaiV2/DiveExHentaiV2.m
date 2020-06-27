//
//  DiveExHentaiV2.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2016/11/28.
//  Copyright © 2016年 ChilunChen. All rights reserved.
//

#import "DiveExHentaiV2.h"
#import <objc/runtime.h>

// 這邊 method 的邏輯取自專案 Shinsi
// 感謝 @Powhu

@implementation DiveExHentaiV2

#pragma mark - Private Class Method

#pragma mark * cookie 操作

+ (void)refresh:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL isSuccess))completion {
    NSMutableURLRequest *request = [self generateRequestUsing:username and:password];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = [self additionalHeaders];
    
    [[[NSURLSession sessionWithConfiguration:configuration] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                BOOL isSuccess = [self checkCookie];
                if (isSuccess) {
                    [self replaceCookies];
                }
                completion(isSuccess);
            }
            else {
                completion(NO);
            }
        });
    }] resume];
}

#pragma mark * request 相關

// 這邊有些 method 是從 Alamofire swift 轉成 objective-c =_____=

// 客製 ua
+ (NSString *)userAgent {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *userAgent;
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        if (info) {
            NSString *executable = info[(__bridge NSString *)kCFBundleExecutableKey] ? : @"Unknown";
            NSString *bundle = info[(__bridge NSString *)kCFBundleIdentifierKey] ? : @"Unknown";
            NSString *version = info[(__bridge NSString *)kCFBundleVersionKey] ? : @"Unknown";
            NSString *osNameVersion = @"iOS 10.9";
            userAgent = [NSString stringWithFormat:@"%@/%@ (%@; %@)", executable, bundle, version, osNameVersion];
        }
        else {
            userAgent = @"Alamofire";
        }
        objc_setAssociatedObject(self, _cmd, userAgent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

// 額外 header
+ (NSDictionary *)additionalHeaders {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *acceptEncoding = @"gzip;q=1.0, compress;q=0.5";
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        NSMutableArray *languageCodes = [NSMutableArray array];
        for (NSInteger index = 0; index < preferredLanguages.count && index < 6; index++) {
            CGFloat quality = 1.0f - (index * 0.1f);
            [languageCodes addObject:[NSString stringWithFormat:@"%@;q=%f", preferredLanguages[index], quality]];
        }
        NSString *acceptLanguage = [languageCodes componentsJoinedByString:@", "];
        NSString *userAgent = [self userAgent];
        objc_setAssociatedObject(self, _cmd, @{ @"Accept-Encoding": acceptEncoding, @"Accept-Language": acceptLanguage, @"User-Agent": userAgent}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

// query string
+ (NSString *)query:(NSDictionary <NSString *, NSString *> *)parameters {
    NSMutableArray *queries = [NSMutableArray array];
    for (NSString *key in parameters.allKeys) {
        [queries addObject:[NSString stringWithFormat:@"%@=%@", key, parameters[key]]];
    }
    return [queries componentsJoinedByString:@"&"];
}

// 製作一個新的 request
+ (NSMutableURLRequest *)generateRequestUsing:(NSString *)username and:(NSString *)password {
    NSString *urlString = @"https://forums.e-hentai.org/index.php?act=Login&CODE=01";
    NSDictionary *parameters = @{ @"CookieDate": @"1", @"b": @"d", @"bt": @"1-1", @"UserName": username, @"PassWord": password, @"ipb_login_submit": @"Login!" };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self query:parameters] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

#pragma mark - Class Method

+ (void)replaceCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://e-hentai.org"]]) {
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

+ (BOOL)checkCookie {
    NSURL *hentaiURL = [NSURL URLWithString:@"https://e-hentai.org"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hentaiURL]) {
        if ([cookie.name isEqualToString:@"ipb_pass_hash"]) {
            if ([[NSDate date] compare:cookie.expiresDate] != NSOrderedAscending) {
                return false;
            }
            else {
                return true;
            }
        }
    }
    return NO;
}

+ (void)diveBy:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL isSuccess))completion {
    if ([self checkCookie]) {
        completion(YES);
    }
    else {
        [self refresh:username andPassword:password completion:completion];
    }
}

@end
