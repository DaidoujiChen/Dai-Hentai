//
//  HentaiCacheLibrary.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiCacheLibrary.h"

@implementation HentaiCacheLibrary

#pragma mark - class method

//增加一筆新的 cache 資料
+ (void)addCacheInfo:(NSDictionary *)cacheInfo forKey:(NSString *)key {
    [self removeCacheInfoForKey:key];
    
    HentaiCacheLibrary *newCacheLibrary = [HentaiCacheLibrary new];
    newCacheLibrary.key = key;
    
    for (NSString *eachKey in [cacheInfo allKeys]) {
        HentaiSaveLibrary_HentaiResult *newResult = [HentaiSaveLibrary_HentaiResult new];
        newResult.key = eachKey;
        NSNumber *value = cacheInfo[eachKey];
        newResult.value = value.floatValue;
        [newCacheLibrary.items addObject:newResult];
    }
    
    [[self hentaiCacheLibraryRealm] beginWriteTransaction];
    [[self hentaiCacheLibraryRealm] addObject:newCacheLibrary];
    [[self hentaiCacheLibraryRealm] commitWriteTransaction];
}

//用 key 值取得一筆 cache 資料
+ (NSDictionary *)cacheInfoForKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key contains[c] %@", key];
    RLMResults *oldObjects = [HentaiCacheLibrary objectsInRealm:[self hentaiCacheLibraryRealm] withPredicate:predicate];
    if (oldObjects.count) {
        HentaiCacheLibrary *cacheLibrary = [oldObjects firstObject];
        NSMutableDictionary *hentaiResultDictionary = [NSMutableDictionary dictionary];
        for (HentaiSaveLibrary_HentaiResult *eachHentaiResultObject in cacheLibrary.items) {
            hentaiResultDictionary[eachHentaiResultObject.key] = @(eachHentaiResultObject.value);
        }
        return hentaiResultDictionary;
    }
    return nil;
}

//根據 key 值移除 cache 資料
+ (void)removeCacheInfoForKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key contains[c] %@", key];
    RLMResults *oldObjects = [HentaiCacheLibrary objectsInRealm:[self hentaiCacheLibraryRealm] withPredicate:predicate];
    if (oldObjects.count) {
        HentaiCacheLibrary *removeObject = [oldObjects firstObject];
        [[self hentaiCacheLibraryRealm] beginWriteTransaction];
        [[self hentaiCacheLibraryRealm] deleteObjects:removeObject.items];
        [[self hentaiCacheLibraryRealm] deleteObject:removeObject];
        [[self hentaiCacheLibraryRealm] commitWriteTransaction];
    }
}

//清除所有 cache 資料
+ (void)removeAllCacheInfo {
    [[self hentaiCacheLibraryRealm] beginWriteTransaction];
    [[self hentaiCacheLibraryRealm] deleteAllObjects];
    [[self hentaiCacheLibraryRealm] commitWriteTransaction];
}

#pragma mark - private

//存在特定檔案
+ (RLMRealm *)hentaiCacheLibraryRealm {
    NSString *realmPath = [[FilesManager documentFolder] currentPath];
    return [RLMRealm realmWithPath:[realmPath stringByAppendingPathComponent:@"HentaiCacheLibrary.realm"]];
}

@end
