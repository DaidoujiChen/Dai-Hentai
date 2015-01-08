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
+ (void)addSaveInfo:(NSDictionary *)saveInfo {
    HentaiSaveLibrary *newLibrary = [HentaiSaveLibrary new];
    newLibrary.hentaiKey = saveInfo[@"hentaiKey"];
    newLibrary.group = @"";
    
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

//用 hentaiKey 查詢所在 index
+ (NSUInteger)indexOfHentaiKey:(NSString *)hentaiKey {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hentaiKey contains[c] %@", hentaiKey];
    RLMResults *resultObjects = [HentaiSaveLibrary objectsInRealm:[self hentaiSaveLibraryRealm] withPredicate:predicate];
    if (resultObjects.count) {
        return [[HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]] indexOfObject:[resultObjects firstObject]];
    }
    return NSNotFound;
}

//指定 index 返回內容
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index {
    NSMutableDictionary *returnInfo = [NSMutableDictionary dictionary];
    HentaiSaveLibrary *infoObject = [[HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]] objectAtIndex:index];
    
    returnInfo[@"hentaiKey"] = infoObject.hentaiKey;
    
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

//移除某一個 index 內容
+ (void)removeSaveInfoAtIndex:(NSUInteger)index {
    HentaiSaveLibrary *removeObject = [[HentaiSaveLibrary allObjectsInRealm:[self hentaiSaveLibraryRealm]] objectAtIndex:index];
    
    [[self hentaiSaveLibraryRealm] beginWriteTransaction];
    [[self hentaiSaveLibraryRealm] deleteObject:removeObject.hentaiInfo];
    [[self hentaiSaveLibraryRealm] deleteObjects:removeObject.hentaiResult];
    [[self hentaiSaveLibraryRealm] deleteObjects:removeObject.images];
    [[self hentaiSaveLibraryRealm] deleteObject:removeObject];
    [[self hentaiSaveLibraryRealm] commitWriteTransaction];
}

#pragma mark - private

//存在特定檔案
+ (RLMRealm *)hentaiSaveLibraryRealm {
    NSString *realmPath = [[FilesManager documentFolder] currentPath];
    return [RLMRealm realmWithPath:[realmPath stringByAppendingPathComponent:@"HentaiSaveLibrary.realm"]];
}

@end
