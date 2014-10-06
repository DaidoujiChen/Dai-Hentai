//
//  HentaiDownloadCenter.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiDownloadCenter.h"

#import <objc/runtime.h>

@implementation HentaiDownloadCenter

#pragma mark - HentaiDownloadBookOperationDelegate

//用來回報 download center 的狀態
+ (void)hentaiDownloadBookOperationChange:(NSDictionary *)change operation:(HentaiDownloadBookOperation *)operation {
    HentaiMonitorBlock monitor = [self monitor];
    if (monitor) {
        //這樣寫很智障, 但是寫起來比較快, 而且違背 delegate 這樣寫的本意, 想到好方法的時候會來優化
        NSMutableArray *waitingItems = [NSMutableArray array];
        NSMutableArray *downloadingItems = [NSMutableArray array];
        NSArray *operations = [[self allBooksOperationQueue] operations];
        
        for (HentaiDownloadBookOperation *eachOperation in operations) {
            switch (eachOperation.status) {
                case HentaiDownloadBookOperationStatusWaiting:
                    [waitingItems addObject:@{ @"hentaiInfo":eachOperation.hentaiInfo }];
                    break;
                    
                case HentaiDownloadBookOperationStatusDownloading:
                    [downloadingItems addObject:@{ @"hentaiInfo":eachOperation.hentaiInfo, @"recvCount":@(eachOperation.recvCount), @"totalCount":@(eachOperation.totalCount) }];
                    break;
                    
                default:
                    break;
            }
        }
        monitor(@{ @"waitingItems":waitingItems, @"downloadingItems":downloadingItems });
    }
}

#pragma mark - class method

+ (void)addBook:(NSDictionary *)hentaiInfo {
    BOOL isExist = NO;
    
    //如果下載過的話不給下
    for (NSDictionary *eachInfo in HentaiSaveLibraryArray) {
        if ([eachInfo[@"url"] isEqualToString:hentaiInfo[@"url"]]) {
            isExist = YES;
            break;
        }
    }
    
    //如果在 queue 裡面也不給下
    isExist = isExist | [self isDownloading:hentaiInfo];
    
    if (isExist) {
        [UIAlertView hentai_alertViewWithTitle:@"不行~ O3O" message:@"你可能已經下載過或是正在下載中!" cancelButtonTitle:@"確定"];
    }
    else {
        HentaiDownloadBookOperation *newOperation = [HentaiDownloadBookOperation new];
        newOperation.delegate = (id <HentaiDownloadBookOperationDelegate> )self;
        newOperation.hentaiInfo = hentaiInfo;
        newOperation.status = HentaiDownloadBookOperationStatusWaiting;
        [[self allBooksOperationQueue] addOperation:newOperation];
    }
}

+ (BOOL)isDownloading:(NSDictionary *)hentaiInfo {
    BOOL isExist = NO;
    
    for (HentaiDownloadBookOperation *eachOperation in[[self allBooksOperationQueue] operations]) {
        if ([eachOperation.hentaiInfo[@"url"] isEqualToString:hentaiInfo[@"url"]]) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

+ (BOOL)isActiveFolder:(NSString *)folder {
    BOOL isExist = NO;
    for (HentaiDownloadBookOperation *eachOperation in[[self allBooksOperationQueue] operations]) {
        if ([folder isEqualToString:[eachOperation.hentaiInfo hentaiKey]]) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

+ (void)centerMonitor:(HentaiMonitorBlock)monitor {
    [self setMonitor:monitor];
    
    //直接先刷新一次
    [self hentaiDownloadBookOperationChange:nil operation:nil];
}

#pragma mark - private

+ (NSOperationQueue *)allBooksOperationQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue *hentaiQueue = [NSOperationQueue new];
        [hentaiQueue setMaxConcurrentOperationCount:2];
        objc_setAssociatedObject(self, _cmd, hentaiQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setMonitor:(HentaiMonitorBlock)monitor {
    objc_setAssociatedObject(self, @selector(monitor), monitor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (HentaiMonitorBlock)monitor {
    return objc_getAssociatedObject(self, _cmd);
}

@end
