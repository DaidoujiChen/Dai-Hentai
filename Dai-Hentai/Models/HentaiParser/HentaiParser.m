//
//  HentaiParser.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiParser.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <hpple/TFHpple.h>
#import "DBGalleryPage.h"
#import "DBGallery.h"
#import "EHentaiParser.h"
#import "ExHentaiParser.h"
#import "ImageURLOperation.h"

#define apiURLString \
({ \
    [NSString stringWithFormat:@"%@api.php", [self domain]]; \
})

#define galleryURLString(gid, token, index) \
({ \
NSString *urlString; \
if (index == 0) \
{ \
urlString = [NSString stringWithFormat:@"%@g/%@/%@/?inline_set=ts_m", [self domain], gid, token]; \
} else { \
urlString = [NSString stringWithFormat:@"%@g/%@/%@/?p=%@&inline_set=ts_m", [self domain], gid, token, @(index)]; \
} \
urlString; \
})

#define completionToMainThread(arg1, args...) \
if ([NSThread isMainThread]) { \
    completion(arg1, ## args); \
} \
else { \
    dispatch_async(dispatch_get_main_queue(), ^{ \
        completion(arg1, ## args); \
    }); \
}

@implementation HentaiParser

#pragma mark - Private Class Method

// 原網站的時間是 1970, 這邊把他轉為一個人類看得懂的時間格式
+ (NSString *)dateStringFrom1970:(NSTimeInterval)date1970 {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    });
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:date1970]];
}

// 這段是使用 e hentai 原本提供的 api 做列表 request 時使用
+ (void)requestGDataAPIWithURLStrings:(NSArray<NSString *> *)urlStrings completion:(void (^)(HentaiParserStatus status, NSArray<NSDictionary *> *gMetaData))completion {
    
    //https://e-hentai.org/g/618395/0439fa3666/
    //                          -3        -2       -1
    NSMutableArray *idArray = [NSMutableArray array];
    for (NSString *urlString in urlStrings) {
        NSArray<NSString *> *splitStrings = [urlString componentsSeparatedByString:@"/"];
        NSUInteger splitCount = splitStrings.count;
        [idArray addObject:@[ splitStrings[splitCount - 3], splitStrings[splitCount - 2] ]];
    }
    
    // post 給 e hentai api 的固定規則
    NSDictionary *jsonDictionary = @{ @"method": @"gdata", @"gidlist": idArray };
    NSMutableURLRequest *request = [self makeJsonPostRequest:jsonDictionary];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionToMainThread(HentaiParserStatusNetworkFail, nil);
        }
        else {
            NSDictionary *responseResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionToMainThread(HentaiParserStatusSuccess, responseResult[@"gmetadata"]);
        }
    }] resume];
}

// 製造一個 json post 的 request
+ (NSMutableURLRequest *)makeJsonPostRequest:(NSDictionary *)jsonDictionary {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *urlString = apiURLString;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    return request;
}

+ (void)parseShowKey:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *showKey))completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:urlString forHTTPHeaderField:@"Referer"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray<TFHppleElement *> *scripts  = [xpathParser searchWithXPathQuery:@"//script [@type='text/javascript']"];
            for (TFHppleElement *scriptsElement in scripts) {
                if (!scriptsElement.attributes[@"src"]) {
                    JSContext *context = [JSContext new];
                    [context evaluateScript:scriptsElement.firstChild.content];
                    JSValue *showKey = [context evaluateScript:@"showkey;"];
                    
                    if (![showKey.toString isEqualToString:@"undefined"]) {
                        completionToMainThread(HentaiParserStatusSuccess, showKey.toString);
                        return;
                    }
                }
            }
        }
        completionToMainThread(HentaiParserStatusParseFail, nil);
    }] resume];
}

+ (void)parseImageURL:(NSString *)gid page:(NSString *)page imgkey:(NSString *)imgkey showKey:(NSString *)showKey completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion {
    
    // post 給 e hentai api 的固定規則
    NSDictionary *jsonDictionary = @{ @"method": @"showpage", @"gid": gid, @"page": page, @"imgkey": imgkey, @"showkey": showKey };
    NSMutableURLRequest *request = [self makeJsonPostRequest:jsonDictionary];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionToMainThread(HentaiParserStatusNetworkFail, nil);
        }
        else {
            NSDictionary *responseResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (responseResult[@"error"]) {
                completionToMainThread(HentaiParserStatusParseFail, nil);
            }
            else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:[responseResult[@"i3"] dataUsingEncoding:NSUTF8StringEncoding]];
                NSArray<TFHppleElement *> *imgs  = [xpathParser searchWithXPathQuery:@"//a/img"];
                completionToMainThread(HentaiParserStatusSuccess, imgs.firstObject.attributes[@"src"]);
            }
        }
    }] resume];
}

+ (NSString *)domain {
    NSAssert(0, @"Must Implement This Method in Subclass.");
    return nil;
}

+ (NSOperationQueue *)showKeyQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue *showKeyQueue = [NSOperationQueue new];
        showKeyQueue.maxConcurrentOperationCount = 1;
        objc_setAssociatedObject(self, _cmd, showKeyQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)showKeys {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Class Method

+ (Class)parserType:(HentaiParserType)type {
    switch (type) {
        case HentaiParserTypeEh:
            return [EHentaiParser class];
        
        case HentaiParserTypeEx:
            return [ExHentaiParser class];
            
        default:
            NSAssert(0, @"Unknow Parser Type.");
    }
}

+ (void)requestListUsingFilter:(NSString *)filter completion:(void (^)(HentaiParserStatus status, NSArray<HentaiInfo *> *infos))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self domain], filter];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completionToMainThread(HentaiParserStatusNetworkFail, nil);
        }
        else {
            
            //這段是從 e hentai 的網頁 parse 列表
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray<TFHppleElement *> *photoURLs = [xpathParser searchWithXPathQuery:@"//td [@class='gl3c glname']//a"];
            
            //如果 parse 有結果, 才做 request api 的動作, 反之 callback HentaiParserStatusParseFail
            if (photoURLs.count) {
                NSMutableArray *urlStrings = [NSMutableArray array];
                
                for (TFHppleElement *photoURL in photoURLs) {
                    NSString *photoURLString = photoURL.attributes[@"href"];
                    [urlStrings addObject:photoURLString];
                }
                
                //這段是從 e hentai 的 api 抓資料
                [self requestGDataAPIWithURLStrings:urlStrings completion: ^(HentaiParserStatus status, NSArray<NSDictionary *> *gMetaDatas) {
                    if (status) {
                        NSMutableArray<HentaiInfo *> *infos = [NSMutableArray array];
                        for (NSUInteger i = 0; i < gMetaDatas.count; i++) {
                            NSDictionary *gMetaData = gMetaDatas[i];
                            HentaiInfo *info = [HentaiInfo new];
                            info.gid = gMetaData[@"gid"];
                            info.token = gMetaData[@"token"];
                            info.thumb = gMetaData[@"thumb"];
                            info.title = gMetaData[@"title"];
                            info.title_jpn = gMetaData[@"title_jpn"];
                            info.category = gMetaData[@"category"];
                            info.uploader = gMetaData[@"uploader"];
                            info.filecount = gMetaData[@"filecount"];
                            info.filesize = [NSByteCountFormatter stringFromByteCount:[gMetaData[@"filesize"] floatValue] countStyle:NSByteCountFormatterCountStyleFile];
                            info.rating = gMetaData[@"rating"];
                            info.posted = [self dateStringFrom1970:[gMetaData[@"posted"] doubleValue]];
                            [info.tags addObjectsFromArray:gMetaData[@"tags"]];
                            info.userLatestPage = @(0);
                            [infos addObject:info];
                        }
                        completionToMainThread(HentaiParserStatusSuccess, infos);
                    }
                    else {
                        completionToMainThread(HentaiParserStatusNetworkFail, nil);
                    }
                }];
            }
            else {
                completionToMainThread(HentaiParserStatusParseFail, nil);
            }
        }
    }] resume];
}

+ (void)requestImagePagesBy:(HentaiInfo *)info atIndex:(NSInteger)index completion:(void (^)(HentaiParserStatus status, NSInteger nextIndex, NSArray<NSString *> *imagePages))completion {
    
    NSMutableArray<NSString *> *pages = [NSMutableArray array];
    NSArray<NSString *> *cachePages;
    NSInteger cacheIndex = index;
    do {
        cachePages = [DBGalleryPage by:info.gid token:info.token index:cacheIndex];
        if (cachePages) {
            [pages addObjectsFromArray:cachePages];
            cacheIndex++;
        }
        
        if (pages.count > [info latestPage]) {
            break;
        }
    } while (cachePages);
    if (pages.count) {
        completionToMainThread(HentaiParserStatusSuccess, cacheIndex, pages);
    }
    else {
        //網址的範例
        //https://e-hentai.org/g/735601/35fe0802c8/?p=2
        NSString *urlString = galleryURLString(info.gid, info.token, index);
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                completionToMainThread(HentaiParserStatusNetworkFail, index, nil);
            }
            else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray<TFHppleElement *> *pageURLs  = [xpathParser searchWithXPathQuery:@"//div [@class='gdtm']//a"];
                
                //如果 parse 有結果, 才做 request api 的動作, 反之 callback HentaiParserStatusParseFail
                if (pageURLs.count) {
                    NSMutableArray<NSString *> *newPages = [NSMutableArray array];
                    for (TFHppleElement *pageURLElement in pageURLs) {
                        [newPages addObject:pageURLElement.attributes[@"href"]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DBGalleryPage add:info.gid token:info.token index:index pages:newPages];
                        completionToMainThread(HentaiParserStatusSuccess, index + 1, newPages);
                    });
                }
                else {
                    completionToMainThread(HentaiParserStatusParseFail, index, nil);
                }
            }
        }] resume];
    }
}

+ (void)requestImageURL:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion {
    ImageURLOperation *newOperation = [[ImageURLOperation alloc] initWithURLString:urlString completion:completion];
    newOperation.parser = self;
    [[self showKeyQueue] addOperation:newOperation];
}

@end
