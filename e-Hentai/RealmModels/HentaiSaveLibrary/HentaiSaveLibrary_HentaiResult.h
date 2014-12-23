//
//  HentaiSaveLibrary_HentaiResult.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Realm/Realm.h>

@interface HentaiSaveLibrary_HentaiResult : RLMObject

@property NSString *key;
@property float value;

@end

RLM_ARRAY_TYPE(HentaiSaveLibrary_HentaiResult)
