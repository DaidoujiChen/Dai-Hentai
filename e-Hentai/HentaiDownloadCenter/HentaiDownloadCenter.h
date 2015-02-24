//
//  HentaiDownloadCenter.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HentaiDownloadBookOperation.h"

typedef void (^HentaiMonitorBlock)(NSDictionary *centerDetail);

@interface HentaiDownloadCenter : NSObject

+ (void)addBook:(NSDictionary *)hentaiInfo toGroup:(NSString *)group;
+ (BOOL)isDownloading:(NSDictionary *)hentaiInfo;
+ (BOOL)isActiveFolder:(NSString *)folder;

+ (void)centerMonitor:(HentaiMonitorBlock)monitor;

@end
