//
//  MeetAVParser.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MeetParserStatusNetworkFail = -1,
    MeetParserStatusParseFail,
    MeetParserStatusSuccess
} MeetParserStatus;

@interface MeetAVParser : NSObject

+ (void)requestListForQuery:(NSString *)query completion:(void (^)(MeetParserStatus status, NSArray *listArray))completion;
+ (void)parseVideoFrom:(NSString *)urlString completion:(void (^)(MeetParserStatus status, NSString *videoURL))completion;

@end
