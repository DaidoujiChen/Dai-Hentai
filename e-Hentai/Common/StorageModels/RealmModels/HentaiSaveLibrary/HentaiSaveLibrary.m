//
//  HentaiSaveLibrary.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiSaveLibrary.h"

@implementation HentaiSaveLibrary

#pragma mark - class method

//儲存整本作品的資訊
+ (void)addSaveInfo:(NSDictionary *)saveInfo toGroup:(NSString *)group {
    HentaiSaveLibrary *newLibrary = [HentaiSaveLibrary new];
    newLibrary.hentaiKey = saveInfo[@"hentaiKey"];
    newLibrary.group = group;
    
    HentaiSaveLibrary_HentaiInfo *newInfo = [HentaiSaveLibrary_HentaiInfo new];
    newInfo.category = saveInfo[@"hentaiInfo"][@"category"];
    newInfo.filecount = saveInfo[@"hentaiInfo"][@"filecount"];
    newInfo.filesize = saveInfo[@"hentaiInfo"][@"filesize"];
    newInfo.posted = saveInfo[@"hentaiInfo"][@"posted"];
    newInfo.rating = saveInfo[@"hentaiInfo"][@"rating"];
    newInfo.thumb = saveInfo[@"hentaiInfo"][@"thumb"];
    newInfo.title = saveInfo[@"hentaiInfo"][@"title"];
    newInfo.title_jpn = saveInfo[@"hentaiInfo"][@"title_jpn"];
    newInfo.uploader = saveInfo[@"hentaiInfo"][@"uploader"];
    newInfo.url = saveInfo[@"hentaiInfo"][@"url"];
    newLibrary.hentaiInfo = newInfo;
    
    NSDictionary *hentaiResult = saveInfo[@"hentaiResult"];
    for (NSString *eachKey in[hentaiResult allKeys]) {
        HentaiSaveLibrary_HentaiResult *newResult = [HentaiSaveLibrary_HentaiResult new];
        newResult.key = eachKey;
        NSNumber *value = hentaiResult[eachKey];
        newResult.value = value.floatValue;
        [newLibrary.hentaiResult addObject:newResult];
    }
    
    NSArray *images = saveInfo[@"images"];
    for (NSString *eachURL in images) {
        HentaiSaveLibrary_Images *newImage = [HentaiSaveLibrary_Images new];
        newImage.url = eachURL;
        [newLibrary.images addObject:newImage];
    }
    
    [[self hentaiSaveLibraryRealm] beginWriteTransaction];
    [[self hentaiSaveLibraryRealm] addObject:newLibrary];
    [[self hentaiSaveLibraryRealm] commitWriteTransaction];
}

//已下載數量
+ (NSUInteger)count {
    return [[HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]] count];
}

//某個 group 的數量
+ (NSUInteger)countByGroup:(NSString *)group {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@", group];
    return [[HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate] count];
}

//某個搜尋條件的數量
+ (NSUInteger)countBySearchInfo:(NSDictionary *)searchInfo {
    RLMResults *hentaiSaveLibrarys = [self hentaiSaveLibraryBySearchInfo:searchInfo];
    return [hentaiSaveLibrarys count];
}

//update 某一個作品的 group
+ (void)changeToGroup:(NSString *)group atHentaiKey:(NSString *)hentaiKey {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hentaiKey == %@", hentaiKey];
    RLMResults *resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];
    if (resultObjects.count) {
        HentaiSaveLibrary *saveInfo = [resultObjects firstObject];
        [[self hentaiSaveLibraryRealm] beginWriteTransaction];
        saveInfo.group = group;
        [[self hentaiSaveLibraryRealm] commitWriteTransaction];
    }
}

//從 hentaikey 直接回 saveinfo
+ (NSDictionary *)saveInfoAtHentaiKey:(NSString *)hentaiKey {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hentaiKey == %@", hentaiKey];
    RLMResults *resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];
    if (resultObjects.count) {
        HentaiSaveLibrary *saveInfo = [resultObjects firstObject];
        return [self dictionaryFromRealm:saveInfo];
    }
    return nil;
}

//指定 index 返回內容
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index {
    HentaiSaveLibrary *infoObject = [[HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]] objectAtIndex:index];
    return [self dictionaryFromRealm:infoObject];
}

//指定某個 group 內特定 index 的內容
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index byGroup:(NSString *)group {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@", group];
    HentaiSaveLibrary *infoObject = [[HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate] objectAtIndex:index];
    return [self dictionaryFromRealm:infoObject];
}

//指定某一個搜尋條件內特定 index 的內容
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index bySearchInfo:(NSDictionary *)searchInfo {
    RLMResults *hentaiSaveLibrarys = [self hentaiSaveLibraryBySearchInfo:searchInfo];
    HentaiSaveLibrary *infoObject = hentaiSaveLibrarys[index];
    return [self dictionaryFromRealm:infoObject];
}

//移除某一個 hentaikey 的內容
+ (void)removeSaveInfoAtHentaiKey:(NSString *)hentaiKey {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hentaiKey == %@", hentaiKey];
    RLMResults *resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];
    if (resultObjects.count) {
        HentaiSaveLibrary *removeObject = [resultObjects firstObject];
        [self removeHentaiSaveLibrary:removeObject];
    }
}

//回傳共有多少 groups
+ (NSArray *)groups {
    NSMutableDictionary *categorys = [NSMutableDictionary dictionary];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group != %@", @""];
    RLMResults *resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];    for (HentaiSaveLibrary *eachHentaiSaveLibrary in resultObjects) {
        if (![eachHentaiSaveLibrary.group isEqualToString:@""]) {
            categorys[eachHentaiSaveLibrary.group] = eachHentaiSaveLibrary.group;
        }
    }
    NSMutableArray *groups = [NSMutableArray array];
    for (NSString *eachKey in [categorys allKeys]) {
        [groups addObject:@{@"title":eachKey, @"value":eachKey}];
    }
    return [groups sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *string1 = obj1[@"title"];
        NSString *string2 = obj2[@"title"];
        return [string1 compare:string2];
    }];
}

#pragma mark - private

+ (RLMResults *)hentaiSaveLibraryBySearchInfo:(NSDictionary *)searchInfo {
    RLMResults *resultObjects;
    NSMutableArray *predicateStrings = [NSMutableArray array];
    NSMutableArray *arguments = [NSMutableArray array];
    
    //分類搜尋
    if ([searchInfo[@"group"] isKindOfClass:[NSString class]]) {
        if (![searchInfo[@"group"] isEqualToString:@""]) {
            [predicateStrings addObject:@"(group == %@)"];
            [arguments addObject:searchInfo[@"group"]];
        }
    }
    else {
        [predicateStrings addObject:@"(group == %@)"];
        [arguments addObject:@""];
    }
    
    //title 搜尋
    if (searchInfo[@"titles"]) {
        NSArray *titles = searchInfo[@"titles"];
        for (NSString *eachTitle in titles) {
            [predicateStrings addObject:@"(hentaiInfo.title contains[c] %@ OR hentaiInfo.title_jpn contains[c] %@)"];
            [arguments addObject:eachTitle];
            [arguments addObject:eachTitle];
        }
    }
    
    if ([predicateStrings count]) {
        NSString *finalPredicateString = [predicateStrings componentsJoinedByString:@" AND "];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:finalPredicateString argumentArray:arguments];
        resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];
    }
    else {
        resultObjects = [HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]];
    }
    return resultObjects;
}

+ (void)removeHentaiSaveLibrary:(HentaiSaveLibrary *)removeObject {
    [[self hentaiSaveLibraryRealm] beginWriteTransaction];
    [[self hentaiSaveLibraryRealm] deleteObject:removeObject.hentaiInfo];
    [[self hentaiSaveLibraryRealm] deleteObjects:removeObject.hentaiResult];
    [[self hentaiSaveLibraryRealm] deleteObjects:removeObject.images];
    [[self hentaiSaveLibraryRealm] deleteObject:removeObject];
    [[self hentaiSaveLibraryRealm] commitWriteTransaction];
}

+ (NSDictionary *)dictionaryFromRealm:(HentaiSaveLibrary *)realm {
    NSMutableDictionary *returnInfo = [NSMutableDictionary dictionary];
    HentaiSaveLibrary *infoObject = realm;
    
    returnInfo[@"hentaiKey"] = infoObject.hentaiKey;
    returnInfo[@"group"] = infoObject.group;
    
    NSMutableDictionary *hentaiInfoDictionary = [NSMutableDictionary dictionary];
    HentaiSaveLibrary_HentaiInfo *hentaiInfoObject = infoObject.hentaiInfo;
    hentaiInfoDictionary[@"category"] = hentaiInfoObject.category;
    hentaiInfoDictionary[@"filecount"] = hentaiInfoObject.filecount;
    hentaiInfoDictionary[@"filesize"] = hentaiInfoObject.filesize;
    hentaiInfoDictionary[@"posted"] = hentaiInfoObject.posted;
    hentaiInfoDictionary[@"rating"] = hentaiInfoObject.rating;
    hentaiInfoDictionary[@"thumb"] = hentaiInfoObject.thumb;
    hentaiInfoDictionary[@"title"] = hentaiInfoObject.title;
    hentaiInfoDictionary[@"title_jpn"] = hentaiInfoObject.title_jpn;
    hentaiInfoDictionary[@"uploader"] = hentaiInfoObject.uploader;
    hentaiInfoDictionary[@"url"] = hentaiInfoObject.url;
    returnInfo[@"hentaiInfo"] = hentaiInfoDictionary;
    
    NSMutableDictionary *hentaiResultDictionary = [NSMutableDictionary dictionary];
    for (HentaiSaveLibrary_HentaiResult *eachHentaiResultObject in infoObject.hentaiResult) {
        hentaiResultDictionary[eachHentaiResultObject.key] = @(eachHentaiResultObject.value);
    }
    returnInfo[@"hentaiResult"] = hentaiResultDictionary;
    
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (HentaiSaveLibrary_Images *eachImageObject in infoObject.images) {
        [imagesArray addObject:eachImageObject.url];
    }
    returnInfo[@"images"] = imagesArray;
    
    return returnInfo;
}

//存在特定檔案
+ (RLMRealm *)hentaiSaveLibraryRealm {
    NSString *realmPath = [[FilesManager documentFolder] currentPath];
    return [RLMRealm realmWithPath:[realmPath stringByAppendingPathComponent:@"HentaiSaveLibrary.realm"]];
}

@end
