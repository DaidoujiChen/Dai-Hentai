//
//  HentaiDownloadCenter.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/9.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "HentaiDownloadCenter.h"
#import <objc/runtime.h>

@implementation HentaiDownloadCenter

#pragma mark - HentaiImagesManagerInternalDelegate

+ (void)downloadFinish:(HentaiInfo *)info {
    NSString *key = [NSString stringWithFormat:@"%@-%@", info.gid, info.token];
    HentaiImagesManager *manager = [self center][key];
    if (!manager) {
        return;
    }
    
    if (!manager.delegate) {
        [self bye:info];
    }
}

#pragma mark - Private Class Method

+ (NSMutableDictionary<NSString *, HentaiImagesManager *> *)center {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)itemsInCenter:(NSInteger)items {
    [UIApplication sharedApplication].idleTimerDisabled = items > 0;
}

#pragma mark - Class Method

// 取回舊的, 或是建立一個新的 HentaiImagesManager
+ (HentaiImagesManager *)manager:(HentaiInfo *)info andParser:(Class)parser {
    NSString *key = [NSString stringWithFormat:@"%@-%@", info.gid, info.token];
    HentaiImagesManager *manager = [self center][key];
    if (!manager) {
        manager = [[HentaiImagesManager alloc] initWith:info andParser:parser];
        manager.internalDelegate = (id<HentaiImagesManagerInternalDelegate>)self;
        [self center][key] = manager;
        [self itemsInCenter:[self center].count];
    }
    return manager;
}

// 當使用完畢時, 跟這個 manager 說 881
+ (void)bye:(HentaiInfo *)info {
    NSString *key = [NSString stringWithFormat:@"%@-%@", info.gid, info.token];
    HentaiImagesManager *manager = [self center][key];
    if (!manager) {
        return;
    }
    
    // 如果不需要完整下載, 則直接從託管移除掉
    manager.delegate = nil;
    if (!manager.aliveForDownload) {
        [[self center] removeObjectForKey:key];
        [self itemsInCenter:[self center].count];
    }
}

// 顯示當前的下載進度
+ (CGFloat)downloadProgress:(HentaiInfo *)info {
    NSString *key = [NSString stringWithFormat:@"%@-%@", info.gid, info.token];
    HentaiImagesManager *manager = [self center][key];
    if (manager) {
        return manager.downloadProgress;
    }
    return -1;
}

@end
