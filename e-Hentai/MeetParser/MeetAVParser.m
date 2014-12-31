//
//  MeetAVParser.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MeetAVParser.h"

#import <objc/runtime.h>

@implementation MeetAVParser

#pragma mark - class method

+ (void)requestListForQuery:(NSString *)query completion:(void (^)(MeetParserStatus status, NSArray *listArray))completion {
    NSString *queryString = [NSString stringWithFormat:@"http://www.meetav.com/search_result.php?query=%@&type=videos&submit=Search", query];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] queue:[self defaultOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(MeetParserStatusNetworkFail, nil);
            });
            return;
        }
        
        NSMutableArray *listArray = [NSMutableArray array];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data encoding:@"utf-8"];
        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//h2 [@style='display:none']//a"];
        NSArray *thumbURL = [xpathParser searchWithXPathQuery:@"//div [@class='vid_thumb']//a//img"];
        
        if ([pageURL count]) {
            for (int i=0; i<[pageURL count]; i++) {
                TFHppleElement *eachURL = pageURL[i];
                TFHppleElement *eachThumbURL = thumbURL[i];
                [listArray addObject:@{ @"title":[eachURL text], @"url":[eachURL attributes][@"href"], @"thumb":[eachThumbURL attributes][@"src"] }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(MeetParserStatusSuccess, listArray);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(MeetParserStatusParseFail, nil);
            });
        }
    }];
}

+ (void)parseVideoFrom:(NSString *)urlString completion:(void (^)(MeetParserStatus status, NSString *videoURL))completion {
    [self setCompletion:completion];
    [[self meetAVWebView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
}

#pragma mark - UIWebViewDelegate

+ (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *hq_video_file = [self.meetAVWebView stringByEvaluatingJavaScriptFromString:@"hq_video_file"];
    if (hq_video_file) {
        if ([[hq_video_file pathExtension] isEqualToString:@"mp4"]) {
            [self completion](MeetParserStatusSuccess, hq_video_file);
        }
        else {
            [self completion](MeetParserStatusParseFail, nil);
        }
        [webView stopLoading];
        [self setMeetAVWebView:nil];
    }
}

+ (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self completion](MeetParserStatusNetworkFail, nil);
    [webView stopLoading];
    [self setMeetAVWebView:nil];
}

#pragma mark - runtime objects

+ (void)setMeetAVWebView:(UIWebView *)meetAVWebView {
    objc_setAssociatedObject(self, @selector(meetAVWebView), meetAVWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIWebView *)meetAVWebView {
    if (!objc_getAssociatedObject(self, _cmd)) {
        UIWebView *meetAVWebView = [UIWebView new];
        meetAVWebView.delegate = (id <UIWebViewDelegate> )self;
        [self setMeetAVWebView:meetAVWebView];
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setCompletion:(void (^)(MeetParserStatus status, NSString *videoURL))completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void (^)(MeetParserStatus status, NSString *videoURL))completion {
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSOperationQueue *)defaultOperationQueue {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, [NSOperationQueue new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

@end
