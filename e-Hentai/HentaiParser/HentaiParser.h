//
//  HentaiParser.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HentaiParserStatusNetworkFail = -1,
    HentaiParserStatusParseFail,
	HentaiParserStatusSuccess
} HentaiParserStatus;

@interface HentaiParser : NSObject

//取得 filter 過後的列表
+ (void)requestListAtFilterUrl:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSArray *listArray))completion;

//取得某一本漫畫中的圖片連結
+ (void)requestImagesAtURL:(NSString *)urlString atIndex:(NSUInteger)index completion:(void (^)(HentaiParserStatus status, NSArray *images))completion;

@end
