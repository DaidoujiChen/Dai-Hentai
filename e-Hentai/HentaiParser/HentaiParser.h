//
//  HentaiParser.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HentaiParserStatusFail,
	HentaiParserStatusSuccess
} HentaiParserStatus;

@interface HentaiParser : NSObject

+ (void)requestListAtIndex:(NSUInteger)index completion:(void (^)(HentaiParserStatus status, NSArray *listArray))completion;
+ (void)requestImagesAtURL:(NSString *)urlString atIndex:(NSUInteger)index completion:(void (^)(HentaiParserStatus status, NSArray *images))completion;

@end
