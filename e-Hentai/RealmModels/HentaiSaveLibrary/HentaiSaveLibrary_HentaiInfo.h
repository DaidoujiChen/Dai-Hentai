//
//  HentaiInfo.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/23.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Realm/Realm.h>

@interface HentaiSaveLibrary_HentaiInfo : RLMObject

@property NSString *category;
@property NSString *filecount;
@property NSString *filesize;
@property NSString *posted;
@property NSString *rating;
@property NSString *thumb;
@property NSString *title;
@property NSString *title_jpn;
@property NSString *uploader;
@property NSString *url;

@end

RLM_ARRAY_TYPE(HentaiSaveLibrary_HentaiInfo)
