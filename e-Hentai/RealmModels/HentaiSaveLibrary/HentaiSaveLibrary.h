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
@property HentaiSaveLibrary_HentaiInfo *hentaiInfo;
@property RLMArray <HentaiSaveLibrary_HentaiResult> *hentaiResult;
@property RLMArray <HentaiSaveLibrary_Images> *images;

+ (void)addSaveInfo:(NSDictionary *)saveInfo;
+ (NSUInteger)count;
+ (NSUInteger)foundDownloadKey:(NSString *)hentaiKey;
+ (NSDictionary *)saveInfoAtIndex:(NSUInteger)index;
+ (void)removeSaveInfoAtIndex:(NSUInteger)index;

@end

RLM_ARRAY_TYPE(HentaiSaveLibrary)
