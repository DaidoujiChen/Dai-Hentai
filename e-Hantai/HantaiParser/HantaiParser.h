//
//  HantaiParser.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HantaiParserStatusFail,
	HantaiParserStatusSuccess
} HantaiParserStatus;

@interface HantaiParser : NSObject

+ (void)requestListAtIndex:(NSUInteger)index completion:(void (^)(HantaiParserStatus status, NSArray *listArray))completion;
+ (void)requestImagesAtURL:(NSURL *)url completion:(void (^)(HantaiParserStatus status, NSArray *images))completion;

@end
