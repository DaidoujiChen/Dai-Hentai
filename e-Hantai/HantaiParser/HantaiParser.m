//
//  HantaiParser.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HantaiParser.h"

#import <objc/runtime.h>

#define baseListURL @"http://g.e-hentai.org/?page=%d"

@implementation NSMutableArray (HANTAI)

+ (NSMutableArray *)hantai_preAllocWithCapacity:(NSUInteger)capacity
{
    NSMutableArray *returnArray = [NSMutableArray array];
    for (NSUInteger i=0; i<capacity; i++) {
        [returnArray addObject:[NSNull null]];
    }
    return returnArray;
}

@end

@implementation HantaiParser

#pragma mark - class method

+ (void)requestListAtIndex:(NSUInteger)index completion:(void (^)(HantaiParserStatus status, NSArray *listArray))completion
{
	NSString *urlString = [NSString stringWithFormat:baseListURL, index];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
	        completion(HantaiParserStatusFail, nil);
		} else {
#warning  改進的空間, 這邊會慢些
	        TFHpple * xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	        NSArray *type  = [xpathParser searchWithXPathQuery:@"//td [@class='itdc']//img"];
	        NSArray *published = [xpathParser searchWithXPathQuery:@"//td [@style='white-space:nowrap']"];
	        NSArray *titleWithURL = [xpathParser searchWithXPathQuery:@"//div [@class='it5']//a"];
	        NSArray *uploader = [xpathParser searchWithXPathQuery:@"//td [@class='itu']//div//a"];
            
	        NSMutableArray *returnArray = [NSMutableArray array];
            
	        for (NSUInteger i = 0; i < [type count]; i++) {
	            TFHppleElement *eachType = type[i];
	            TFHppleElement *eachPublished = published[i];
	            TFHppleElement *eachTitleWithURL = titleWithURL[i];
	            TFHppleElement *eachUploader = uploader[i];
	            [returnArray addObject:@{ @"type": [eachType attributes][@"alt"], @"published": [eachPublished text], @"title": [eachTitleWithURL text], @"url": [eachTitleWithURL attributes][@"href"], @"uploader":[eachUploader text] }];
			}
            
	        completion(HantaiParserStatusSuccess, returnArray);
            
#warning 保留, pa 星星的部分要算, 懶惰算
	        /*NSArray *star = [xpathParser searchWithXPathQuery:@"//div [@class='it4']//div"];
             for (TFHppleElement *e in star) {
             NSLog(@"%@", [e attributes][@"style"]);
             }*/
		}
	}];
}

+ (void)requestImagesAtURL:(NSURL *)url completion:(void (^)(HantaiParserStatus status, NSArray *images))completion
{
#warning 只先 pa 第一頁吧
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
	        completion(HantaiParserStatusFail, nil);
		} else {
	        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div [@class='gdtm']//a"];
	        NSMutableArray *returnArray = [NSMutableArray hantai_preAllocWithCapacity:[pageURL count]];
            
            dispatch_queue_t hantaiQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_group_t hantaiGroup = dispatch_group_create();
            
            for (NSUInteger i=0; i<[pageURL count]; i++) {
                TFHppleElement *e = pageURL[i];
                dispatch_group_async(hantaiGroup, hantaiQueue, ^{
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [self requestCurrentImage:[NSURL URLWithString:[e attributes][@"href"]] atIndex:i completion: ^(HantaiParserStatus status, NSString *imageString, NSUInteger index) {
                        if (status) {
                            returnArray[index] = imageString;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                });
            }
            dispatch_group_wait(hantaiGroup, DISPATCH_TIME_FOREVER);
	        completion(HantaiParserStatusSuccess, returnArray);
		}
	}];
}


#pragma mark - private

+ (void)requestCurrentImage:(NSURL *)url atIndex:(NSUInteger)index completion:(void (^)(HantaiParserStatus status, NSString *imageString, NSUInteger index))completion
{
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[self hantaiOperationQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError) {
	        completion(HantaiParserStatusFail, nil, -1);
		} else {
	        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div [@id='i3']//img"];
	        for (TFHppleElement * e in pageURL) {
	            completion(HantaiParserStatusSuccess, [e attributes][@"src"], index);
	            break;
			}
		}
	}];
}

+ (NSOperationQueue *)hantaiOperationQueue
{
	if (!objc_getAssociatedObject(self, _cmd)) {
		objc_setAssociatedObject(self, _cmd, [NSOperationQueue new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return objc_getAssociatedObject(self, _cmd);
}

@end
