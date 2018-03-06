//
//  DBGallery.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HentaiInfo.h"

extern NSNotificationName const DBGalleryTimeStampUpdateNotification;
extern NSNotificationName const DBGalleryDownloadedUpdateNotification;

@interface HentaiInfo (Status)

- (BOOL)isDownloaded;
- (void)moveToDownloaded;
- (NSInteger)latestPage;
- (void)setLatestPage:(NSInteger)latestPage;

@end

@interface DBGallery : NSObject

// 列表
+ (NSArray<HentaiInfo *> *)all;
+ (NSArray<HentaiInfo *> *)historiesFrom:(NSInteger)start length:(NSInteger)length;
+ (NSArray<HentaiInfo *> *)downloadedsFrom:(NSInteger)start length:(NSInteger)length;
+ (NSArray<HentaiInfo *> *)allFrom:(NSInteger)start length:(NSInteger)length;

// 刪除
+ (void)deleteDownloaded:(HentaiInfo *)info handler:(void (^)(void))handler onFinish:(void (^)(BOOL successed))finish;
+ (void)deleteAllHistories:(void (^)(NSInteger total, NSInteger index, HentaiInfo *info))handler onFinish:(void (^)(BOOL successed))finish;

@end
