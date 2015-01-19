//
//  NSString+Hentai.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/6.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hentai)

//原先是取 lastPathComponent, 但是有些漫畫的檔案名稱會重複, 因此把倒數第二個 path 也列入編名
- (NSString *)hentai_lastTwoPathComponent;

//去除空格以及跳行
- (NSString *)hentai_withoutSpace;

@end
