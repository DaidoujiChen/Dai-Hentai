//
//  DiveExHentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/15.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DiveExHentai.h"

#import <objc/runtime.h>

typedef enum {
    DiveExHentaiStatusFirstCheck,
    DiveExHentaiStatusOpenPage,
    DiveExHentaiStatusLogin,
    DiveExHentaiStatusMeetPanda,
    DiveExHentaiStatusFinish
} DiveExHentaiStatus;

@implementation DiveExHentai

#pragma mark - class method

+ (void)diveByUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(BOOL isSuccess))completion {
    if (userName == nil || password == nil || completion == nil) {
        NSLog(@"變數都要填滿!");
        completion(NO);
        return;
    }
    [self setUserName:userName];
    [self setPassword:password];
    [self setCompletion:completion];
    [self setStatus:DiveExHentaiStatusFirstCheck];
    [[self hentaiWebView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://exhentai.org/"]]];
}

#pragma mark - UIWebViewDelegate

+ (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *htmlTitle = [[self hentaiWebView] stringByEvaluatingJavaScriptFromString:@"document.title"];
    switch ([self status]) {
        case DiveExHentaiStatusFirstCheck:
        {
            if ([htmlTitle isEqualToString:@"ExHentai.org"]) {
                [self completion](YES);
                objc_removeAssociatedObjects(self);
            }
            else {
                [self setStatus:DiveExHentaiStatusOpenPage];
                [[self hentaiWebView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://e-hentai.org/"]]];
            }
            break;
        }
        //開啟 e-hentai 網頁階段, 由於可能開的不完整, 所以要 fill 到 ok 才按 button, 否則 reload
        case DiveExHentaiStatusOpenPage:
        {
            if ([htmlTitle isEqualToString:@"E-Hentai.org -- Free Hentai, Doujinshi, Manga, CG Sets, H-Anime"]) {
                NSString *autoFill = [NSString stringWithFormat:@"var userNameTextField = document.querySelectorAll(\"input[name='UserName']\"); userNameTextField[0].value = '%@';var passwordTextField = document.querySelectorAll(\"input[name='PassWord']\"); passwordTextField[0].value = '%@';", [self userName], [self password]];
                if (![[[self hentaiWebView] stringByEvaluatingJavaScriptFromString:autoFill] isEqualToString:@""]) {
                    NSLog(@"start to Login E-hentai...");
                    [self setStatus:DiveExHentaiStatusLogin];
                    [[self hentaiWebView] stringByEvaluatingJavaScriptFromString:@"var buttons = document.querySelectorAll(\"input[name='ipb_login_submit']\"); buttons[0].click();"];
                }
                else {
                    [webView reload];
                }
            }
            break;
        }
        
        //登入之後拿下他的餅乾, 並且篡改所有的 e-hentai 變為 exhentai, 之後去開 exhentai.org 網頁
        case DiveExHentaiStatusLogin:
        {
            if ([htmlTitle isEqualToString:@"E-Hentai.org -- Free Hentai, Doujinshi, Manga, CG Sets, H-Anime"]) {
                NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                for (NSHTTPCookie *each in cookieStorage.cookies) {
                    NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary:each.properties];
                    NSString *newDomain = [each.properties[@"Domain"] stringByReplacingOccurrencesOfString:@"e-hentai" withString:@"exhentai"];
                    newProperties[@"Domain"] = newDomain;
                    [[self cookies] addObject:[[NSHTTPCookie alloc] initWithProperties:newProperties]];
                }
                
                NSLog(@"got cookies and redirect to exhentai.org...");
                [self setStatus:DiveExHentaiStatusMeetPanda];
                [[self hentaiWebView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://exhentai.org/"]]];
            }
            break;
        }
        
        //開啟 exhentai.org 網頁之後會看到熊貓人, 這時候把篡改的餅乾整個替換過去, 重新 load 網頁
        case DiveExHentaiStatusMeetPanda:
        {
            NSRange range = [htmlTitle rangeOfString:@"exhentai.org 260×260"];
            if (range.location != NSNotFound) {
                NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                for (NSHTTPCookie *each in cookieStorage.cookies) {
                    [cookieStorage deleteCookie:each];
                }
                
                for (NSHTTPCookie *eachCookies in [self cookies]) {
                    [cookieStorage setCookie:eachCookies];
                }
                
                NSLog(@"meet panda and replace cookies...");
                [self setStatus:DiveExHentaiStatusFinish];
                [[self hentaiWebView] reload];
            }
            break;
        }
        
        //成功的話就可以潛入 exhentai 了
        case DiveExHentaiStatusFinish:
        {
            if ([htmlTitle isEqualToString:@"ExHentai.org"]) {
                [self completion](YES);
            }
            else {
                [self completion](NO);
            }
            objc_removeAssociatedObjects(self);
            break;
        }
    }
}

#pragma mark - runtime objects

+ (UIWebView *)hentaiWebView {
    if (!objc_getAssociatedObject(self, _cmd)) {
        UIWebView *hentaiWebView = [UIWebView new];
        hentaiWebView.delegate = (id <UIWebViewDelegate> )self;
        objc_setAssociatedObject(self, _cmd, hentaiWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableArray *)cookies {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setCompletion:(void (^)(BOOL isSuccess))completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void (^)(BOOL successed))completion {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setUserName:(NSString *)userName {
    objc_setAssociatedObject(self, @selector(userName), userName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)userName {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setPassword:(NSString *)password {
    objc_setAssociatedObject(self, @selector(password), password, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)password {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setStatus:(int)status {
    objc_setAssociatedObject(self, @selector(status), @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (int)status {
    NSNumber *status = objc_getAssociatedObject(self, _cmd);
    return status.intValue;
}

@end
