//
//  HentaiInfo.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/30.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"

@interface HentaiInfo : DaiStorage

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSNumber *filecount;
@property (nonatomic, strong) NSString *filesize;
@property (nonatomic, strong) NSString *posted;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *title_jpn;
@property (nonatomic, strong) NSString *uploader;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *group;

@end
