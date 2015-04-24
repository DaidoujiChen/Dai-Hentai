//
//  HentaiParser.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiParser.h"

#import <objc/runtime.h>

#define hentaiAPIURL @"http://g.e-hentai.org/api.php"
#define exHentaiAPIURL @"http://exhentai.org/api.php"

@implementation NSMutableArray (Hentai)

+ (NSMutableArray *)hentai_preAllocWithCapacity:(NSUInteger)capacity {
	NSMutableArray *returnArray = [NSMutableArray array];
	for (NSUInteger i = 0; i < capacity; i++) {
		[returnArray addObject:[NSNull null]];
	}
	return returnArray;
}

@end


@implementation HentaiParser

#pragma mark - class method

+ (void)requestListAtFilterUrl:(NSString *)urlString forExHentai:(BOOL)isForExHentai completion:(void (^)(HentaiParserStatus status, NSArray *listArray))completion {
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection sendAsynchronousRequest:urlRequest queue:[self defaultOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(HentaiParserStatusNetworkFail, nil);
            });
		}
	    else {
	        //這段是從 e hentai 的網頁 parse 列表
	        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	        NSArray *photoURL = [xpathParser searchWithXPathQuery:@"//div [@class='it5']//a"];
            
            //如果 parse 有結果, 才做 request api 的動作, 反之 callback HentaiParserStatusParseFail
            if ([photoURL count]) {
                NSMutableArray *returnArray = [NSMutableArray array];
                NSMutableArray *urlStringArray = [NSMutableArray array];
                
                for (TFHppleElement * eachTitleWithURL in photoURL) {
                    [urlStringArray addObject:[eachTitleWithURL attributes][@"href"]];
                    [returnArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{ @"url": [eachTitleWithURL attributes][@"href"] }]];
                }
                
                //這段是從 e hentai 的 api 抓資料
                [self requestGDataAPIWithURLStrings:urlStringArray forExHentai:(BOOL)isForExHentai completion: ^(HentaiParserStatus status, NSArray *gMetaData) {
                    if (status) {
                        for (NSUInteger i = 0; i < [gMetaData count]; i++) {
                            NSMutableDictionary *eachDictionary = returnArray[i];
                            NSDictionary *metaData = gMetaData[i];
                            eachDictionary[@"thumb"] = metaData[@"thumb"];
                            eachDictionary[@"title"] = metaData[@"title"];
                            eachDictionary[@"title_jpn"] = metaData[@"title_jpn"];
                            eachDictionary[@"category"] = metaData[@"category"];
                            eachDictionary[@"uploader"] = metaData[@"uploader"];
                            eachDictionary[@"filecount"] = metaData[@"filecount"];
                            eachDictionary[@"filesize"] = [NSByteCountFormatter stringFromByteCount:[metaData[@"filesize"] floatValue] countStyle:NSByteCountFormatterCountStyleFile];
                            eachDictionary[@"rating"] = metaData[@"rating"];
                            eachDictionary[@"posted"] = [self dateStringFrom1970:[metaData[@"posted"] doubleValue]];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(HentaiParserStatusSuccess, returnArray);
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(HentaiParserStatusNetworkFail, nil);
                        });
                    }
                }];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(HentaiParserStatusParseFail, nil);
                });
            }
		}
	}];
}

+ (void)requestImagesAtURL:(NSString *)urlString atIndex:(NSUInteger)index completion:(void (^)(HentaiParserStatus status, NSArray *images))completion {
	//網址的範例
	//http://g.e-hentai.org/g/735601/35fe0802c8/?p=2
	NSString *newURLString = [NSString stringWithFormat:@"%@?p=%lud", urlString, index];
	NSURL *newURL = [NSURL URLWithString:newURLString];
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:newURL] queue:[self defaultOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
	        dispatch_async(dispatch_get_main_queue(), ^{
	            completion(HentaiParserStatusNetworkFail, nil);
			});
		}
	    else {
	        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div [@class='gdtm']//a"];
            
            //如果 parse 有結果, 才做 request api 的動作, 反之 callback HentaiParserStatusParseFail
            if ([pageURL count]) {
                NSMutableArray *returnArray = [NSMutableArray hentai_preAllocWithCapacity:[pageURL count]];
                
                dispatch_queue_t hentaiQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                dispatch_group_t hentaiGroup = dispatch_group_create();
                
                for (NSUInteger i = 0; i < [pageURL count]; i++) {
                    TFHppleElement *e = pageURL[i];
                    dispatch_group_async(hentaiGroup, hentaiQueue, ^{
                        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                        [self requestCurrentImage:[NSURL URLWithString:[e attributes][@"href"]] atIndex:i completion: ^(HentaiParserStatus status, NSString *imageString, NSUInteger index) {
                            if (status == HentaiParserStatusSuccess) {
                                returnArray[index] = imageString;
                            }
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    });
                }
                dispatch_group_wait(hentaiGroup, DISPATCH_TIME_FOREVER);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *removeObjects = [NSMutableArray array];
                    for (id eachObj in returnArray) {
                        if ([eachObj isKindOfClass:[NSNull class]]) {
                            [removeObjects addObject:eachObj];
                        }
                    }
                    [returnArray removeObjectsInArray:removeObjects];
                    completion(HentaiParserStatusSuccess, returnArray);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(HentaiParserStatusNetworkFail, nil);
                });
            }
		}
	}];
}

#pragma mark - private

//原網站的時間是 1970, 這邊把他轉為一個人類看得懂的時間格式
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

//這段是使用 e hentai 原本提供的 api 做列表 request 時使用
+ (void)requestGDataAPIWithURLStrings:(NSArray *)urlStringArray forExHentai:(BOOL)isForExHentai completion:(void (^)(HentaiParserStatus status, NSArray *gMetaData))completion {
	//http://g.e-hentai.org/g/618395/0439fa3666/
	//                          -3        -2       -1
	NSMutableArray *idArray = [NSMutableArray array];
	for (NSString *eachURLString in urlStringArray) {
		NSArray *splitStrings = [eachURLString componentsSeparatedByString:@"/"];
		NSUInteger splitCount = [splitStrings count];
		[idArray addObject:@[splitStrings[splitCount - 3], splitStrings[splitCount - 2]]];
	}
    
	// post 給 e hentai api 的固定規則
	NSDictionary *jsonDictionary = @{ @"method": @"gdata", @"gidlist":idArray };
	NSMutableURLRequest *request = [self makeJsonPostRequest:jsonDictionary forExHentai:isForExHentai];
    
	[NSURLConnection sendAsynchronousRequest:request queue:[self defaultOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
            completion(HentaiParserStatusNetworkFail, nil);
		}
	    else {
	        NSDictionary *responseResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(HentaiParserStatusSuccess, responseResult[@"gmetadata"]);
		}
	}];
}

//製造一個 json post 的 request
+ (NSMutableURLRequest *)makeJsonPostRequest:(NSDictionary *)jsonDictionary forExHentai:(BOOL)isForExHentai {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *request;
    if (isForExHentai) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[exHentaiAPIURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[hentaiAPIURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:jsonData];
	return request;
}

//取得單一圖片的聯結
+ (void)requestCurrentImage:(NSURL *)url atIndex:(NSUInteger)index completion:(void (^)(HentaiParserStatus status, NSString *imageString, NSUInteger index))completion {
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[self hentaiOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
	        completion(HentaiParserStatusNetworkFail, nil, -1);
		}
	    else {
	        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *pageURL = [xpathParser searchWithXPathQuery:@"//img"];
            
            //如果 parse 有結果, 才做 request api 的動作, 反之 callback HentaiParserStatusParseFail
            if ([pageURL count]) {
                for (TFHppleElement * e in pageURL) {
                    if ([e attributes][@"src"] && [e attributes][@"style"]) {
                        completion(HentaiParserStatusSuccess, [e attributes][@"src"], index);
                        return;
                    }
                }
            }
            completion(HentaiParserStatusParseFail, nil, -1);
		}
	}];
}

#pragma mark - runtime objects

+ (NSOperationQueue *)hentaiOperationQueue {
	if (!objc_getAssociatedObject(self, _cmd)) {
		objc_setAssociatedObject(self, _cmd, [NSOperationQueue new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return objc_getAssociatedObject(self, _cmd);
}

+ (NSOperationQueue *)defaultOperationQueue {
	if (!objc_getAssociatedObject(self, _cmd)) {
		objc_setAssociatedObject(self, _cmd, [NSOperationQueue new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return objc_getAssociatedObject(self, _cmd);
}

@end
