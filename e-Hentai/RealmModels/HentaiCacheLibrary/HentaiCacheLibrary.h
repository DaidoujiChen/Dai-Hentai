//
//  HentaiCacheLibrary.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Realm/Realm.h>

#import "HentaiSaveLibrary_HentaiResult.h"

@interface HentaiCacheLibrary : RLMObject

@property NSString *key;
@property RLMArray <HentaiSaveLibrary_HentaiResult> *items;

+ (void)addCacheInfo:(NSDictionary *)cacheInfo forKey:(NSString *)key;
+ (NSDictionary *)cacheInfoForKey:(NSString *)key;
+ (void)removeCacheInfoForKey:(NSString *)key;
+ (void)removeAllCacheInfo;

@end

RLM_ARRAY_TYPE(HentaiCacheLibrary)
