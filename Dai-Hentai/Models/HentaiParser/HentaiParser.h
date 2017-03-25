//
//  HentaiParser.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HentaiInfo.h"

typedef enum {
	HentaiParserStatusNetworkFail = -1,
    HentaiParserStatusParseFail,
	HentaiParserStatusSuccess
} HentaiParserStatus;

typedef enum {
    HentaiParserTypeEh,
    HentaiParserTypeEx
} HentaiParserType;

@interface HentaiParser : NSObject

// o.o 不想一直寫 isExHentai 這個 flag
+ (Class)parserType:(HentaiParserType)type;

// 取得 filter 過後的列表
+ (void)requestListUsingFilter:(NSString *)filter completion:(void (^)(HentaiParserStatus status, NSArray<HentaiInfo *> *infos))completion;

// 取得 gallery 圖片頁面們
+ (void)requestImagePagesBy:(HentaiInfo *)info atIndex:(NSInteger)index completion:(void (^)(HentaiParserStatus status, NSInteger nextIndex, NSArray<NSString *> *imagePages))completion;

// 取得圖片頁面中, 真實圖片網址
+ (void)requestImageURL:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion;

@end
