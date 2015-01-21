//
//  HentaiSaveLibrary.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Realm/Realm.h>

#import "HentaiSaveLibrary_HentaiInfo.h"
#import "HentaiSaveLibrary_HentaiResult.h"
#import "HentaiSaveLibrary_Images.h"

@interface HentaiSaveLibrary : RLMObject

@property NSString *hentaiKey;
@property NSString *group;
@property HentaiSaveLibrary_HentaiInfo *hentaiInfo;
@property RLMArray <HentaiSaveLibrary_HentaiResult> *hentaiResult;
@property RLMArray <HentaiSaveLibrary_Images> *images;

+ (void)addSaveInfo:(NSDictionary *)saveInfo toGroup:(NSString *)group;
+ (NSUInteger)count;
+ (NSUInteger)countByGroup:(NSString *)group;
+ (NSUInteger)countBySearchInfo:(NSDictionary *)searchInfo;
+ (void)changeToGroup:(NSString *)group atHentaiKey:(NSString *)hentaiKey;
+ (NSDictionary *)saveInfoAtHentaiKey:(NSString *)hentaiKey;
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index;
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index byGroup:(NSString *)group;
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index bySearchInfo:(NSDictionary *)searchInfo;
+ (void)removeSaveInfoAtHentaiKey:(NSString *)hentaiKey;
+ (NSArray *)groups;

@end

RLM_ARRAY_TYPE(HentaiSaveLibrary)
