//
//  DBGallery.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HentaiInfo.h"

@interface HentaiInfo (Status)

- (BOOL)isDownloaded;
- (void)moveToDownloaded;
- (NSInteger)latestPage;
- (void)setLatestPage:(NSInteger)latestPage;

@end

@interface DBGallery : NSObject

// 列表
+ (NSArray<NSDictionary *> *)historiesFrom:(NSInteger)start length:(NSInteger)length;
+ (NSArray<NSDictionary *> *)downloadedsFrom:(NSInteger)start length:(NSInteger)length;

// 刪除
+ (void)deleteDownloaded:(HentaiInfo *)info handler:(void (^)(void))handler onFinish:(void (^)(BOOL successed))finish;
+ (void)deleteAllHistories:(void (^)(NSInteger total, NSInteger index, HentaiInfo *info))handler onFinish:(void (^)(BOOL successed))finish;

@end
