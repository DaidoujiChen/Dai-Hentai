//
//  HentaiInfo.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/12.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "DaiStorage.h"

DaiStorageArrayConverter(NSString)

@interface HentaiInfo : DaiStorage

@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *title_jpn;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *uploader;
@property (nonatomic, strong) NSString *filecount;
@property (nonatomic, strong) NSString *filesize;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *posted;
@property (nonatomic, strong) NSStringArray *tags;

@property (nonatomic, strong) NSNumber *userLatestPage;
@property (nonatomic, strong) NSNumber *timeStamp;

// 只要有寫入 db 的就會算在歷史, 下載需要另外打 flag
@property (nonatomic, strong) NSNumber *downloaded;

- (NSString *)bestTitle;
- (NSString *)folder;
- (NSArray<NSString *> *)engTitleSplit;
- (NSArray<NSString *> *)jpnTitleSplit;

@end
