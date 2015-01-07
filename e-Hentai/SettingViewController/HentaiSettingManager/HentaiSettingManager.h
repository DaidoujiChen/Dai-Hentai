//
//  HentaiSettingManager.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HentaiSettingsV2 LWPDictionary(@"HentaiSettingsV2")

@interface HentaiSettingManager : NSObject

+ (void)settingTransfer;

+ (BOOL)isHighResolution;
+ (void)setIsHighResolution:(BOOL)isHighResolution;

+ (BOOL)isUseNewBrowser;
+ (void)setIsUseNewBrowser:(BOOL)isUseNewBrowser;

@end
